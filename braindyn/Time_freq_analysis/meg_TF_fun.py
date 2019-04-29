"""
Time Frequency analysis functions
"""

import numpy as np
import mne

from meg_TF_param_json import * 

###############################################################################
# Time-frequency analysis: power and inter-trial coherence
# --------------------------------------------------------

def freq_analysis (epochs,freqs,n_cycles,use_fft,return_itc,average,time_bandwidth,width,method_epochs,fmin,fmax):
       if method_epochs == 'morlet':
              power, itc = mne.time_frequency.tfr_morlet(epochs, freqs, n_cycles, use_fft,
                        return_itc, average)

       if method_epochs == 'multitaper':
              power, itc = mne.time_frequency.tfr_multitaper(epochs, freqs, n_cycles, use_fft,
                        return_itc, average,time_bandwidth)

       if method_epochs == 'stockwell':
              power, itc = mne.time_frequency.tfr_stockwell(epochs, return_itc,width,fmin,fmax)

       return power ,itc    

## define evoked responses
def get_evokeds(epochs):
       epochs = mne.read_epochs(data_path + 'epochs_data.ds')
       evokeds = []
       for trial_type in epochs.event_id:
              evokeds.append(epochs[trial_type].average())
       return evokeds       


def evoked_freq_analysis(evokeds,l_freqs,l_n_cycles,use_fft_evokeds,return_itc_evokeds,average_evokeds,time_bandwidth_evokeds,width_evokeds,method_evokeds,l_fmin,l_fmax):
       el_power=[]
       if method_evokeds == 'morlet':
              for evoked in evokeds:  
                     l = mne.time_frequency.tfr_morlet(evoked, freqs=l_freqs, n_cycles=l_n_cycles, use_fft=use_fft_evokeds,
                        return_itc=return_itc_evokeds, average = average_evokeds)
                     el_power.append(l)
       if method_evokeds == 'multitaper':
              for evoked in evokeds:  
                     l = mne.time_frequency.tfr_multitaper(evoked, freqs=l_freqs, n_cycles=l_n_cycles, use_fft=use_fft_evokeds,
                        return_itc=return_itc_evokeds,  average = average_evokeds,time_bandwidth=time_bandwidth_evokeds)
                     el_power.append(l)
       if method_evokeds == 'stockwell':
              for evoked in evokeds:  
                     l = mne.time_frequency.tfr_stockwell(evoked, return_itc=return_itc_evokeds,width= width_evokeds,fmin=l_fmin,fmax=l_fmax)
                     el_power.append(l)
       return el_power

