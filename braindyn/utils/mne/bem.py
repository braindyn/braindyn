import numpy as np
import os.path as op

from mne.bem import _surfaces_to_bem, _check_bem_size, _ico_downsample, _order_surfaces, _check_surfaces, \
    _check_surface_size, _check_thicknesses, read_bem_surfaces, ConductorModel, _add_gamma_multipliers, \
    _fwd_bem_multi_solution, _fwd_bem_homog_solution, _fwd_bem_ip_modify_solution, _bem_explain_surface, \
    _correct_auto_elements
from mne.externals.six import string_types
from mne.fixes import einsum
from mne.io.constants import FIFF, FWD
from mne.surface import complete_surface_info, _fast_cross_nd_sum
from mne.utils import get_subjects_dir, logger

from braindyn.utils.mne.surface import read_surface


def make_bem_model(subject, ico=4, conductivity=(0.3, 0.006, 0.3),
                   inner_skull_surf='', outer_skull_surf='', outer_skin_surf='', subjects_dir=None, verbose=None):
    """Create a BEM model for a subject.

    .. note:: To get a single layer bem corresponding to the --homog flag in
              the command line tool set the ``conductivity`` parameter
              to a list/tuple with a single value (e.g. [0.3]).

    Parameters
    ----------
    subject : str
        The subject.
    ico : int | None
        The surface ico downsampling to use, e.g. 5=20484, 4=5120, 3=1280.
        If None, no subsampling is applied.
    conductivity : array of int, shape (3,) or (1,)
        The conductivities to use for each shell. Should be a single element
        for a one-layer model, or three elements for a three-layer model.
        Defaults to ``[0.3, 0.006, 0.3]``. The MNE-C default for a
        single-layer model would be ``[0.3]``.
    subjects_dir : string, or None
        Path to SUBJECTS_DIR if it is not set in the environment.
    verbose : bool, str, int, or None
        If not None, override default verbose level (see :func:`mne.verbose`
        and :ref:`Logging documentation <tut_logging>` for more).

    Returns
    -------
    surfaces : list of dict
        The BEM surfaces. Use `make_bem_solution` to turn these into a
        `ConductorModel` suitable for forward calculation.

    Notes
    -----
    .. versionadded:: 0.10.0

    See Also
    --------
    make_bem_solution
    make_sphere_model
    read_bem_surfaces
    write_bem_surfaces
    """
    if len(inner_skull_surf)==0:
        inner_skull_surf='inner_skull.surf'
    if len(outer_skull_surf)==0:
        outer_skull_surf='outer_skull.surf'
    if len(outer_skin_surf)==0:
        outer_skin_surf='outer_skin.surf'

    conductivity = np.array(conductivity, float)
    if conductivity.ndim != 1 or conductivity.size not in (1, 3):
        raise ValueError('conductivity must be 1D array-like with 1 or 3 '
                         'elements')
    subjects_dir = get_subjects_dir(subjects_dir, raise_error=True)
    subject_dir = op.join(subjects_dir, subject)
    bem_dir = op.join(subject_dir, 'bem')
    inner_skull = op.join(bem_dir, inner_skull_surf)
    outer_skull = op.join(bem_dir, outer_skull_surf)
    outer_skin = op.join(bem_dir, outer_skin_surf)
    surfaces = [inner_skull, outer_skull, outer_skin]
    ids = [FIFF.FIFFV_BEM_SURF_ID_BRAIN,
           FIFF.FIFFV_BEM_SURF_ID_SKULL,
           FIFF.FIFFV_BEM_SURF_ID_HEAD]
    logger.info('Creating the BEM geometry...')
    if len(conductivity) == 1:
        surfaces = surfaces[:1]
        ids = ids[:1]
    surfaces = _surfaces_to_bem(surfaces, ids, conductivity, ico)
    _check_bem_size(surfaces)
    logger.info('Complete.\n')
    return surfaces


