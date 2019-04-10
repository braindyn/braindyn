import mne
from mne.minimum_norm import make_inverse_operator
import matplotlib.pyplot as plt

from braindyn.utils.mne.minimum_norm.inverse import apply_inverse


def compute_covariance(raw_file, epochs_file, out_fname):
    raw = mne.io.read_raw_fif(raw_file)
    epochs = mne.read_epochs(epochs_file)

    noise_cov = mne.compute_covariance(epochs, tmax=0, method=['shrunk', 'empirical'], rank=None, verbose=True)
    fig_cov, fig_spectra = mne.viz.plot_cov(noise_cov, raw.info)
    mne.write_cov(out_fname,noise_cov)
    return noise_cov

def source_reconstruction(epochs_file, forward_file, cov_file, subjects_dir):
    epochs=mne.read_epochs(epochs_file)

    noise_cov=mne.read_cov(cov_file)

    evoked=epochs.average().pick_types(meg=True)
    evoked.plot(time_unit='s')
    evoked.plot_topomap(ch_type='mag', time_unit='s')
    evoked.plot_white(noise_cov, time_unit='s')

    del epochs

    fwd=mne.read_forward_solution(forward_file)
    info=evoked.info

    inverse_operator=make_inverse_operator(info, fwd, noise_cov, loose=0.2, depth=0.8)

    method='dSPM'
    snr=3
    lambda2=1./snr**2
    stc, residual=apply_inverse(evoked, inverse_operator, lambda2, method=method, pick_ori=None,
                                return_residual=True, verbose=True)

    plt.figure()
    plt.plot(1e3*stc.times, stc.data[::100,:].T)
    plt.xlabel('time (ms)')
    plt.ylabel('%s value' % method)

    fig,axes=plt.subplots(1,1)
    evoked.plot(axes=axes, show=False)
    axes.texts=[]
    for line in axes.lines:
        line.set_color('#98df81')
    residual.plot(axes=axes)
    plt.show()



if __name__=='__main__':
    subjects_dir = '/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167'
    raw_file='/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/gb070167_1_raw.fif'
    epochs_file='/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/gb070167_1-epo.fif'
    cov_file='/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/gb070167)1-cov.fif'
    fwd_file='/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/gb070167-fwd.fif'
    # compute_covariance(raw_file,
    #                    epochs_file,
    #                    cov_file)

    source_reconstruction(epochs_file,
                          fwd_file,
                          cov_file, subjects_dir)