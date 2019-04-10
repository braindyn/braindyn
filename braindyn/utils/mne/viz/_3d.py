import warnings

import numpy as np
import os.path as op
from mne import pick_types

from mne.bem import ConductorModel, _bem_find_surface, read_bem_surfaces, _surf_dict, _surf_name
from mne.defaults import DEFAULTS
from mne.externals.six import string_types
from mne.forward import _create_meg_coils
from mne.io import read_fiducials, _loc_to_coil_trans
from mne.io.constants import FIFF
from mne.surface import _complete_sphere_surf, get_meg_helmet_surf, _project_onto_surface
from mne.transforms import _find_trans, read_trans, _ensure_trans, Transform, invert_transform, combine_transforms, \
    apply_trans, transform_surface_to
from mne.utils import _import_mlab, _validate_type, get_subjects_dir, logger, warn, SilenceStdout, _check_subject
from mne.viz._3d import _fiducial_coords, _sensor_shape, _mlab_figure, _toggle_mlab_render, _create_mesh_surf, \
    _plot_mpl_stc, _handle_time, _limits_to_control_points, _get_ps_kwargs

from braindyn.utils.mne.source_space import SourceSpaces
from braindyn.utils.mne.surface import read_surface


def plot_alignment(info, trans=None, subject=None, subjects_dir=None,
                   surfaces='head', scalp_surfaces=[], brain_surfaces=[], coord_frame='head',
                   meg=None, eeg='original',
                   dig=False, ecog=True, src=None, mri_fiducials=False,
                   bem=None, seeg=True, show_axes=False, fig=None,
                   interaction='trackball', verbose=None):
    """Plot head, sensor, and source space alignment in 3D.

    Parameters
    ----------
    info : dict
        The measurement info.
    trans : str | 'auto' | dict | None
        The full path to the head<->MRI transform ``*-trans.fif`` file
        produced during coregistration. If trans is None, an identity matrix
        is assumed.
    subject : str | None
        The subject name corresponding to FreeSurfer environment
        variable SUBJECT. Can be omitted if ``src`` is provided.
    subjects_dir : str | None
        The path to the freesurfer subjects reconstructions.
        It corresponds to Freesurfer environment variable SUBJECTS_DIR.
    surfaces : str | list
        Surfaces to plot. Supported values:

        * scalp: one of 'head', 'outer_skin' (alias for 'head'),
          'head-dense', or 'seghead' (alias for 'head-dense')
        * skull: 'outer_skull', 'inner_skull', 'brain' (alias for
          'inner_skull')
        * brain: one of 'pial', 'white', 'inflated', or 'brain'
          (alias for 'pial').

        Defaults to 'head'.

        .. note:: For single layer BEMs it is recommended to use 'brain'.
    coord_frame : str
        Coordinate frame to use, 'head', 'meg', or 'mri'.
    meg : str | list | bool | None
        Can be "helmet", "sensors" or "ref" to show the MEG helmet, sensors or
        reference sensors respectively, or a combination like
        ``('helmet', 'sensors')`` (same as None, default). True translates to
        ``('helmet', 'sensors', 'ref')``.
    eeg : bool | str | list
        Can be "original" (default; equivalent to True) or "projected" to
        show EEG sensors in their digitized locations or projected onto the
        scalp, or a list of these options including ``[]`` (equivalent of
        False).
    dig : bool | 'fiducials'
        If True, plot the digitization points; 'fiducials' to plot fiducial
        points only.
    ecog : bool
        If True (default), show ECoG sensors.
    src : instance of SourceSpaces | None
        If not None, also plot the source space points.
    mri_fiducials : bool | str
        Plot MRI fiducials (default False). If ``True``, look for a file with
        the canonical name (``bem/{subject}-fiducials.fif``). If ``str`` it
        should provide the full path to the fiducials file.
    bem : list of dict | Instance of ConductorModel | None
        Can be either the BEM surfaces (list of dict), a BEM solution or a
        sphere model. If None, we first try loading
        `'$SUBJECTS_DIR/$SUBJECT/bem/$SUBJECT-$SOURCE.fif'`, and then look for
        `'$SUBJECT*$SOURCE.fif'` in the same directory. For `'outer_skin'`,
        the subjects bem and bem/flash folders are searched. Defaults to None.
    seeg : bool
        If True (default), show sEEG electrodes.
    show_axes : bool
        If True (default False), coordinate frame axis indicators will be
        shown:

        * head in pink
        * MRI in gray (if ``trans is not None``)
        * MEG in blue (if MEG sensors are present)

        .. versionadded:: 0.16
    fig : mayavi figure object | None
        Mayavi Scene (instance of mlab.Figure) in which to plot the alignment.
        If ``None``, creates a new 600x600 pixel figure with black background.

        .. versionadded:: 0.16
    interaction : str
        Can be "trackball" (default) or "terrain", i.e. a turntable-style
        camera.

        .. versionadded:: 0.16
    verbose : bool, str, int, or None
        If not None, override default verbose level (see :func:`mne.verbose`
        and :ref:`Logging documentation <tut_logging>` for more).

    Returns
    -------
    fig : instance of mlab.Figure
        The mayavi figure.

    See Also
    --------
    mne.viz.plot_bem

    Notes
    -----
    This function serves the purpose of checking the validity of the many
    different steps of source reconstruction:

    - Transform matrix (keywords ``trans``, ``meg`` and ``mri_fiducials``),
    - BEM surfaces (keywords ``bem`` and ``surfaces``),
    - sphere conductor model (keywords ``bem`` and ``surfaces``) and
    - source space (keywords ``surfaces`` and ``src``).

    .. versionadded:: 0.15
    """
    mlab = _import_mlab()
    from tvtk.api import tvtk

    if eeg is False:
        eeg = list()
    elif eeg is True:
        eeg = 'original'
    if meg is None:
        meg = ('helmet', 'sensors')
        # only consider warning if the value is explicit
        warn_meg = False
    else:
        warn_meg = True

    if meg is True:
        meg = ('helmet', 'sensors', 'ref')
    elif meg is False:
        meg = list()
    elif isinstance(meg, string_types):
        meg = [meg]
    if isinstance(eeg, string_types):
        eeg = [eeg]

    if not isinstance(interaction, string_types) or \
            interaction not in ('trackball', 'terrain'):
        raise ValueError('interaction must be "trackball" or "terrain", '
                         'got "%s"' % (interaction,))

    for kind, var in zip(('eeg', 'meg'), (eeg, meg)):
        if not isinstance(var, (list, tuple)) or \
                not all(isinstance(x, string_types) for x in var):
            raise TypeError('%s must be list or tuple of str, got %s'
                            % (kind, type(var)))
    if not all(x in ('helmet', 'sensors', 'ref') for x in meg):
        raise ValueError('meg must only contain "helmet", "sensors" or "ref", '
                         'got %s' % (meg,))
    if not all(x in ('original', 'projected') for x in eeg):
        raise ValueError('eeg must only contain "original" and '
                         '"projected", got %s' % (eeg,))

    _validate_type(info, "info")

    if isinstance(surfaces, string_types):
        surfaces = [surfaces]
    surfaces = list(surfaces)
    for s in surfaces:
        _validate_type(s, "str", "all entries in surfaces")

    if isinstance(scalp_surfaces, string_types):
        scalp_surfaces = [scalp_surfaces]
    scalp_surfaces = list(scalp_surfaces)
    for s in scalp_surfaces:
        _validate_type(s, "str", "all entries in scalp_surfaces")

    if isinstance(brain_surfaces, string_types):
        brain_surfaces = [brain_surfaces]
    brain_surfaces = list(brain_surfaces)
    for s in brain_surfaces:
        _validate_type(s, "str", "all entries in brain_surfaces")

    is_sphere = False
    if isinstance(bem, ConductorModel) and bem['is_sphere']:
        if len(bem['layers']) != 4 and len(surfaces) > 1:
            raise ValueError('The sphere conductor model must have three '
                             'layers for plotting skull and head.')
        is_sphere = True

    valid_coords = ['head', 'meg', 'mri']
    if coord_frame not in valid_coords:
        raise ValueError('coord_frame must be one of %s' % (valid_coords,))
    if src is not None:
        if not isinstance(src, SourceSpaces):
            raise TypeError('src must be None or SourceSpaces, got %s'
                            % (type(src),))
        src_subject = src[0].get('subject_his_id', None)
        subject = src_subject if subject is None else subject
        if src_subject is not None and subject != src_subject:
            raise ValueError('subject ("%s") did not match the subject name '
                             ' in src ("%s")' % (subject, src_subject))
        src_rr = np.concatenate([s['rr'][s['inuse'].astype(bool)]
                                 for s in src])
        src_nn = np.concatenate([s['nn'][s['inuse'].astype(bool)]
                                 for s in src])
    else:
        src_rr = src_nn = np.empty((0, 3))

    ref_meg = 'ref' in meg
    meg_picks = pick_types(info, meg=True, ref_meg=ref_meg)
    eeg_picks = pick_types(info, meg=False, eeg=True, ref_meg=False)
    ecog_picks = pick_types(info, meg=False, ecog=True, ref_meg=False)
    seeg_picks = pick_types(info, meg=False, seeg=True, ref_meg=False)

    if isinstance(trans, string_types):
        if trans == 'auto':
            # let's try to do this in MRI coordinates so they're easy to plot
            subjects_dir = get_subjects_dir(subjects_dir, raise_error=True)
            trans = _find_trans(subject, subjects_dir)
        trans = read_trans(trans, return_all=True)
        for ti, trans in enumerate(trans):  # we got at least 1
            try:
                trans = _ensure_trans(trans, 'head', 'mri')
            except Exception:
                if ti == len(trans) - 1:
                    raise
            else:
                break
    elif trans is None:
        trans = Transform('head', 'mri')
    else:
        _validate_type(trans, (Transform,), "str, Transform, or None")
    head_mri_t = _ensure_trans(trans, 'head', 'mri')
    dev_head_t = info['dev_head_t']
    del trans

    # Figure out our transformations
    if coord_frame == 'meg':
        head_trans = invert_transform(dev_head_t)
        meg_trans = Transform('meg', 'meg')
        mri_trans = invert_transform(combine_transforms(
            dev_head_t, head_mri_t, 'meg', 'mri'))
    elif coord_frame == 'mri':
        head_trans = head_mri_t
        meg_trans = combine_transforms(dev_head_t, head_mri_t, 'meg', 'mri')
        mri_trans = Transform('mri', 'mri')
    else:  # coord_frame == 'head'
        head_trans = Transform('head', 'head')
        meg_trans = info['dev_head_t']
        mri_trans = invert_transform(head_mri_t)

    # both the head and helmet will be in MRI coordinates after this
    surfs = dict()

    # Head:
    sphere_level = 4
    head = False
    for s in scalp_surfaces:
        if head:
            raise ValueError('Can only supply one head-like surface name')
        surfaces.pop(scalp_surfaces.index(s))
        head = True
        head_surf = None
        # Try the BEM if applicable
        if bem is not None:
            if isinstance(bem, ConductorModel):
                if is_sphere:
                    head_surf = _complete_sphere_surf(bem, 3, sphere_level, complete=False)
                else:  # BEM solution
                    head_surf = _bem_find_surface(
                        bem, FIFF.FIFFV_BEM_SURF_ID_HEAD)
            elif bem is not None:  # list of dict
                for this_surf in bem:
                    if this_surf['id'] == FIFF.FIFFV_BEM_SURF_ID_HEAD:
                        head_surf = this_surf
                        break
                else:
                    raise ValueError('Could not find the surface for '
                                     'head in the provided BEM model.')
        if head_surf is None:
            if subject is None:
                raise ValueError('To plot the head surface, the BEM/sphere'
                                 ' model must contain a head surface '
                                 'or "subject" must be provided (got '
                                 'None)')
            subject_dir = op.join(
                get_subjects_dir(subjects_dir, raise_error=True), subject)
            try_fnames = [
                op.join(subject_dir, 'bem', s),
                op.join(subject_dir, 'surf', s),
            ]
            for fname in try_fnames:
                if op.exists(fname):
                    logger.info('Using %s for head surface.'
                                % (op.basename(fname),))
                    head_surf = read_surface(
                        fname, return_dict=True)
                    head_surf['rr'] /= 1000.
                    head_surf.update(coord_frame=FIFF.FIFFV_COORD_MRI)
                    break
            else:
                raise IOError('No head surface found for subject '
                              '%s after trying:\n%s'
                              % (subject, '\n'.join(try_fnames)))
        surfs['head'] = head_surf

    # Skull:
    skull = list()
    for name, id_ in (('outer_skull', FIFF.FIFFV_BEM_SURF_ID_SKULL),
                      ('inner_skull', FIFF.FIFFV_BEM_SURF_ID_BRAIN)):
        if name in surfaces:
            surfaces.pop(surfaces.index(name))
            if bem is None:
                fname = op.join(
                    get_subjects_dir(subjects_dir, raise_error=True),
                    subject, 'bem', name + '.surf')
                if not op.isfile(fname):
                    raise ValueError('bem is None and the the %s file cannot '
                                     'be found:\n%s' % (name, fname))
                surf = read_surface(fname, return_dict=True)[2]
                surf.update(coord_frame=FIFF.FIFFV_COORD_MRI,
                            id=_surf_dict[name])
                surf['rr'] /= 1000.
                skull.append(surf)
            elif isinstance(bem, ConductorModel):
                if is_sphere:
                    if len(bem['layers']) != 4:
                        raise ValueError('The sphere model must have three '
                                         'layers for plotting %s' % (name,))
                    this_idx = 1 if name == 'inner_skull' else 2
                    skull.append(_complete_sphere_surf(
                        bem, this_idx, sphere_level))
                    skull[-1]['id'] = _surf_dict[name]
                else:
                    skull.append(_bem_find_surface(bem, id_))
            else:  # BEM model
                for this_surf in bem:
                    if this_surf['id'] == _surf_dict[name]:
                        skull.append(this_surf)
                        break
                else:
                    raise ValueError('Could not find the surface for %s.'
                                     % name)

    if mri_fiducials:
        if mri_fiducials is True:
            subjects_dir = get_subjects_dir(subjects_dir, raise_error=True)
            if subject is None:
                raise ValueError("Subject needs to be specified to "
                                 "automatically find the fiducials file.")
            mri_fiducials = op.join(subjects_dir, subject, 'bem',
                                    subject + '-fiducials.fif')
        if isinstance(mri_fiducials, string_types):
            mri_fiducials, cf = read_fiducials(mri_fiducials)
            if cf != FIFF.FIFFV_COORD_MRI:
                raise ValueError("Fiducials are not in MRI space")
        fid_loc = _fiducial_coords(mri_fiducials, FIFF.FIFFV_COORD_MRI)
        fid_loc = apply_trans(mri_trans, fid_loc)
    else:
        fid_loc = []

    if 'helmet' in meg and len(meg_picks) > 0:
        surfs['helmet'] = get_meg_helmet_surf(info, head_mri_t)
        assert surfs['helmet']['coord_frame'] == FIFF.FIFFV_COORD_MRI

    # Brain:
    if len(brain_surfaces) > 1:
        raise ValueError('Only one brain surface can be plotted. '
                         'Got %s.' % brain_surfaces[0])
    elif len(brain_surfaces) == 0:
        brain = False
    else:  # exactly 1
        brain = brain_surfaces[0]
        if is_sphere:
            if len(bem['layers']) > 0:
                surfs['brain'] = _complete_sphere_surf(bem, 0, sphere_level)  # only plot 1
        else:
            subjects_dir = get_subjects_dir(subjects_dir, raise_error=True)
            fname = op.join(subjects_dir, subject, 'surf',
                            brain)
            surfs['brain'] = read_surface(fname, return_dict=True)
            surfs['brain']['rr'] /= 1000.
            surfs['brain'].update(coord_frame=FIFF.FIFFV_COORD_MRI)
        brain = True

    # we've looked through all of them, raise if some remain
    if len(surfaces) > 0:
        raise ValueError('Unknown surfaces types: %s' % (surfaces,))

    skull_alpha = dict()
    skull_colors = dict()
    hemi_val = 0.5
    if src is None or (brain and any(s['type'] == 'surf' for s in src)):
        hemi_val = 1.
    alphas = (4 - np.arange(len(skull) + 1)) * (0.5 / 4.)
    for idx, this_skull in enumerate(skull):
        if isinstance(this_skull, dict):
            skull_surf = this_skull
            this_skull = _surf_name[skull_surf['id']]
        elif is_sphere:  # this_skull == str
            this_idx = 1 if this_skull == 'inner_skull' else 2
            skull_surf = _complete_sphere_surf(bem, this_idx, sphere_level)
        else:  # str
            skull_fname = op.join(subjects_dir, subject, 'bem', 'flash',
                                  '%s.surf' % this_skull)
            if not op.exists(skull_fname):
                skull_fname = op.join(subjects_dir, subject, 'bem',
                                      '%s.surf' % this_skull)
            if not op.exists(skull_fname):
                raise IOError('No skull surface %s found for subject %s.'
                              % (this_skull, subject))
            logger.info('Using %s for head surface.' % skull_fname)
            skull_surf = read_surface(skull_fname, return_dict=True)[2]
            skull_surf['rr'] /= 1000.
            skull_surf['coord_frame'] = FIFF.FIFFV_COORD_MRI
        skull_alpha[this_skull] = alphas[idx + 1]
        skull_colors[this_skull] = (0.95 - idx * 0.2, 0.85, 0.95 - idx * 0.2)
        surfs[this_skull] = skull_surf

    if src is None and brain is False and len(skull) == 0 and not show_axes:
        head_alpha = 1.0
    else:
        head_alpha = alphas[0]

    for key in surfs.keys():
        # Surfs can sometimes be in head coords (e.g., if coming from sphere)
        surfs[key] = transform_surface_to(surfs[key], coord_frame,
                                          [mri_trans, head_trans], copy=True)
    if src is not None:
        if src[0]['coord_frame'] == FIFF.FIFFV_COORD_MRI:
            src_rr = apply_trans(mri_trans, src_rr)
            src_nn = apply_trans(mri_trans, src_nn, move=False)
        elif src[0]['coord_frame'] == FIFF.FIFFV_COORD_HEAD:
            src_rr = apply_trans(head_trans, src_rr)
            src_nn = apply_trans(head_trans, src_nn, move=False)

    # determine points
    meg_rrs, meg_tris = list(), list()
    ecog_loc = list()
    seeg_loc = list()
    hpi_loc = list()
    ext_loc = list()
    car_loc = list()
    eeg_loc = list()
    eegp_loc = list()
    if len(eeg) > 0:
        eeg_loc = np.array([info['chs'][k]['loc'][:3] for k in eeg_picks])
        if len(eeg_loc) > 0:
            eeg_loc = apply_trans(head_trans, eeg_loc)
            # XXX do projections here if necessary
            if 'projected' in eeg:
                eegp_loc, eegp_nn = _project_onto_surface(
                    eeg_loc, surfs['head'], project_rrs=True,
                    return_nn=True)[2:4]
            if 'original' not in eeg:
                eeg_loc = list()
    del eeg
    if 'sensors' in meg:
        coil_transs = [_loc_to_coil_trans(info['chs'][pick]['loc'])
                       for pick in meg_picks]
        coils = _create_meg_coils([info['chs'][pick] for pick in meg_picks],
                                  acc='normal')
        offset = 0
        for coil, coil_trans in zip(coils, coil_transs):
            rrs, tris = _sensor_shape(coil)
            rrs = apply_trans(coil_trans, rrs)
            meg_rrs.append(rrs)
            meg_tris.append(tris + offset)
            offset += len(meg_rrs[-1])
        if len(meg_rrs) == 0:
            if warn_meg:
                warn('MEG sensors not found. Cannot plot MEG locations.')
        else:
            meg_rrs = apply_trans(meg_trans, np.concatenate(meg_rrs, axis=0))
            meg_tris = np.concatenate(meg_tris, axis=0)
    del meg
    if dig:
        if dig == 'fiducials':
            hpi_loc = ext_loc = []
        elif dig is not True:
            raise ValueError("dig needs to be True, False or 'fiducials', "
                             "not %s" % repr(dig))
        else:
            hpi_loc = np.array([d['r'] for d in (info['dig'] or [])
                                if d['kind'] == FIFF.FIFFV_POINT_HPI])
            ext_loc = np.array([d['r'] for d in (info['dig'] or [])
                                if d['kind'] == FIFF.FIFFV_POINT_EXTRA])
        car_loc = _fiducial_coords(info['dig'])
        # Transform from head coords if necessary
        if coord_frame == 'meg':
            for loc in (hpi_loc, ext_loc, car_loc):
                loc[:] = apply_trans(invert_transform(info['dev_head_t']), loc)
        elif coord_frame == 'mri':
            for loc in (hpi_loc, ext_loc, car_loc):
                loc[:] = apply_trans(head_mri_t, loc)
        if len(car_loc) == len(ext_loc) == len(hpi_loc) == 0:
            warn('Digitization points not found. Cannot plot digitization.')
    del dig
    if len(ecog_picks) > 0 and ecog:
        ecog_loc = np.array([info['chs'][pick]['loc'][:3]
                             for pick in ecog_picks])
    if len(seeg_picks) > 0 and seeg:
        seeg_loc = np.array([info['chs'][pick]['loc'][:3]
                             for pick in seeg_picks])

    # initialize figure
    if fig is None:
        fig = _mlab_figure(bgcolor=(0.5, 0.5, 0.5), size=(800, 800))
    if interaction == 'terrain' and fig.scene is not None:
        fig.scene.interactor.interactor_style = \
            tvtk.InteractorStyleTerrain()
    _toggle_mlab_render(fig, False)

    # plot surfaces
    alphas = dict(head=head_alpha, helmet=0.25, lh=hemi_val, rh=hemi_val, brain=hemi_val)
    alphas.update(skull_alpha)
    colors = dict(head=(0.6,) * 3, helmet=(0.0, 0.0, 0.6), lh=(0.5,) * 3,
                  rh=(0.5,) * 3, brain=(0.5,) * 3)
    colors.update(skull_colors)
    for key, surf in surfs.items():
        # Make a solid surface
        mesh = _create_mesh_surf(surf, fig)
        with warnings.catch_warnings(record=True):  # traits
            surface = mlab.pipeline.surface(
                mesh, color=colors[key], opacity=alphas[key], figure=fig)
        if key != 'helmet':
            surface.actor.property.backface_culling = True
    if brain and ('lh' not in surfs and 'brain' not in surfs):  # one layer sphere
        assert bem['coord_frame'] == FIFF.FIFFV_COORD_HEAD
        center = bem['r0'].copy()
        center = apply_trans(head_trans, center)
        mlab.points3d(*center, scale_factor=0.01, color=colors['lh'],
                      opacity=alphas['lh'])
    if show_axes:
        axes = [(head_trans, (0.9, 0.3, 0.3))]  # always show head
        if not np.allclose(mri_trans['trans'], np.eye(4)):  # Show MRI
            axes.append((mri_trans, (0.6, 0.6, 0.6)))
        if len(meg_picks) > 0:  # Show MEG
            axes.append((meg_trans, (0., 0.6, 0.6)))
        for ax in axes:
            x, y, z = np.tile(ax[0]['trans'][:3, 3], 3).reshape((3, 3)).T
            u, v, w = ax[0]['trans'][:3, :3]
            mlab.points3d(x[0], y[0], z[0], color=ax[1], scale_factor=3e-3)
            mlab.quiver3d(x, y, z, u, v, w, mode='arrow', scale_factor=2e-2,
                          color=ax[1], scale_mode='scalar', resolution=20,
                          scalars=[0.33, 0.66, 1.0])

    # plot points
    defaults = DEFAULTS['coreg']
    datas = [eeg_loc,
             hpi_loc,
             ext_loc, ecog_loc, seeg_loc]
    colors = [defaults['eeg_color'],
              defaults['hpi_color'],
              defaults['extra_color'],
              defaults['ecog_color'],
              defaults['seeg_color']]
    alphas = [0.8,
              0.5,
              0.25, 0.8, 0.8]
    scales = [defaults['eeg_scale'],
              defaults['hpi_scale'],
              defaults['extra_scale'],
              defaults['ecog_scale'],
              defaults['seeg_scale']]
    for kind, loc in (('dig', car_loc), ('mri', fid_loc)):
        if len(loc) > 0:
            datas.extend(loc[:, np.newaxis])
            colors.extend((defaults['lpa_color'],
                           defaults['nasion_color'],
                           defaults['rpa_color']))
            alphas.extend(3 * (defaults[kind + '_fid_opacity'],))
            scales.extend(3 * (defaults[kind + '_fid_scale'],))

    for data, color, alpha, scale in zip(datas, colors, alphas, scales):
        if len(data) > 0:
            with warnings.catch_warnings(record=True):  # traits
                points = mlab.points3d(data[:, 0], data[:, 1], data[:, 2],
                                       color=color, scale_factor=scale,
                                       opacity=alpha, figure=fig)
                points.actor.property.backface_culling = True
    if len(eegp_loc) > 0:
        with warnings.catch_warnings(record=True):  # traits
            quiv = mlab.quiver3d(
                eegp_loc[:, 0], eegp_loc[:, 1], eegp_loc[:, 2],
                eegp_nn[:, 0], eegp_nn[:, 1], eegp_nn[:, 2],
                color=defaults['eegp_color'], mode='cylinder',
                scale_factor=defaults['eegp_scale'], opacity=0.6, figure=fig)
        quiv.glyph.glyph_source.glyph_source.height = defaults['eegp_height']
        quiv.glyph.glyph_source.glyph_source.center = \
            (0., -defaults['eegp_height'], 0)
        quiv.glyph.glyph_source.glyph_source.resolution = 20
        quiv.actor.property.backface_culling = True
    if len(meg_rrs) > 0:
        color, alpha = (0., 0.25, 0.5), 0.25
        surf = dict(rr=meg_rrs, tris=meg_tris)
        mesh = _create_mesh_surf(surf, fig)
        with warnings.catch_warnings(record=True):  # traits
            surface = mlab.pipeline.surface(mesh, color=color,
                                            opacity=alpha, figure=fig)
        surface.actor.property.backface_culling = True
    if len(src_rr) > 0:
        with warnings.catch_warnings(record=True):  # traits
            quiv = mlab.quiver3d(
                src_rr[:, 0], src_rr[:, 1], src_rr[:, 2],
                src_nn[:, 0], src_nn[:, 1], src_nn[:, 2], color=(1., 1., 0.),
                mode='cylinder', scale_factor=3e-3, opacity=0.75, figure=fig)
        quiv.glyph.glyph_source.glyph_source.height = 0.25
        quiv.glyph.glyph_source.glyph_source.center = (0., 0., 0.)
        quiv.glyph.glyph_source.glyph_source.resolution = 20
        quiv.actor.property.backface_culling = True
    with SilenceStdout():
        mlab.view(90, 90, focalpoint=(0., 0., 0.), distance=0.6, figure=fig)
    _toggle_mlab_render(fig, True)
    return fig


