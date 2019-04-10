import copy

import nibabel.gifti
from nibabel.gifti import giftiio


def read_surface(fname, return_dict=False, verbose=None):
    """Load a Gifti surface mesh in triangular format.

    Parameters
    ----------
    fname : str
        The name of the file containing the surface.
    return_dict : bool
        If True, a dictionary with surface parameters is returned.
    verbose : bool, str, int, or None
        If not None, override default verbose level (see :func:`mne.verbose`
        and :ref:`Logging documentation <tut_logging>` for more).

    Returns
    -------
    rr : array, shape=(n_vertices, 3)
        Coordinate points.
    tris : int array, shape=(n_faces, 3)
        Triangulation (each line contains indices for three points which
        together form a face).
    volume_info : dict-like
        If read_metadata is true, key-value pairs found in the geometry file.
    surf : dict
        The surface parameters. Only returned if ``return_dict`` is True.

    See Also
    --------
    write_surface
    read_tri
    """
    ret = giftiio.read(fname)
    if return_dict:
        ret = dict(rr=copy.copy(ret.darrays[0].data), tris=copy.copy(ret.darrays[1].data), ntri=ret.darrays[1].data.shape[0],
                     use_tris=copy.copy(ret.darrays[1].data), np=ret.darrays[0].data.shape[0])
    return ret
