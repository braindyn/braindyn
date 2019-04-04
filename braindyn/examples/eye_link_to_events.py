# Example on how to extract eye link eye tracking data and create an event structure

import numpy as np
from braindyn.preprocessing.eyetracking import extract_events
from braindyn.data import example_data

# specify path to file
path_to_asc_file = example_data.get_path() + '/eye_tracking_data.asc'

# define search phrases and output dictionary names + number of columns
search_for = {'fixation':['EFIX', 7],'saccade':['ESACC', 10],'blink':['EBLINK', 4],'trigger':['MSG.*LED.*', 2],
              'recording':['MSG.*Start.*Rec.*', 1]}

# extract data
eye_data = extract_events(path_to_asc_file, search_for, ['trigger', 252, 0], new_sample_freq=1200)

# make event file for blinks
event_id={'b_onset': 0, 'b_offset': 1}

# create event file by concatenating blink on and offset samples
events = np.zeros((eye_data['blink'].shape[0] * 2, 3),dtype=int)
events[:, 0] = np.concatenate((eye_data['blink'][:, 0], eye_data['blink'][:, 1]))
events[:, 2] = np.concatenate((np.ones((eye_data['blink'].shape[0],)) * event_id[ 'b_onset'],
                               np.ones((eye_data['blink'].shape[0],)) * event_id[ 'b_offset']))

# sort along first column (sample values)
events = events[events[:, 0].argsort(),:]

print events