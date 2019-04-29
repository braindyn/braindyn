'''
This script lists the Time Frequency analysis steps
1. Analysis in epochs (morlet,multitepers or stockwell)
2. Compute evokeds (averaging of epochs)
3. Analysis in evokeds (morlet,multitepers or stockwell)
'''


import mne
import math
# load preprocessing functions 
from meg_TF_fun import * 

# load constants specific to participant 
from meg_TF_param_json import * 

#### 0
# load data
# -------------------------------------------------
epochs = mne.read_epochs(data_path + 'epochs_data.ds')

####1
## epochs time frequency
#freq band 1

l_power, l_itc = freq_analysis(epochs,freqs1,n_cycles1,use_fft_epochs,return_itc_epochs,average_epochs,time_bandwidth_epochs,width_epochs,method_epochs,fmin1,fmax2)

#freq band 2
h_power, h_itc = freq_analysis(epochs,freqs2,n_cycles2,use_fft_epochs,return_itc_epochs,average_epochs,time_bandwidth_epochs,width_epochs,method_epochs,fmin2,fmax2)

####2
## evoked responses
evokeds = get_evokeds(epochs)

####3
## evoked time frequency
#freq band 1
el_power = evoked_freq_analysis(evokeds,freqs1,n_cycles1,use_fft_evokeds,return_itc_evokeds,average_evokeds,time_bandwidth_evokeds,width_evokeds,method_evokeds,fmin1,fmax1)

#freq band 2
eh_power = evoked_freq_analysis(evokeds,freqs2,n_cycles2,use_fft_evokeds,return_itc_evokeds,average_evokeds,time_bandwidth_evokeds,width_evokeds,method_evokeds,fmin2,fmax2)