## Preprocessing functions

import numpy as np
import mne
from copy import deepcopy

# filter raw data 
def filtering(raw, picks_meg, h_freq=None, l_freq=None, freqs=None, fir_design='firwin',filter_length='auto',phase='zero'):

    # Removing power-line noise with notch filtering
    # ----------------------------------------------
    if freqs is None:
        pass
    else:
        raw.notch_filter(freqs, picks=picks_meg, filter_length=filter_length, phase=phase)

    # Removing power-line noise with low-pass filtering
    # -------------------------------------------------
    if h_freq is None:
        pass
    else:
        raw.filter(None,h_freq, fir_design=fir_design)

    # High-pass filtering to remove slow drifts
    # -----------------------------------------
    if l_freq is None:
        pass
    else:
        raw.filter(l_freq, None , fir_design=fir_design)
    return raw


def downsampling(raw, sfreq, npad):
    # Downsampling and decimation
    # -----------------------------------------
    if sfreq is None:
        pass
    else:
        raw.resample(sfreq ,npad=npad)  # set sampling frequency to 100Hz
    return raw


# epoch data according to events of interest (in event_id), with no automatic rejection
def epoching(raw, picks, event_id, tmin, tmax, baseline, bad_ch_list, stim_ch_name):

    # mark already known bad channels
    raw.info['bads'] = bad_ch_list 

    # find all events in recorded data
    events = mne.find_events(raw, stim_channel=stim_ch_name)

    # epoch data with no rejection of epochs, only known bad channels are rejected
    epochs = mne.Epochs(raw, events, event_id, tmin, tmax, picks=picks, baseline=baseline, reject=None)
    return epochs


#rejection based on manual checking
def visual_epoch_reject(epochs,eog_ch_name, n_epochs=10,n_channels=50):
    
    data =epochs.get_data()

    MEG_chans = [i for i, elem in enumerate(epochs.ch_names) if 'M' in elem]
    EOG_chan = epochs.ch_names.index(eog_ch_name)

    # MEG rejection threshold = 2 * mean standard deviation of times series across channels and trials
    MEG_threshold = 2 * np.mean(np.std(data[:,MEG_chans,:],axis=2))
    # EOG rejection threshold = 2 * mean standard deviation of EOG data
    EOG_threshold = 2 * np.mean(np.std(data[:,EOG_chan,:],axis=1))

    # list of epochs with blinks
    list_epochs_blinks = np.where(np.max((data[:,EOG_chan,:]),axis=1)- np.min(data[:,EOG_chan,:],axis=1)>EOG_threshold)
    list_epochs_blinks = np.squeeze(list_epochs_blinks)
    # list of noisy epochs
    list_epochs_noisy = np.where(np.mean(np.std(data[:,MEG_chans,:],axis=2),axis=1)>MEG_threshold)
    list_epochs_noisy = np.squeeze(list_epochs_noisy)

    #create color-coded events for visualization of epochs to be rejected
    epochs_reject = deepcopy(epochs)

    event_colors ={}
    events_reject_visualize = []
    for (ev_ind, ev) in enumerate(epochs_reject.events):
        events_reject_visualize.append(ev)
        if ev_ind in list_epochs_noisy: # if noisy, mark epoch as noisy (with event code 666 500 ms post stimulus trigger)
            events_reject_visualize.append([int(ev[0]+epochs.info['sfreq']*0.5),0,666])
            event_colors.update({ 666:'red'})
            #epochs_reject.event_id.update({'bad':666})
        elif ev_ind in list_epochs_blinks: # if blink, mark epoch as blink (with event code 999 500 ms post stimulus trigger)
            events_reject_visualize.append([int(ev[0]+epochs.info['sfreq']*0.5),0,999])
            event_colors.update({999:'yellow'})
            #epochs_reject.event_id.update({'blink':999})

    epochs_reject_visualize = np.squeeze(events_reject_visualize)

    # plotting epoch data, mark each bad epoch as bad
    epochs_reject.plot(n_epochs=n_epochs, n_channels=n_channels, events=epochs_reject_visualize, event_colors=event_colors)

    # after selection of bad epochs, create list of bad epochs
    epochs_before_selection = epochs.selection     #epochs before manual rejection
    epochs_after_selection = epochs_reject.selection     #epochs before manual rejection
    
    bad_trials= list(set(epochs_before_selection)-set(epochs_after_selection)) #create an array with bad trials 
    idx_epochs_reject=np.zeros(len(bad_trials))                #precompute array
    for idx_trial in range(len(bad_trials)):
        temp=bad_trials[idx_trial]
        temp2=np.where(epochs_before_selection==temp)
        idx_epochs_reject[idx_trial]=temp2[0] 

    return idx_epochs_reject, epochs_reject