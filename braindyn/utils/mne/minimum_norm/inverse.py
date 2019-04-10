import numpy as np
from mne.io.constants import FIFF
from mne.minimum_norm.inverse import _check_reference, _check_method, _check_ori, _check_ch_names, _check_or_prepare, \
    _pick_channels_inverse_operator, _assemble_kernel, combine_xyz, _subject_from_inverse
from mne.source_estimate import _get_src_type, VectorSourceEstimate, VolSourceEstimate, \
    MixedSourceEstimate
from mne.utils import logger

from braindyn.utils.mne.source_estimate import SourceEstimate


def apply_inverse(evoked, inverse_operator, lambda2=1. / 9., method="dSPM",
                  pick_ori=None, prepared=False, label=None,
                  method_params=None, return_residual=False, verbose=None):
    """Apply inverse operator to evoked data.

    Parameters
    ----------
    evoked : Evoked object
        Evoked data.
    inverse_operator: instance of InverseOperator
        Inverse operator.
    lambda2 : float
        The regularization parameter.
    method : "MNE" | "dSPM" | "sLORETA" | "eLORETA"
        Use minimum norm [1]_, dSPM (default) [2]_, sLORETA [3]_, or
        eLORETA [4]_.
    pick_ori : None | "normal" | "vector"
        If "normal", rather than pooling the orientations by taking the norm,
        only the radial component is kept. This is only implemented
        when working with loose orientations.
        If "vector", no pooling of the orientations is done and the vector
        result will be returned in the form of a
        :class:`mne.VectorSourceEstimate` object. This is only implemented when
        working with loose orientations.
    prepared : bool
        If True, do not call :func:`prepare_inverse_operator`.
    label : Label | None
        Restricts the source estimates to a given label. If None,
        source estimates will be computed for the entire source space.
    method_params : dict | None
        Additional options for eLORETA. See Notes for details.

        .. versionadded:: 0.16
    return_residual : bool
        If True (default False), return the residual evoked data.
        Cannot be used with ``method=='eLORETA'``.

        .. versionadded:: 0.17
    verbose : bool, str, int, or None
        If not None, override default verbose level (see :func:`mne.verbose`
        and :ref:`Logging documentation <tut_logging>` for more).

    Returns
    -------
    stc : SourceEstimate | VectorSourceEstimate | VolSourceEstimate
        The source estimates.
    residual : instance of Evoked
        The residual evoked data, only returned if return_residual is True.

    See Also
    --------
    apply_inverse_raw : Apply inverse operator to raw object
    apply_inverse_epochs : Apply inverse operator to epochs object

    Notes
    -----
    Currently only the ``method='eLORETA'`` has additional options.
    It performs an iterative fit with a convergence criterion, so you can
    pass a ``method_params`` :class:`dict` with string keys mapping to values
    for:

        'eps' : float
            The convergence epsilon (default 1e-6).
        'max_iter' : int
            The maximum number of iterations (default 20).
            If less regularization is applied, more iterations may be
            necessary.
        'force_equal' : bool
            Force all eLORETA weights for each direction for a given
            location equal. The default is None, which means ``True`` for
            loose-orientation inverses and ``False`` for free- and
            fixed-orientation inverses. See below.

    The eLORETA paper [4]_ defines how to compute inverses for fixed- and
    free-orientation inverses. In the free orientation case, the X/Y/Z
    orientation triplet for each location is effectively multiplied by a
    3x3 weight matrix. This is the behavior obtained with
    ``force_equal=False`` parameter.

    However, other noise normalization methods (dSPM, sLORETA) multiply all
    orientations for a given location by a single value.
    Using ``force_equal=True`` mimics this behavior by modifying the iterative
    algorithm to choose uniform weights (equivalent to a 3x3 diagonal matrix
    with equal entries).

    It is necessary to use ``force_equal=True``
    with loose orientation inverses (e.g., ``loose=0.2``), otherwise the
    solution resembles a free-orientation inverse (``loose=1.0``).
    It is thus recommended to use ``force_equal=True`` for loose orientation
    and ``force_equal=False`` for free orientation inverses. This is the
    behavior used when the parameter ``force_equal=None`` (default behavior).

    References
    ----------
    .. [1] Hamalainen M S and Ilmoniemi R. Interpreting magnetic fields of
           the brain: minimum norm estimates. Medical & Biological Engineering
           & Computing, 32(1):35-42, 1994.
    .. [2] Dale A, Liu A, Fischl B, Buckner R. (2000) Dynamic statistical
           parametric mapping: combining fMRI and MEG for high-resolution
           imaging of cortical activity. Neuron, 26:55-67.
    .. [3] Pascual-Marqui RD (2002), Standardized low resolution brain
           electromagnetic tomography (sLORETA): technical details. Methods
           Find. Exp. Clin. Pharmacology, 24(D):5-12.
    .. [4] Pascual-Marqui RD (2007). Discrete, 3D distributed, linear imaging
           methods of electric neuronal activity. Part 1: exact, zero error
           localization. arXiv:0710.3341
    """
    _check_reference(evoked, inverse_operator['info']['ch_names'])
    _check_method(method)
    if method == 'eLORETA' and return_residual:
        raise ValueError('eLORETA does not currently support return_residual')
    _check_ori(pick_ori, inverse_operator['source_ori'])
    #
    #   Set up the inverse according to the parameters
    #
    nave = evoked.nave

    _check_ch_names(inverse_operator, evoked.info)

    inv = _check_or_prepare(inverse_operator, nave, lambda2, method,
                            method_params, prepared)

    #
    #   Pick the correct channels from the data
    #
    sel = _pick_channels_inverse_operator(evoked.ch_names, inv)
    logger.info('Applying inverse operator to "%s"...' % (evoked.comment,))
    logger.info('    Picked %d channels from the data' % len(sel))
    logger.info('    Computing inverse...')
    K, noise_norm, vertno, source_nn = _assemble_kernel(inv, label, method,
                                                        pick_ori)
    sol = np.dot(K, evoked.data[sel])  # apply imaging kernel
    logger.info('    Computing residual...')
    # x̂(t) = G ĵ(t) = C ** 1/2 U Π w(t)
    # where the diagonal matrix Π has elements πk = λk γk
    Pi = inv['sing'] * inv['reginv']
    data_w = np.dot(inv['whitener'],  # C ** -0.5
                    np.dot(inv['proj'], evoked.data[sel]))
    w_t = np.dot(inv['eigen_fields']['data'], data_w)  # U.T @ data
    data_est = np.dot(inv['colorer'],  # C ** 0.5
                      np.dot(inv['eigen_fields']['data'].T,  # U
                             Pi[:, np.newaxis] * w_t))
    data_est_w = np.dot(inv['whitener'], np.dot(inv['proj'], data_est))
    var_exp = 1 - ((data_est_w - data_w) ** 2).sum() / (data_w ** 2).sum()
    logger.info('    Explained %5.1f%% variance' % (100 * var_exp,))
    if return_residual:
        residual = evoked.copy()
        residual.data[sel] -= data_est
    is_free_ori = (inverse_operator['source_ori'] ==
                   FIFF.FIFFV_MNE_FREE_ORI and pick_ori != 'normal')

    if is_free_ori and pick_ori != 'vector':
        logger.info('    Combining the current components...')
        sol = combine_xyz(sol)

    if noise_norm is not None:
        logger.info('    %s...' % (method,))
        if is_free_ori and pick_ori == 'vector':
            noise_norm = noise_norm.repeat(3, axis=0)
        sol *= noise_norm

    tstep = 1.0 / evoked.info['sfreq']
    tmin = float(evoked.times[0])
    subject = _subject_from_inverse(inverse_operator)

    src_type = _get_src_type(inverse_operator['src'], vertno)
    stc = _make_stc(sol, vertno, tmin=tmin, tstep=tstep, subject=subject,
                    vector=(pick_ori == 'vector'), source_nn=source_nn,
                    src_type=src_type)
    logger.info('[done]')

    return (stc, residual) if return_residual else stc