def plot_source_estimates(stc, subject=None, surface='inflated',
                          colormap='auto', time_label='auto',
                          smoothing_steps=10, transparent=True, alpha=1.0,
                          time_viewer=False, subjects_dir=None, figure=None,
                          views='lat', colorbar=True, clim='auto',
                          cortex="classic", size=800, background="black",
                          foreground="white", initial_time=None,
                          time_unit='s', backend='auto', spacing='oct6',
                          title=None, verbose=None):
    """Plot SourceEstimates with PySurfer.

    By default this function uses :mod:`mayavi.mlab` to plot the source
    estimates. If Mayavi is not installed, the plotting is done with
    :mod:`matplotlib.pyplot` (much slower, decimated source space by default).

    Parameters
    ----------
    stc : SourceEstimates
        The source estimates to plot.
    subject : str | None
        The subject name corresponding to FreeSurfer environment
        variable SUBJECT. If None stc.subject will be used. If that
        is None, the environment will be used.
    surface : str
        The type of surface (inflated, white etc.).
    hemi : str, 'lh' | 'rh' | 'split' | 'both'
        The hemisphere to display.
    colormap : str | np.ndarray of float, shape(n_colors, 3 | 4)
        Name of colormap to use or a custom look up table. If array, must
        be (n x 3) or (n x 4) array for with RGB or RGBA values between
        0 and 255. The default ('auto') uses 'hot' for one-sided data and
        'mne' for two-sided data.
    time_label : str | callable | None
        Format of the time label (a format string, a function that maps
        floating point time values to strings, or None for no label). The
        default is ``time=%0.2f ms``.
    smoothing_steps : int
        The amount of smoothing
    transparent : bool
        If True, use a linear transparency between fmin and fmid.
    alpha : float
        Alpha value to apply globally to the overlay. Has no effect with mpl
        backend.
    time_viewer : bool
        Display time viewer GUI.
    subjects_dir : str
        The path to the freesurfer subjects reconstructions.
        It corresponds to Freesurfer environment variable SUBJECTS_DIR.
    figure : instance of mayavi.core.scene.Scene | instance of matplotlib.figure.Figure | list | int | None
        If None, a new figure will be created. If multiple views or a
        split view is requested, this must be a list of the appropriate
        length. If int is provided it will be used to identify the Mayavi
        figure by it's id or create a new figure with the given id. If an
        instance of matplotlib figure, mpl backend is used for plotting.
    views : str | list
        View to use. See surfer.Brain(). Supported views: ['lat', 'med', 'ros',
        'cau', 'dor' 'ven', 'fro', 'par']. Using multiple views is not
        supported for mpl backend.
    colorbar : bool
        If True, display colorbar on scene.
    clim : str | dict
        Colorbar properties specification. If 'auto', set clim automatically
        based on data percentiles. If dict, should contain:

            ``kind`` : 'value' | 'percent'
                Flag to specify type of limits.
            ``lims`` : list | np.ndarray | tuple of float, 3 elements
                Left, middle, and right bound for colormap.
            ``pos_lims`` : list | np.ndarray | tuple of float, 3 elements
                Left, middle, and right bound for colormap. Positive values
                will be mirrored directly across zero during colormap
                construction to obtain negative control points.

        .. note:: Only sequential colormaps should be used with ``lims``, and
                  only divergent colormaps should be used with ``pos_lims``.
    cortex : str or tuple
        Specifies how binarized curvature values are rendered.
        Either the name of a preset PySurfer cortex colorscheme (one of
        'classic', 'bone', 'low_contrast', or 'high_contrast'), or the name of
        mayavi colormap, or a tuple with values (colormap, min, max, reverse)
        to fully specify the curvature colors. Has no effect with mpl backend.
    size : float or pair of floats
        The size of the window, in pixels. can be one number to specify
        a square window, or the (width, height) of a rectangular window.
        Has no effect with mpl backend.
    background : matplotlib color
        Color of the background of the display window.
    foreground : matplotlib color
        Color of the foreground of the display window. Has no effect with mpl
        backend.
    initial_time : float | None
        The time to display on the plot initially. ``None`` to display the
        first time sample (default).
    time_unit : 's' | 'ms'
        Whether time is represented in seconds ("s", default) or
        milliseconds ("ms").
    backend : 'auto' | 'mayavi' | 'matplotlib'
        Which backend to use. If ``'auto'`` (default), tries to plot with
        mayavi, but resorts to matplotlib if mayavi is not available.

        .. versionadded:: 0.15.0

    spacing : str
        The spacing to use for the source space. Can be ``'ico#'`` for a
        recursively subdivided icosahedron, ``'oct#'`` for a recursively
        subdivided octahedron, or ``'all'`` for all points. In general, you can
        speed up the plotting by selecting a sparser source space. Has no
        effect with mayavi backend. Defaults  to 'oct6'.

        .. versionadded:: 0.15.0
    title : str | None
        Title for the figure. If None, the subject name will be used.

        .. versionadded:: 0.17.0
    verbose : bool, str, int, or None
        If not None, override default verbose level (see :func:`mne.verbose`
        and :ref:`Logging documentation <tut_logging>` for more).

    Returns
    -------
    figure : surfer.viz.Brain | matplotlib.figure.Figure
        An instance of :class:`surfer.Brain` from PySurfer or
        matplotlib figure.
    """  # noqa: E501
    # import here to avoid circular import problem
    from braindyn.utils.mne.source_estimate import SourceEstimate
    _validate_type(stc, SourceEstimate, "stc", "Surface Source Estimate")
    subjects_dir = get_subjects_dir(subjects_dir=subjects_dir,
                                    raise_error=True)
    subject = _check_subject(stc.subject, subject, True)
    if backend not in ['auto', 'matplotlib', 'mayavi']:
        raise ValueError("backend must be 'auto', 'mayavi' or 'matplotlib'. "
                         "Got %s." % backend)
    plot_mpl = backend == 'matplotlib'
    if not plot_mpl:
        try:
            from mayavi import mlab  # noqa: F401
        except ImportError:
            if backend == 'auto':
                warn('Mayavi not found. Resorting to matplotlib 3d.')
                plot_mpl = True
            else:  # 'mayavi'
                raise

    if plot_mpl:
        return _plot_mpl_stc(stc, subject=subject, surface=surface, hemi=hemi,
                             colormap=colormap, time_label=time_label,
                             smoothing_steps=smoothing_steps,
                             subjects_dir=subjects_dir, views=views, clim=clim,
                             figure=figure, initial_time=initial_time,
                             time_unit=time_unit, background=background,
                             spacing=spacing, time_viewer=time_viewer,
                             colorbar=colorbar, transparent=transparent)
    from surfer import Brain, TimeViewer

    time_label, times = _handle_time(time_label, time_unit, stc.times)
    # convert control points to locations in colormap
    colormap, scale_pts, diverging, transparent = _limits_to_control_points(
        clim, stc.data, colormap, transparent)

    if title is None:
        title = subject
    with warnings.catch_warnings(record=True):  # traits warnings
        brain = Brain(subject, surf=surface, hemi='both',
                      title=title, cortex=cortex, size=size,
                      background=background, foreground=foreground,
                      figure=figure, subjects_dir=subjects_dir,
                      views=views)

    ad_kwargs, sd_kwargs = _get_ps_kwargs(
        initial_time, diverging, scale_pts[1], transparent)
    del initial_time, transparent
    data = getattr(stc, 'data')
    vertices = stc.vertices[0]
    if len(data) > 0:
        with warnings.catch_warnings(record=True):  # traits warnings
            brain.add_data(data, colormap=colormap, vertices=vertices,
                           smoothing_steps=smoothing_steps, time=times,
                           time_label=time_label, alpha=alpha, hemi='both',
                           colorbar=colorbar,
                           min=scale_pts[0], max=scale_pts[2], **ad_kwargs)
    if 'mid' not in ad_kwargs:  # PySurfer < 0.9
        brain.scale_data_colormap(fmin=scale_pts[0], fmid=scale_pts[1],
                                  fmax=scale_pts[2], **sd_kwargs)
    if time_viewer:
        TimeViewer(brain)
    return brain
