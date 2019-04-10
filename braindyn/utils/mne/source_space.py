import numpy as np
import os

import mne
from mne import create_info
from mne.externals.six import string_types
from mne.io.constants import FIFF
from mne.source_space import _check_spacing, add_source_space_distances, _src_kind_dict
from mne.surface import complete_surface_info, _normalize_vectors, _compute_nearest, _get_surf_neighbors
from mne.transforms import _coord_frame_name

from braindyn.utils.mne.surface import read_surface


class SourceSpaces(mne.SourceSpaces):
    def plot(self, head=False, brain=None, skull=None, subjects_dir=None,
             trans=None, verbose=None):
        """Plot the source space.

        Parameters
        ----------
        head : bool
            If True, show head surface.
        brain : bool | str
            If True, show the brain surfaces. Can also be a str for
            surface type (e.g., 'pial', same as True). Default is None,
            which means 'white' for surface source spaces and False otherwise.
        skull : bool | str | list of str | list of dict | None
            Whether to plot skull surface. If string, common choices would be
            'inner_skull', or 'outer_skull'. Can also be a list to plot
            multiple skull surfaces. If a list of dicts, each dict must
            contain the complete surface info (such as you get from
            :func:`mne.make_bem_model`). True is an alias of 'outer_skull'.
            The subjects bem and bem/flash folders are searched for the 'surf'
            files. Defaults to None, which is False for surface source spaces,
            and True otherwise.
        subjects_dir : string, or None
            Path to SUBJECTS_DIR if it is not set in the environment.
        trans : str | 'auto' | dict | None
            The full path to the head<->MRI transform ``*-trans.fif`` file
            produced during coregistration. If trans is None, an identity
            matrix is assumed. This is only needed when the source space is in
            head coordinates.
        verbose : bool, str, int, or None
            If not None, override default verbose level (see
            :func:`mne.verbose` and :ref:`Logging documentation <tut_logging>`
            for more).

        Returns
        -------
        fig : instance of mlab Figure
            The figure.
        """
        from braindyn.utils.mne.viz import plot_alignment

        surfaces = list()
        brain_surfaces = list()
        bem = None

        if brain is None:
            brain = 'white.gii' if any(ss['type'] == 'surf'
                                   for ss in self) else False

        if isinstance(brain, string_types):
            brain_surfaces.append(brain)
        elif brain:
            brain_surfaces.append('brain')

        if skull is None:
            skull = False if self.kind == 'surface' else True

        if isinstance(skull, string_types):
            surfaces.append(skull)
        elif skull is True:
            surfaces.append('outer_skull.gii')
        elif skull is not False:  # list
            if isinstance(skull[0], dict):  # bem
                skull_map = {FIFF.FIFFV_BEM_SURF_ID_BRAIN: 'inner_skull.gii',
                             FIFF.FIFFV_BEM_SURF_ID_SKULL: 'outer_skull.gii',
                             FIFF.FIFFV_BEM_SURF_ID_HEAD: 'outer_skin.gii'}
                for this_skull in skull:
                    surfaces.append(skull_map[this_skull['id']])
                bem = skull
            else:  # list of str
                for surf in skull:
                    surfaces.append(surf)

        if head:
            surfaces.append('head')

        if self[0]['coord_frame'] == FIFF.FIFFV_COORD_HEAD:
            coord_frame = 'head'
            if trans is None:
                raise ValueError('Source space is in head coordinates, but no '
                                 'head<->MRI transform was given. Please '
                                 'specify the full path to the appropriate '
                                 '*-trans.fif file as the "trans" parameter.')
        else:
            coord_frame = 'mri'

        info = create_info(0, 1000., 'eeg')

        return plot_alignment(
            info, trans=trans, subject=self[0]['subject_his_id'],
            subjects_dir=subjects_dir, brain_surfaces=brain_surfaces, surfaces=surfaces,
            coord_frame=coord_frame, meg=(), eeg=False, dig=False, ecog=False,
            bem=bem, src=self
        )

    def __repr__(self):  # noqa: D105
        ss_repr = []
        for ss in self:
            ss_type = ss['type']
            r = _src_kind_dict[ss_type]
            if ss_type == 'vol':
                if 'seg_name' in ss:
                    r += " (%s)" % (ss['seg_name'],)
                else:
                    r += ", shape=%s" % (ss['shape'],)
            elif ss_type == 'surf':
                r += (" (%s), n_vertices=%i" % (ss, ss['np']))
            r += (', n_used=%i, coordinate_frame=%s'
                  % (ss['nuse'], _coord_frame_name(int(ss['coord_frame']))))
            ss_repr.append('<%s>' % r)
        return "<SourceSpaces: [%s]>" % ', '.join(ss_repr)


