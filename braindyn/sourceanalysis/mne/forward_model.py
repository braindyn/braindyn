import mne
import subprocess

def compute_bem_surfaces(subj_id, subjects_dir):
    #subprocess.call(["mne", "watershed_bem", "-s", subj_id, "-d", subjects_dir])

    # TODO: include flash bme for EEG forward model if we have FLASH MRI sequences
    #subprocess.call(["mne", "flash_bem", "-s", subj_id, "-d", subjects_dir])

    # TODO: these BEM surfaces don't look too good - we need to figure out a way to create higher precision surfaces
    mne.viz.plot_bem(subject=subj_id, subjects_dir=subjects_dir,
                     brain_surfaces='white', orientation='coronal')

def coregister(subj_id, subjects_dir):
    mne.gui.coregistration(subject=subj_id, subjects_dir=subjects_dir, guess_mri_subject=True)

    """ TODO: do we need to do this?
    ##  Find rotation and translation to fit all 3 fiducials.
        if n_scale_params is None:
            n_scale_params = self.n_scale_params
        head_pts = np.vstack((self.hsp.lpa, self.hsp.nasion, self.hsp.rpa))
        mri_pts = np.vstack((self.mri.lpa, self.mri.nasion, self.mri.rpa))
        weights = [self.lpa_weight, self.nasion_weight, self.rpa_weight]
        assert n_scale_params in (0, 1)  # guaranteed by GUI
        if n_scale_params == 0:
            mri_pts *= self.parameters[6:9]  # not done in fit_matched_points
        x0 = np.array(self.parameters[:6 + n_scale_params])
        est = fit_matched_points(mri_pts, head_pts, x0=x0, out='params',
                                 scale=n_scale_params, weights=weights)
        if n_scale_params == 0:
            self.parameters[:6] = est
        else:
            self.parameters[:] = np.concatenate([est, [est[-1]] * 2])
    """


if __name__=='__main__':
    #compute_bem_surfaces('gb070167-synth','/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167')
    coregister('gb070167-synth','/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167')