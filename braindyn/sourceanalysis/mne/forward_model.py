import mne
import numpy as np
import subprocess
import os

from mne.coreg import fit_matched_points, coregister_fiducials, trans_fname
from mne.io import write_fiducials
from mne.io.constants import FIFF
from mne.transforms import rotation, Transform, write_trans


def compute_bem_surfaces(subj_id, subjects_dir):
    #subprocess.call(["mne", "watershed_bem", "-s", subj_id, "-d", subjects_dir])

    # TODO: include flash bme for EEG forward model if we have FLASH MRI sequences
    #subprocess.call(["mne", "flash_bem", "-s", subj_id, "-d", subjects_dir])

    # TODO: these BEM surfaces don't look too good - we need to figure out a way to create higher precision surfaces
    mne.viz.plot_bem(subject=subj_id, subjects_dir=subjects_dir,
                     brain_surfaces='white', orientation='coronal')

def coregister(subj_id, subjects_dir, nas, lpa, rpa, data_file):
    # Read MEG based fiducials
    hsp=mne.channels.read_dig_montage(fif=data_file)

    # Register MEG_based fiducial coords to MRI fiducial coords
    scale=0.001

    lpa=np.array(lpa)*scale
    nas=np.array(nas)*scale
    rpa=np.array(rpa)*scale

    # Write MRI-based fiducial coords to fif file
    dig = [{'kind': FIFF.FIFFV_POINT_CARDINAL,
            'ident': FIFF.FIFFV_POINT_LPA,
            'r': lpa},
           {'kind': FIFF.FIFFV_POINT_CARDINAL,
            'ident': FIFF.FIFFV_POINT_NASION,
            'r': nas},
           {'kind': FIFF.FIFFV_POINT_CARDINAL,
            'ident': FIFF.FIFFV_POINT_RPA,
            'r': rpa}]
    fname=os.path.join(subjects_dir, subj_id, 'bem', '%s-fiducials.fif' % subj_id)
    write_fiducials(fname, dig, FIFF.FIFFV_COORD_MRI)

    n_scale_params = 0
    parameters=[0,0,0,0,0,0,1,1,1]
    head_pts = np.vstack((hsp.lpa, hsp.nasion, hsp.rpa))
    mri_pts = np.vstack((lpa, nas, rpa))
    weights = [1.0, 10.0, 1.0]
    assert n_scale_params in (0, 1)  # guaranteed by GUI
    if n_scale_params == 0:
        mri_pts *= parameters[6:9]  # not done in fit_matched_points
    x0 = np.array(parameters[:6 + n_scale_params])
    est = fit_matched_points(mri_pts, head_pts, x0=x0, out='params',
                             scale=n_scale_params, weights=weights)
    parameters[:6] = est

    # mne.gui.coregistration(tabbed=True, subject=subj_id, subjects_dir=subjects_dir, guess_mri_subject=True)

    # Figure out what to do with this transform
    head_mri_t = rotation(*parameters[:3]).T
    head_mri_t[:3, 3] = -np.dot(head_mri_t[:3, :3], parameters[3:6])

    (raw_dir,raw_file)=os.path.split(data_file)
    trans_fname=os.path.join(raw_dir, '%s-trans.fif' % (os.path.splitext(raw_file)[0]))
    write_trans(trans_fname, Transform('head', 'mri', head_mri_t))


if __name__=='__main__':
    #compute_bem_surfaces('gb070167-synth','/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167')
    coregister('gb070167-synth','/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167', [9.9898, 142.5147, -8.1787],
               [-55.7659, 49.4636, -26.2089], [88.7153, 62.4787, -29.1394],
               '/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/gb070167_1_raw.fif')