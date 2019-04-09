
##Preprocessing parameters 

"""
In this script we can find constants needed for MEG preprocessing:
"""

import numpy as np

###############################################################################
### PATHS
###############################################################################

data_path = '/Users/annkos/braindyn/'
raw_fname = data_path + 'max_flicker_20190401_01.ds'

###############################################################################
### FILTERING AND DECIMATION CONSTANTS
###############################################################################

fir_design='firwin' #filter type

#low, high, band pass filtering
h_freq = None #Hz # high frequency cut-off, None if high-pass filtering
l_freq = 1.#Hz # low frequency cut-off, None if low-pass filtering

# Notch Filter 
freqs= None #np.arange(50, 301, 50) # for Notch Filter only, here for freqs from 50 to 300 by 50 steps (all in Hz)
filter_length='auto'
phase='zero'

# Downsampling and decimation
sfreq =600 #Hz
npad="auto"

###############################################################################
### EPOCHING PARAMETERS
###############################################################################

event_id = {"flickera": 101,"flickerb": 102,"flickerc": 103, "flickerd": 104,"flickere": 105, "flickerf": 106} #name and trigger of events of interest
tmin = -0.5  # start of each epoch 
tmax = 5.5  # end of each epoch 
baseline = (None, 0)  # means from the first instant to t = 0

###############################################################################
### CHANNELS, EPOCHS, AND ARTEFACTS REJECTION PARAMETERS
###############################################################################

# channel names
eog_ch_name = 'EOGV' # channel to use for blink detection
ecg_ch_name = 'ECG' # channel to use for cardiac artefact detection
stim_ch_name = 'UPPT002' # trigger channel 
extstim_ch_name = 'ADC001.2800' # channel where external stimulation is recorded (e.g. photodiode, sound) 

# bad channels
bad_ch_list = [] # list of bad channels to be excluded

# automatic rejection
reject = dict(mag=4000e-13, eog=150e-6)  # None if no automatic rejection