def _make_stc(data, vertices, src_type=None, tmin=None, tstep=None,
              subject=None, vector=False, source_nn=None, warn_text=None):
    """Generate a surface, vector-surface, volume or mixed source estimate."""
    if src_type is None:
        # attempt to guess from vertices
        src_type = _get_src_type(src=None, vertices=vertices,
                                 warn_text=warn_text)

    if src_type == 'surface':
        # make a surface source estimate
        if len(vertices)>1:
            n_vertices = len(vertices[0]) + len(vertices[1])
        else:
            n_vertices = len(vertices[0])
        if vector:
            if source_nn is None:
                raise RuntimeError('No source vectors supplied.')

            # Rotate data to absolute XYZ coordinates
            data_rot = np.zeros((n_vertices, 3, data.shape[1]))
            if data.shape[0] == 3 * n_vertices:
                source_nn = source_nn.reshape(n_vertices, 3, 3)
                data = data.reshape(n_vertices, 3, -1)
            else:
                raise RuntimeError('Shape of data array does not match the '
                                   'number of vertices.')
            for i, d, n in zip(range(data.shape[0]), data, source_nn):
                data_rot[i] = np.dot(n.T, d)
            data = data_rot
            stc = VectorSourceEstimate(data, vertices=vertices, tmin=tmin,
                                       tstep=tstep, subject=subject)
        else:
            stc = SourceEstimate(data, vertices=vertices, tmin=tmin,
                                 tstep=tstep, subject=subject)
    elif src_type in ('volume', 'discrete'):
        if vector:
            data = data.reshape((-1, 3, data.shape[-1]))
        stc = VolSourceEstimate(data, vertices=vertices, tmin=tmin,
                                tstep=tstep, subject=subject)
    elif src_type == 'mixed':
        # make a mixed source estimate
        stc = MixedSourceEstimate(data, vertices=vertices, tmin=tmin,
                                  tstep=tstep, subject=subject)
    else:
        raise ValueError('vertices has to be either a list with one or more '
                         'arrays or an array')
    return stc
