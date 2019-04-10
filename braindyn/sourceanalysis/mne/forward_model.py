import mne
import numpy as np
import subprocess
import os

from mayavi import mlab
from mne.coreg import fit_matched_points, coregister_fiducials, trans_fname
from mne.io import write_fiducials
from mne.io.constants import FIFF
from mne.source_space import _check_spacing, SourceSpaces, add_source_space_distances
from mne.surface import complete_surface_info, _normalize_vectors, _compute_nearest, _get_surf_neighbors
from mne.transforms import rotation, Transform, write_trans

import braindyn
from braindyn.utils.mne.bem import make_bem_model, make_bem_solution
from braindyn.utils.mne.source_space import setup_source_space
from braindyn.utils.mne.surface import read_surface
from braindyn.utils.mne.viz import plot_alignment


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

    # MRI fiducial coords
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

    # Fit points
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

    # Compute transformation
    head_mri_t = rotation(*parameters[:3]).T
    head_mri_t[:3, 3] = -np.dot(head_mri_t[:3, :3], parameters[3:6])

    # Write transformation to file
    (raw_dir,raw_file)=os.path.split(data_file)
    trans_fname=os.path.join(raw_dir, '%s-trans.fif' % (os.path.splitext(raw_file)[0]))
    write_trans(trans_fname, Transform('head', 'mri', head_mri_t))

    raw=mne.io.read_raw_fif(data_file)
    trans=mne.read_trans(trans_fname)

    plot_alignment(raw.info, trans=trans, subject=subj_id, subjects_dir=subjects_dir, scalp_surfaces='outer_skin.surf.gii',
                   show_axes=True, dig=True, eeg=[], meg='sensors', coord_frame='meg')
    mlab.view(45, 90, distance=0.6, focalpoint=(0.,0.,0.))


def forward_model(subj_id, subjects_dir, data_file, trans_file, out_fname):

    src = setup_source_space(subj_id, spacing='oct6', surface='white.gii', subjects_dir=subjects_dir, add_dist=False)
    src.plot(subjects_dir=subjects_dir)
    mlab.show()

    conductivity = (0.3,)  # for single layer
    # conductivity = (0.3, 0.006, 0.3)  # for three layers
    model = make_bem_model(subject=subj_id, ico=4, inner_skull_surf='inner_skull.surf.gii',
                           outer_skull_surf='outer_skull.surf.gii', outer_skin_surf='outer_skin.surf.gii',
                           conductivity=conductivity, subjects_dir=subjects_dir)
    bem = make_bem_solution(model)
    fwd = mne.make_forward_solution(data_file, trans=trans_file, src=src, bem=bem,
                                    meg=True, eeg=False, mindist=5.0, n_jobs=2)
    print(fwd)
    mne.write_forward_solution(out_fname, fwd, overwrite=True)



if __name__=='__main__':
    subj_id='gb070167-synth'
    subjects_dir='/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167'
    data_file='/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/gb070167_1_raw.fif'
    #compute_bem_surfaces('gb070167-synth','/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167')
    trans_file=coregister(subj_id, subjects_dir, [9.9898, 142.5147, -8.1787], [-55.7659, 49.4636, -26.2089],
                          [88.7153, 62.4787, -29.1394], data_file)
    forward_model(subj_id, subjects_dir, data_file, trans_file,
                  '/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/gb070167-fwd.fif')