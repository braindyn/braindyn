##Time Frequency constants for pilot data
"""
In this script we can find constants needed for Time Frequency analysis:
"""
import numpy as np
import mne
###############################################################################
### PATHS
###############################################################################
#My path
data_path = '/home/maxime/data/MEG/max_20190401/'

###############################################################################
### Frenquencies
###############################################################################
#frequencies of interest
## Low freqs
fmin1 = 3
fmax1 = 41
step1 = 1
freqs1 = np.arange(fmin1,fmax1,step1)
n_cycles1 =  3. # different number of cycle per frequency

## High freqs
fmin2 = 40
fmax2 = 100
step2 = 2
freqs2 = np.arange(fmin2,fmax2,step2)
n_cycles2 = 5. # different number of cycle per frequency

###############################################################################
### EPOCHS
###############################################################################
return_itc_epochs=True
#Choose your method for the trf analysis on epochs:

method_epochs ='morlet' # morlet , multitaper , stockwell

#tfr_morlet
if method_epochs == 'morlet':
    use_fft_epochs=False
    average_epochs=True
    time_bandwidth_epochs = None
    width_epochs = None
#tfr_multitaper
if method_epochs == 'multitaper':
    use_fft_epochs=True
    average_epochs=True
    time_bandwidth_epochs = 2.
    width_epochs = None
#tfr_stockwell
if method_epochs == 'stockwell':
    use_fft_epochs=None
    average_epochs=None
    width_epochs = 1
    time_bandwidth_epochs = None
    ###############################################################################
### EVOKED
###############################################################################
return_itc_evokeds=False
average_evokeds =True 

#Choose your method for the trf analysis on epochs:

method_evokeds ='morlet' #morlet,multitaper , stockwell

#tfr_morlet
if method_evokeds == 'morlet':
    use_fft_evokeds=False
    average_evokeds=True
    time_bandwidth_evokeds = None
    width_evokeds = None
#tfr_multitaper
if method_evokeds == 'multitaper':
    use_fft_evokeds=True
    average_evokeds=True
    time_bandwidth_evokeds = 2.
    width_evokeds = None
#tfr_stockwell
if method_evokeds == 'stockwell':
    use_fft_evokeds=None
    average_evokeds=None
    width_evokeds = 1
    time_bandwidth_evokeds = None