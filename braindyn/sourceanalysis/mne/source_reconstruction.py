import mne
import os
import numpy as np
from mne.minimum_norm import make_inverse_operator
import matplotlib.pyplot as plt
from nibabel.gifti import giftiio, GiftiImage, GiftiDataArray

from braindyn.utils.mne.minimum_norm.inverse import apply_inverse, apply_inverse_epochs, apply_inverse_raw


def compute_covariance(raw_file, epochs_file, out_fname=None, plot=False):
    """Compute covariance matrix

        Parameters
        ----------
        raw_file: str
            filename of raw data
        epochs_file: str
            filename of epochs data
        out_fname : str or None
            filename to write covariance matrix to (if not None)
        plot : bool, or None
            Whether or not to plot

        Returns
        -------
        noise_cov : instance of Covariance
            The covariance matrix
    """
    raw = mne.io.read_raw_fif(raw_file)
    epochs = mne.read_epochs(epochs_file)

    noise_cov = _compute_covariance(epochs, out_fname)

    if plot:
        fig_cov, fig_spectra = mne.viz.plot_cov(noise_cov, raw.info)

    return noise_cov


def _compute_covariance(epochs, out_fname):
    noise_cov = mne.compute_covariance(epochs, tmax=0, method=['shrunk', 'empirical'], rank=None, verbose=True)
    if out_fname is not None:
        mne.write_cov(out_fname, noise_cov)
    return noise_cov


def source_reconstruction(data, data_type, forward_file, cov_file, snr, method='dSPM', out_fname=None, plot=False):
    """Run source reconstruction

        Parameters
        ----------
        data: instance of Raw or instance of Epochs or instance of Evoked
            data to run source reconstruction on
        data_type: str (raw, epochs, or evoked)
            data type
        cov_file : str
            filename to read covariance matrix from
        snr : float
            SNR
        method : str
            inversion method to use
        out_fname : str or None
            filename to write output to (if not None)
        plot : bool, or None
            Whether or not to plot

        Returns
        -------
        stc : instance of SourceEstimate or list of SourceEstimate
            The source estimate
    """
    noise_cov = mne.read_cov(cov_file)

    fwd = mne.read_forward_solution(forward_file)

    stc = _source_reconstruction(data, data_type, fwd, noise_cov, snr, method)

    if plot:

        plt.figure()
        if data_type == 'evoked' or data_type == 'raw':
            source_peaks = np.max(stc.data, axis=1)
            peak = np.argmax(source_peaks)
            plt.plot(1e3 * stc.times, stc.data[peak, :].T)
        elif data_type == 'epochs':
            all_data = np.zeros((len(stc), fwd['src'][0]['nuse'], len(data.times)))
            for k, stc_trial in enumerate(stc):
                all_data[k, :, :] = stc_trial.data
            mean_data = np.squeeze(np.mean(all_data, axis=0))
            source_peaks = np.max(mean_data, axis=1)
            peak = np.argmax(source_peaks)

            for k, stc_trial in enumerate(stc):
                plt.plot(1e3 * stc_trial.times, stc_trial.data[peak, :].T, 'k--',
                         alpha=0.5)

        plt.xlabel('time (ms)')
        plt.ylabel('%s value' % method)
        plt.show()

    if out_fname is not None:
        if data_type == 'evoked' or data_type == 'raw':
            data = GiftiDataArray(stc.data.astype('float32'), datatype='NIFTI_TYPE_FLOAT32',
                                  ordering="ColumnMajorOrder")
            img = GiftiImage(darrays=[data])
            giftiio.write(img, out_fname)
        elif data_type == 'epochs':
            [path, ext] = os.path.splitext(out_fname)
            [path, file] = os.path.split(path)
            for k, stc_trial in enumerate(stc):
                data = GiftiDataArray(stc_trial.data.astype('float32'), datatype='NIFTI_TYPE_FLOAT32',
                                      ordering="ColumnMajorOrder")
                img = GiftiImage(darrays=[data])
                giftiio.write(img, os.path.join(path, '%s_%d%s' % (file, k, ext)))

    return stc


def _source_reconstruction(data, data_type, fwd, noise_cov, snr, method):
    inverse_operator = make_inverse_operator(data.info, fwd, noise_cov, loose=0.2, depth=0.8)

    lambda2 = 1. / snr ** 2

    if data_type == 'evoked':
        stc = apply_inverse(data, inverse_operator, lambda2, method=method, pick_ori=None,
                            return_residual=False, verbose=True)
    elif data_type == 'epochs':
        evoked = epochs.average().pick_types(meg=True)
        stc = apply_inverse_epochs(data, inverse_operator, lambda2, method=method, label=None, nave=evoked.nave,
                                   pick_ori=None, return_generator=False, verbose=True)
    elif data_type == 'raw':
        stc = apply_inverse_raw(data, inverse_operator, lambda2, method=method, stop=3000, label=None, pick_ori=None,
                                verbose=True)
    return stc


if __name__ == '__main__':
    subjects_dir = '/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167'
    raw_file = '/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/gb070167_1_raw.fif'
    epochs_file = '/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/gb070167_1-epo.fif'
    cov_file = '/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/gb070167)1-cov.fif'
    fwd_file = '/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/gb070167-fwd.fif'

    compute_covariance(raw_file, epochs_file, out_fname=cov_file, plot=True)

    raw = mne.io.read_raw_fif(raw_file)
    epochs = mne.read_epochs(epochs_file)

    evoked = epochs.average().pick_types(meg=True)
    evoked.plot(time_unit='s')
    evoked.plot_topomap(ch_type='mag', time_unit='s')

    source_reconstruction(evoked, 'evoked', fwd_file, cov_file, 3, plot=True,
                          out_fname='/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/evoked.gii')

    source_reconstruction(epochs, 'epochs', fwd_file, cov_file, 3, plot=True,
                          out_fname='/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/epochs.gii')

    source_reconstruction(raw, 'raw', fwd_file, cov_file, 1, plot=True,
                          out_fname='/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/raw.gii')
