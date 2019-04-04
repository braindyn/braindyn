# functions related to process eyeLink data

import numpy as np
import re


# main function to convert eye link events into a dictionary
def extract_events(path_to_file, tags, ref_sample, eye_link_sample_freq=1000, new_sample_freq=1000):
    """Process raw eye link data from .asc file and return dictionary containing the relevant info. The data will be
        loaded, events will be extracted and if specified will be resampled.

    Parameters
    ----------
    path_to_file: string
        Absolute path to .asc file

    tags: dict
        Definition of relationship between key value in result dictionary and naming in the .asc file. The value
        has to be a list, of which entry to look for and how many columns the data matrix that will be extracted
        will have.

    ref_sample: list
        Contains 3 elements. 1) key value where triggers are stored, 2) reference trigger value, 3) sample
        number at this point.

    eye_link_sample_freq: int
        Sample frequency of data recorded.

    new_sample_freq: int
        Sample frequency of output data.
    """

    return _resample_tags(_search_for_tags_in_raw_data(tags, _read_raw_eye_link_data(path_to_file)),
                          eye_link_sample_freq, new_sample_freq, ref_sample)


# resample data according to user specifications
def _resample_tags(eye_data,sample_freq, new_sample_freq, ref_sample):

    # find relation between sampling rates
    multiplicand = new_sample_freq / sample_freq

    eventval_first_sample = ref_sample[1]
    value_first_sample = ref_sample[2]

    # find index of trigger value corresponding to first sample
    index_first_sample = [ind for ind, val in enumerate(eye_data[ref_sample[0]][:,1]) if val == eventval_first_sample]

    # setup sample shift
    resample_val = eye_data[ref_sample[0]][index_first_sample[0], 0] * multiplicand - value_first_sample

    # resample data
    for key in eye_data.keys():
        eye_data[key][:, 0] = eye_data[key][:, 0] * multiplicand
        eye_data[key][:, 0] = eye_data[key][:, 0] - resample_val

        # because some have a begin and end sample which also needs to be resampled
        if eye_data[key].shape[1] > 2:
            eye_data[key][:, 1] = eye_data[key][:, 1] * multiplicand
            eye_data[key][:, 1] = eye_data[key][:, 1] - resample_val

        # add sample frequency info
    eye_data['samplefreq'] = new_sample_freq

    return eye_data


# reads raw ASCII coded file
def _read_raw_eye_link_data(path_to_asc):
    with open(path_to_asc) as eye_data_file:
        eye_data_raw = eye_data_file.read()

    eye_data_file.close()
    return eye_data_raw


# searches for specific tags in the data (e.g. 'ESACC')
def _search_for_tags_in_raw_data(tags, raw_data):

    # initialize results
    eye_data = dict()

    # iterate through dictionary of search phrases and initialize results matrices according to specifications
    for key, value in tags.items():
        eye_data[key] = np.empty((0, value[1]), dtype=float)

    # iterate through raw data file line by line
    for line in raw_data.strip().split('\r\n'):

        # for each line check if a search phrase is present
        for key in tags.keys():

            # if the search phrase was present assign values to results dictionary
            # further if left and right was specified, give the value 0 to 'L' and 1 to 'R'
            if re.compile(tags[key][0]).search(line):

                # find all ineger and float numbers
                line_data = map(float, re.findall(r'\d+\.?\d*', line))

                # if left and right was specified in that line (excepts trigger lines) add 0 or 1 for 'L' or 'R'
                if re.findall(tags[key][0] + ' [L|R]', line):
                    line_data = line_data + [float(0 if re.findall(tags[key][0] + ' [L|R]', line)[0].split()[1] == 'L'
                                                   else 1)]

                eye_data[key] = np.append(eye_data[key], np.array([line_data]), axis=0)

    return eye_data
