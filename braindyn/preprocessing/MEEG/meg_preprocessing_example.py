'''
This script lists the preprocessing steps

1.Filter and downsampling
    - apply lowpass, hipass, bandpass or noth filtering to raw data
    - downsample raw data

2. Epoching and Channel, Epoch/ Artefact rejection
'''

import mne

# load preprocessing functions 
from meg_preprocessing_func import * 

# load constants specific to participant 
from meg_preprocessing_param_json import * 

#### 0
# load data
# -------------------------------------------------
raw = mne.io.read_raw_ctf(raw_fname, preload=True)

#### 1
# band-pass filter MEG data at l_freq and h_freq (here high_pass filter at 1 Hz to remove slow drifts)
# -------------------------------------------------
#picks_meg = mne.pick_types(raw.info, meg = True)
#raw = filtering(raw, picks_meg, l_freq=l_freq, h_freq=h_freq)

# downsample data to sfreq
# -------------------------------------------------
#raw = downsampling(raw,sfreq,npad)

#### 2
# epoching data (with rejection of known bad channels) 
# -------------------------------------------------
picks = mne.pick_types(raw.info, meg=True, eeg=True, exclude='bads') # bad channels will be excluded in next step
epochs = epoching(raw, picks, event_id, tmin, tmax, baseline, bad_ch_list, stim_ch_name)

# manual epochs rejection
# -------------------------------------------------
idx_epochs_reject, epochs_reject = visual_epoch_reject(epochs,eog_ch_name, n_epochs=10,n_channels=50)