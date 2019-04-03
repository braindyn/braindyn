# segment anatomical MRI using freesurfer

import json
import os
import sys

from nipype.interfaces.freesurfer import ReconAll


def recon_all(subject):
    # open config.json and extract data
    with open(os.path.dirname(os.path.abspath(__file__)) + '/../../../config.json') as json_data_file:
        paths = json.load(json_data_file)

    # configure paths
    raw_data_dir = paths['paths']['rawData']
    subject_data_dir = paths['paths']['processedData']
    T1file = raw_data_dir + '/' + subject + '/niftis/t1/T1.nii.gz'

    # setup freesurfer reconstruction
    reconall = ReconAll()
    reconall.inputs.subject_id = '0_freesurfer'
    reconall.inputs.directive = 'all'
    reconall.inputs.subjects_dir = subject_data_dir + '/' + subject
    reconall.inputs.T1_files = T1file

    # run command in command line
    os.system(reconall.cmdline)


def main():
    # if no input argument was provided use subject S1
    if len(sys.argv) < 1:
        subject = 'S1'
    else:
        subject = sys.argv[1]

    recon_all(subject)


if __name__ == "__main__":
    main()