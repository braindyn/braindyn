import mne
import numpy as np
from mne.evoked import _get_peak
from mne.source_estimate import _BaseSourceEstimate

from braindyn.utils.mne.viz import plot_source_estimates


class _BaseSurfaceSourceEstimate(mne.source_estimate._BaseSurfaceSourceEstimate):
    """Abstract base class for surface source estimates.

    Parameters
    ----------
    data : array
        The data in source space.
    vertices : list of two arrays
        Vertex numbers corresponding to the data.
    tmin : scalar
        Time point of the first sample in data.
    tstep : scalar
        Time step between successive samples in data.
    subject : str | None
        The subject name. While not necessary, it is safer to set the
        subject parameter to avoid analysis errors.
    verbose : bool, str, int, or None
        If not None, override default verbose level (see :func:`mne.verbose`
        and :ref:`Logging documentation <tut_logging>` for more).

    Attributes
    ----------
    subject : str | None
        The subject name.
    times : array of shape (n_times,)
        The time vector.
    vertices : list of two arrays of shape (n_dipoles,)
        The indices of the dipoles in the left and right source space.
    data : array
        The data in source space.
    shape : tuple
        The shape of the data. A tuple of int (n_dipoles, n_times).
    """

    def __init__(self, data, vertices=None, tmin=None, tstep=None,
                 subject=None, verbose=None):  # noqa: D102

        if not (isinstance(vertices, list) and len(vertices) == 1):
            raise ValueError('Vertices must be a list containing one '
                             'numpy array, got type %s (%s)'
                             % (type(vertices), vertices))

        _BaseSourceEstimate.__init__(self, data, vertices=vertices, tmin=tmin,
                                     tstep=tstep, subject=subject,
                                     verbose=verbose)

class SourceEstimate(_BaseSurfaceSourceEstimate):
    """Container for surface source estimates.

    Parameters
    ----------
    data : array of shape (n_dipoles, n_times) | 2-tuple (kernel, sens_data)
        The data in source space. The data can either be a single array or
        a tuple with two arrays: "kernel" shape (n_vertices, n_sensors) and
        "sens_data" shape (n_sensors, n_times). In this case, the source
        space data corresponds to "numpy.dot(kernel, sens_data)".
    vertices : list of two arrays
        Vertex numbers corresponding to the data.
    tmin : scalar
        Time point of the first sample in data.
    tstep : scalar
        Time step between successive samples in data.
    subject : str | None
        The subject name. While not necessary, it is safer to set the
        subject parameter to avoid analysis errors.
    verbose : bool, str, int, or None
        If not None, override default verbose level (see :func:`mne.verbose`
        and :ref:`Logging documentation <tut_logging>` for more).

    Attributes
    ----------
    subject : str | None
        The subject name.
    times : array of shape (n_times,)
        The time vector.
    vertices : list of two arrays of shape (n_dipoles,)
        The indices of the dipoles in the left and right source space.
    data : array of shape (n_dipoles, n_times)
        The data in source space.
    shape : tuple
        The shape of the data. A tuple of int (n_dipoles, n_times).

    See Also
    --------
    VectorSourceEstimate : A container for vector source estimates.
    VolSourceEstimate : A container for volume source estimates.
    MixedSourceEstimate : A container for mixed surface + volume source
                          estimates.
    """

    def get_peak(self, tmin=None, tmax=None, mode='abs',
                 vert_as_index=False, time_as_index=False):
        """Get location and latency of peak amplitude.

        Parameters
        ----------
        tmin : float | None
            The minimum point in time to be considered for peak getting.
        tmax : float | None
            The maximum point in time to be considered for peak getting.
        mode : {'pos', 'neg', 'abs'}
            How to deal with the sign of the data. If 'pos' only positive
            values will be considered. If 'neg' only negative values will
            be considered. If 'abs' absolute values will be considered.
            Defaults to 'abs'.
        vert_as_index : bool
            whether to return the vertex index instead of of its ID.
            Defaults to False.
        time_as_index : bool
            Whether to return the time index instead of the latency.
            Defaults to False.

        Returns
        -------
        pos : int
            The vertex exhibiting the maximum response, either ID or index.
        latency : float | int
            The time point of the maximum response, either latency in seconds
            or index.
        """
        data = self.data
        vertno = self.vertices

        vert_idx, time_idx, _ = _get_peak(data, self.times, tmin, tmax, mode)

        return (vert_idx if vert_as_index else vertno[vert_idx],
                time_idx if time_as_index else self.times[time_idx])