def _surfaces_to_bem(surfs, ids, sigmas, ico=None, rescale=True,
                     incomplete='raise'):
    """Convert surfaces to a BEM."""
    # equivalent of mne_surf2bem
    # surfs can be strings (filenames) or surface dicts
    if len(surfs) not in (1, 3) or not (len(surfs) == len(ids) ==
                                        len(sigmas)):
        raise ValueError('surfs, ids, and sigmas must all have the same '
                         'number of elements (1 or 3)')
    surf = list(surfs)
    for si, surf in enumerate(surfs):
        if isinstance(surf, string_types):
            surfs[si] = read_surface(surf, return_dict=True)
    # Downsampling if the surface is isomorphic with a subdivided icosahedron
    if ico is not None:
        for si, surf in enumerate(surfs):
            surfs[si] = _ico_downsample(surf, ico)
    for surf, id_ in zip(surfs, ids):
        surf['id'] = id_
        surf['coord_frame'] = surf.get('coord_frame', FIFF.FIFFV_COORD_MRI)
        surf.update(np=len(surf['rr']), ntri=len(surf['tris']))
        if rescale:
            surf['rr'] /= 1000.  # convert to meters

    # Shifting surfaces is not implemented here...

    # Order the surfaces for the benefit of the topology checks
    for surf, sigma in zip(surfs, sigmas):
        surf['sigma'] = sigma
    surfs = _order_surfaces(surfs)

    # Check topology as best we can
    _check_surfaces(surfs, incomplete=incomplete)
    for surf in surfs:
        _check_surface_size(surf)
    _check_thicknesses(surfs)
    logger.info('Surfaces passed the basic topology checks.')
    return surfs


def make_bem_solution(surfs, verbose=None):
    """Create a BEM solution using the linear collocation approach.

    Parameters
    ----------
    surfs : list of dict
        The BEM surfaces to use (`from make_bem_model`)
    verbose : bool, str, int, or None
        If not None, override default verbose level (see :func:`mne.verbose`
        and :ref:`Logging documentation <tut_logging>` for more).

    Returns
    -------
    bem : instance of ConductorModel
        The BEM solution.

    Notes
    -----
    .. versionadded:: 0.10.0

    See Also
    --------
    make_bem_model
    read_bem_surfaces
    write_bem_surfaces
    read_bem_solution
    write_bem_solution
    """
    logger.info('Approximation method : Linear collocation\n')
    if isinstance(surfs, string_types):
        # Load the surfaces
        logger.info('Loading surfaces...')
        surfs = read_bem_surfaces(surfs)
    bem = ConductorModel(is_sphere=False, surfs=surfs)
    _add_gamma_multipliers(bem)
    if len(bem['surfs']) == 3:
        logger.info('Three-layer model surfaces loaded.')
    elif len(bem['surfs']) == 1:
        logger.info('Homogeneous model surface loaded.')
    else:
        raise RuntimeError('Only 1- or 3-layer BEM computations supported')
    _check_bem_size(bem['surfs'])
    _fwd_bem_linear_collocation_solution(bem)
    logger.info('BEM geometry computations complete.')
    return bem


def _fwd_bem_linear_collocation_solution(m):
    """Compute the linear collocation potential solution."""
    # first, add surface geometries
    for surf in m['surfs']:
        complete_surface_info(surf, copy=False, verbose=False)

    logger.info('Computing the linear collocation solution...')
    logger.info('    Matrix coefficients...')
    coeff = _fwd_bem_lin_pot_coeff(m['surfs'])
    m['nsol'] = len(coeff)
    logger.info("    Inverting the coefficient matrix...")
    nps = [surf['np'] for surf in m['surfs']]
    m['solution'] = _fwd_bem_multi_solution(coeff, m['gamma'], nps)
    if len(m['surfs']) == 3:
        ip_mult = m['sigma'][1] / m['sigma'][2]
        if ip_mult <= FWD.BEM_IP_APPROACH_LIMIT:
            logger.info('IP approach required...')
            logger.info('    Matrix coefficients (homog)...')
            coeff = _fwd_bem_lin_pot_coeff([m['surfs'][-1]])
            logger.info('    Inverting the coefficient matrix (homog)...')
            ip_solution = _fwd_bem_homog_solution(coeff,
                                                  [m['surfs'][-1]['np']])
            logger.info('    Modify the original solution to incorporate '
                        'IP approach...')
            _fwd_bem_ip_modify_solution(m['solution'], ip_solution, ip_mult,
                                        nps)
    m['bem_method'] = FWD.BEM_LINEAR_COLL
    logger.info("Solution ready.")


