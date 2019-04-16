import mne
import numpy as np
import subprocess
import os

from mayavi import mlab
from mne.coreg import fit_matched_points
from mne.io import write_fiducials
from mne.io.constants import FIFF
from mne.transforms import rotation, Transform, write_trans
from mne.utils import get_subjects_dir

from braindyn.utils.mne.bem import make_bem_model, make_bem_solution
from braindyn.utils.mne.source_space import setup_source_space
from braindyn.utils.mne.viz import plot_alignment


def create_bem_surfaces(subject, subjects_dir=None, plot=False):
    """Create subject-specific BEM surfaces for forward model computation

    Parameters
    ----------
    subject : str
        Subject to process.
    subjects_dir : string, or None
        Path to SUBJECTS_DIR if it is not set in the environment.
    plot: bool
        Plot created surfaces

    Returns
    -------

    # TODO: these BEM surfaces don't look too good - we need to figure out a way to create higher precision surfaces
    """
    subjects_dir = get_subjects_dir(subjects_dir, raise_error=True)

    _create_bem_surfaces(subject, subjects_dir)

    if plot:
        mne.viz.plot_bem(subject=subject, subjects_dir=subjects_dir,
                         brain_surfaces='white', orientation='coronal')


def _create_bem_surfaces(subject, subjects_dir):
    subprocess.call(["mne", "watershed_bem", "-s", subject, "-d", subjects_dir])

    subprocess.call(["mne", "flash_bem", "-s", subject, "-d", subjects_dir])


def coregister(subject, nas, lpa, rpa, data_file, subjects_dir=None, plot=False):
    """Coregister MEG fiducial coordinates to MRI fiducials

        Parameters
        ----------
        subject : str
            Subject to process.
        nas: list of float
            3-dimensional coordinate of the nasion fiducial (in MRI-space)
        lpa: list of float
            3-dimensional coordinate of the LPA fiducial (in MRI-space)
        rpa: list of float
            3-dimensional coordinate of the RPA fiducial (in MRI-space)
        data_file: str
            filename of raw data containing MEG fiducials
        subjects_dir : string, or None
            Path to SUBJECTS_DIR if it is not set in the environment.

        Returns
        -------
        trans : instance of Transform
            Transformation from head (MEG) coordinates to MRI coordinates
    """
    if len(nas) != 3:
        raise ValueError('NAS coordinate must be three dimensional.')
    if len(lpa) != 3:
        raise ValueError('LPA coordinate must be three dimensional.')
    if len(rpa) != 3:
        raise ValueError('RPA coordinate must be three dimensional.')

    subjects_dir = get_subjects_dir(subjects_dir, raise_error=True)

    trans = _coregister(subject, nas, lpa, rpa, data_file, subjects_dir)

    if plot:
        raw = mne.io.read_raw_fif(data_file)

        plot_alignment(raw.info, trans=trans, subject=subject, subjects_dir=subjects_dir,
                       scalp_surfaces='outer_skin.surf.gii',
                       show_axes=True, dig=True, eeg=[], meg='sensors', coord_frame='meg')
        mlab.view(45, 90, distance=0.6, focalpoint=(0., 0., 0.))


def _coregister(subject, nas, lpa, rpa, data_file, subjects_dir):
    # Read MEG based fiducials
    hsp = mne.channels.read_dig_montage(fif=data_file)

    # MRI fiducial coords
    scale = 0.001
    lpa = np.array(lpa) * scale
    nas = np.array(nas) * scale
    rpa = np.array(rpa) * scale

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
    fname = os.path.join(subjects_dir, subject, 'bem', '%s-fiducials.fif' % subject)
    write_fiducials(fname, dig, FIFF.FIFFV_COORD_MRI)

    # Fit points
    n_scale_params = 0
    parameters = [0, 0, 0, 0, 0, 0, 1, 1, 1]
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

    # Compute transformation
    head_mri_t = rotation(*parameters[:3]).T
    head_mri_t[:3, 3] = -np.dot(head_mri_t[:3, :3], parameters[3:6])
    trans = Transform('head', 'mri', head_mri_t)

    # Write transformation to file
    (raw_dir, raw_file) = os.path.split(data_file)
    trans_fname = os.path.join(raw_dir, '%s-trans.fif' % (os.path.splitext(raw_file)[0]))
    write_trans(trans_fname, trans)

    return trans


