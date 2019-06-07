'''
This script lists the preprocessing steps

1.(optional) Filter and downsampling
    - apply lowpass, hipass, bandpass or noth filtering to raw data
    - downsample raw data

2. Manual Artefact rejection

3.Epoching 

'''
#%matplotlib qt
import mne

# load preprocessing functions 
from meg_preprocessing_func import * 

# load constants specific to participant 
from meg_preprocessing_param_json import *

#### 0
# load data
raw = mne.io.read_raw_ctf(raw_fname, preload=False)

"""
#### 1 (optional)
# band-pass filter MEG data at l_freq and h_freq (here high_pass filter at 1 Hz to remove slow drifts)
picks_meg = mne.pick_types(raw.info, meg = True)
raw = filtering(raw, picks_meg, l_freq=l_freq, h_freq=h_freq)

# downsample data to sfreq
raw = downsampling(raw,sfreq,npad)
"""

#### 2: annotate bad channels/ artefacts

#Define epochs of interest
events = mne.find_events(raw,stim_channel=stim_ch_name)
events_select = np.squeeze([event for event in events if event[2] in event_id])

# Automatic annotation of blinks 
raw_annotated_bad = annotation_bad(raw)
# Manual inspection of annotated data: add/correct bad segments, may also manually reject bad channels
# each blue vertical line shows trigger onset of events of interest (in event_id)
# Beware, every change in the plot will be kept in raw_annotated_bad once the figure is closed !
raw_annotated_bad.plot(events=events_select)


#### 3
# epoching data (with rejection of known bad channels) 
picks = mne.pick_types(raw_annotated_bad.info, meg=True, eeg=True, exclude='bads') # bad channels will be excluded in next step
epochs, idx_epochs_reject = epoching(raw_annotated_bad, picks, event_id, epoch_tmin, epoch_tmax, baseline, bad_ch_list, stim_ch_name)