def setup_source_space(subject, spacing='oct6', surface='white',
                       subjects_dir=None, add_dist=True, n_jobs=1,
                       verbose=None):
    """Set up bilateral hemisphere surface-based source space with subsampling.

    Parameters
    ----------
    subject : str
        Subject to process.
    spacing : str
        The spacing to use. Can be ``'ico#'`` for a recursively subdivided
        icosahedron, ``'oct#'`` for a recursively subdivided octahedron,
        or ``'all'`` for all points.
    surface : str
        The surface to use.
    subjects_dir : string, or None
        Path to SUBJECTS_DIR if it is not set in the environment.
    add_dist : bool
        Add distance and patch information to the source space. This takes some
        time so precomputing it is recommended.
    n_jobs : int
        Number of jobs to run in parallel. Will use at most 2 jobs
        (one for each hemisphere).
    verbose : bool, str, int, or None
        If not None, override default verbose level (see :func:`mne.verbose`
        and :ref:`Logging documentation <tut_logging>` for more).

    Returns
    -------
    src : SourceSpaces
        The source space for each hemisphere.

    See Also
    --------
    setup_volume_source_space
    """
    cmd = ('setup_source_space(%s, spacing=%s, surface=%s, '
           'subjects_dir=%s, add_dist=%s, verbose=%s)'
           % (subject, spacing, surface, subjects_dir, add_dist, verbose))

    surf = os.path.join(subjects_dir, subject, 'surf', surface)
    if surf is not None and not os.path.isfile(surf):
        raise IOError('Could not find the surface %s' % surf)

    stype, sval, ico_surf, src_type_str = _check_spacing(spacing)
    del spacing

    # mne_make_source_space ... actually make the source spaces
    src = []

    # pre-load ico/oct surf (once) for speed, if necessary
    s = _create_surf_spacing(surf, subject, stype, ico_surf, subjects_dir)

    # Fill in source space info
    # Add missing fields
    s.update(dict(dist=None, dist_limit=None, nearest=None, type='surf',
                  nearest_dist=None, pinfo=None, patch_inds=None, id=FIFF.FIFFV_MNE_SURF_UNKNOWN,
                  coord_frame=FIFF.FIFFV_COORD_MRI))
    s['rr'] /= 1000.0
    del s['tri_area']
    del s['tri_cent']
    del s['tri_nn']
    del s['neighbor_tri']
    src.append(s)

    # upconvert to object format from lists
    src = SourceSpaces(src, dict(working_dir=os.getcwd(), command_line=cmd))

    if add_dist:
        add_source_space_distances(src, n_jobs=n_jobs, verbose=verbose)

    # write out if requested, then return the data
    return src



def _create_surf_spacing(surf, subject, stype, ico_surf, subjects_dir):
    """Load a surf and use the subdivided icosahedron to get points."""
    # Based on load_source_space_surf_spacing() in load_source_space.c
    surf = read_surface(surf, return_dict=True)
    complete_surface_info(surf, copy=False)
    if stype == 'all':
        surf['inuse'] = np.ones(surf['np'], int)
        surf['use_tris'] = None
    else:  # ico or oct
        # ## from mne_ico_downsample.c ## #
        surf_name = os.path.join(subjects_dir, subject, 'surf', 'sphere.gii')
        from_surf = read_surface(surf_name, return_dict=True)
        _normalize_vectors(from_surf['rr'])
        _normalize_vectors(ico_surf['rr'])

        # Make the maps
        mmap = _compute_nearest(from_surf['rr'], ico_surf['rr'])
        nmap = len(mmap)
        surf['inuse'] = np.zeros(surf['np'], int)
        for k in range(nmap):
            if surf['inuse'][mmap[k]]:
                # Try the nearest neighbors
                neigh = _get_surf_neighbors(surf, mmap[k])
                was = mmap[k]
                inds = np.where(np.logical_not(surf['inuse'][neigh]))[0]
                if len(inds) == 0:
                    raise RuntimeError('Could not find neighbor for vertex '
                                       '%d / %d' % (k, nmap))
                else:
                    mmap[k] = neigh[inds[-1]]
            elif mmap[k] < 0 or mmap[k] > surf['np']:
                raise RuntimeError('Map number out of range (%d), this is '
                                   'probably due to inconsistent surfaces. '
                                   'Parts of the FreeSurfer reconstruction '
                                   'need to be redone.' % mmap[k])
            surf['inuse'][mmap[k]] = True

        surf['use_tris'] = np.array([mmap[ist] for ist in ico_surf['tris']],
                                    np.int32)
    if surf['use_tris'] is not None:
        surf['nuse_tri'] = len(surf['use_tris'])
    else:
        surf['nuse_tri'] = 0
    surf['nuse'] = np.sum(surf['inuse'])
    surf['vertno'] = np.where(surf['inuse'])[0]

    # set some final params
    inds = np.arange(surf['np'])
    sizes = _normalize_vectors(surf['nn'])
    surf['inuse'][sizes <= 0] = False
    surf['nuse'] = np.sum(surf['inuse'])
    surf['subject_his_id'] = subject
    return surf