def forward_model(subject, data_file, trans, source_space_surface='white.gii', inner_skull_surf='inner_skull.surf.gii',
                  outer_skull_surf='outer_skull.surf.gii', outer_skin_surf='outer_skin.surf.gii', out_fname=None,
                  subjects_dir=None, plot=False):
    """Compute forward model

        Parameters
        ----------
        subject : str
            Subject to process.
        data_file: str
            filename of data to compute forward model for
        trans : instance of Transform
            Transformation from head (MEG) coordinates to MRI coordinates
        source_space_surface : str
            Filename of the surface to use to create the source space. Default is white.gii
        inner_skull_surf : str
            Filename of the inner skull surface. Default is inner_skull.surf.gii
        outer_skull_surf : str
            Filename of the outer skull surface. Default is outer_skull.surf.gii
        outer_skin_surf : str
            Filename of the outer skin surface. Default is outer_skin.surf.gii
        out_fname : str or None
             Filename to write forward solution to (if not None)
        subjects_dir : string, or None
            Path to SUBJECTS_DIR if it is not set in the environment.

        Returns
        -------
        (bme, src, fwd) : tuple - instance of BEMSolution, instance of Forward, and instance of Source Space
            The BEM solution, source space, and forward solution.
    """

    subjects_dir = get_subjects_dir(subjects_dir, raise_error=True)

    (bem, src, fwd) = _forward(subject, data_file, trans, source_space_surface, inner_skull_surf, outer_skull_surf,
                               outer_skin_surf,
                               subjects_dir)

    if plot:
        src.plot(subjects_dir=subjects_dir)
        mlab.show()

    print(fwd)
    if out_fname is not None:
        mne.write_forward_solution(out_fname, fwd, overwrite=True)

    return (bem, src, fwd)


def _forward(subject, data_file, trans, source_space_surface, inner_skull_surf, outer_skull_surf, outer_skin_surf,
             subjects_dir):
    src = setup_source_space(subject, spacing='oct6', surface=source_space_surface, subjects_dir=subjects_dir,
                             add_dist=False)

    conductivity = (0.3,)  # for single layer
    # conductivity = (0.3, 0.006, 0.3)  # for three layers
    model = make_bem_model(subject=subject, ico=4, inner_skull_surf=inner_skull_surf,
                           outer_skull_surf=outer_skull_surf, outer_skin_surf=outer_skin_surf,
                           conductivity=conductivity, subjects_dir=subjects_dir)
    bem = make_bem_solution(model)
    fwd = mne.make_forward_solution(data_file, trans=trans, src=src, bem=bem,
                                    meg=True, eeg=False, mindist=5.0, n_jobs=2)
    return bem, src, fwd


if __name__ == '__main__':
    subj_id = 'gb070167-synth'
    subjects_dir = '/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167'
    data_file = '/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/gb070167_1_raw.fif'
    nas = [9.9898, 142.5147, -8.1787]
    lpa = [-55.7659, 49.4636, -26.2089]
    rpa = [88.7153, 62.4787, -29.1394]
    # create_bem_surfaces('gb070167-synth','/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167')
    trans = coregister(subj_id, nas, lpa, rpa, data_file, subjects_dir=subjects_dir, plot=True)
    forward_model(subj_id, data_file, trans,
                  out_fname='/home/bonaiuto/Dropbox/Projects/inProgress/braindyn/data/gb070167/gb070167-fwd.fif',
                  subjects_dir=subjects_dir, plot=True)