def _fwd_bem_lin_pot_coeff(surfs):
    """Calculate the coefficients for linear collocation approach."""
    # taken from fwd_bem_linear_collocation.c
    nps = [surf['np'] for surf in surfs]
    np_tot = sum(nps)
    coeff = np.zeros((np_tot, np_tot))
    offsets = np.cumsum(np.concatenate(([0], nps)))
    for si_1, surf1 in enumerate(surfs):
        rr_ord = np.arange(nps[si_1])
        for si_2, surf2 in enumerate(surfs):
            logger.info("        %s (%d) -> %s (%d) ..." %
                        (_bem_explain_surface(surf1['id']), nps[si_1],
                         _bem_explain_surface(surf2['id']), nps[si_2]))
            tri_rr = surf2['rr'][surf2['tris']]
            tri_nn = surf2['tri_nn']
            tri_area = surf2['tri_area']
            submat = coeff[offsets[si_1]:offsets[si_1 + 1],
                           offsets[si_2]:offsets[si_2 + 1]]  # view
            for k in range(surf2['ntri']):
                tri = surf2['tris'][k]
                if si_1 == si_2:
                    skip_idx = ((rr_ord == tri[0]) |
                                (rr_ord == tri[1]) |
                                (rr_ord == tri[2]))
                else:
                    skip_idx = list()
                # No contribution from a triangle that
                # this vertex belongs to
                # if sidx1 == sidx2 and (tri == j).any():
                #     continue
                # Otherwise do the hard job
                coeffs = _lin_pot_coeff(surf1['rr'], tri_rr[k], tri_nn[k],
                                        tri_area[k])
                coeffs[skip_idx] = 0.
                submat[:, tri] -= coeffs
            if si_1 == si_2:
                _correct_auto_elements(surf1, submat)
    return coeff


def _lin_pot_coeff(fros, tri_rr, tri_nn, tri_area):
    """Compute the linear potential matrix element computations."""
    omega = np.zeros((len(fros), 3))

    # we replicate a little bit of the _get_solids code here for speed
    # (we need some of the intermediate values later)
    v1 = tri_rr[np.newaxis, 0, :] - fros
    v2 = tri_rr[np.newaxis, 1, :] - fros
    v3 = tri_rr[np.newaxis, 2, :] - fros
    triples = _fast_cross_nd_sum(v1, v2, v3)
    l1 = np.linalg.norm(v1, axis=1)
    l2 = np.linalg.norm(v2, axis=1)
    l3 = np.linalg.norm(v3, axis=1)
    ss = l1 * l2 * l3
    ss += einsum('ij,ij,i->i', v1, v2, l3)
    ss += einsum('ij,ij,i->i', v1, v3, l2)
    ss += einsum('ij,ij,i->i', v2, v3, l1)
    solids = np.arctan2(triples, ss)

    # We *could* subselect the good points from v1, v2, v3, triples, solids,
    # l1, l2, and l3, but there are *very* few bad points. So instead we do
    # some unnecessary calculations, and then omit them from the final
    # solution. These three lines ensure we don't get invalid values in
    # _calc_beta.
    bad_mask = np.abs(solids) < np.pi / 1e6
    l1[bad_mask] = 1.
    l2[bad_mask] = 1.
    l3[bad_mask] = 1.

    # Calculate the magic vector vec_omega
    beta = [_calc_beta(v1, l1, v2, l2)[:, np.newaxis],
            _calc_beta(v2, l2, v3, l3)[:, np.newaxis],
            _calc_beta(v3, l3, v1, l1)[:, np.newaxis]]
    vec_omega = (beta[2] - beta[0]) * v1
    vec_omega += (beta[0] - beta[1]) * v2
    vec_omega += (beta[1] - beta[2]) * v3

    area2 = 2.0 * tri_area
    n2 = 1.0 / (area2 * area2)
    # leave omega = 0 otherwise
    # Put it all together...
    yys = [v1, v2, v3]
    idx = [0, 1, 2, 0, 2]
    for k in range(3):
        diff = yys[idx[k - 1]] - yys[idx[k + 1]]
        zdots = _fast_cross_nd_sum(yys[idx[k + 1]], yys[idx[k - 1]], tri_nn)
        omega[:, k] = -n2 * (area2 * zdots * 2. * solids -
                             triples * (diff * vec_omega).sum(axis=-1))
    # omit the bad points from the solution
    omega[bad_mask] = 0.
    return omega


def _calc_beta(rk, rk_norm, rk1, rk1_norm):
    """Compute coefficients for calculating the magic vector omega."""
    rkk1 = rk1[0] - rk[0]
    size = np.linalg.norm(rkk1)
    rkk1 /= size
    num = rk_norm + np.dot(rk, rkk1)
    den = rk1_norm + np.dot(rk1, rkk1)
    res = np.log(num / den) / size
    res[np.where(np.isnan(res))[0]]=0
    return res