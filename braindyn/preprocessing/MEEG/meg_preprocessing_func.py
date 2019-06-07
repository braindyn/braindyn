## Preprocessing functions

import numpy as np
import mne
from copy import deepcopy
from meg_preprocessing_param_json import *

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



def annotation_bad(raw, annot_blinks=True, eog_ch_name=eog_ch_name, blink_onset_time=0.25, blink_dur=0.5):

    annotated_bad_raw = raw.copy()

    #create 'bad segment' annotation label for manual inspection, by create short bad segment at onset of recording
    annot_bad = mne.Annotations([0], [0.1], ['bad segment'],orig_time=raw.info['meas_date'])

    if annot_blinks: #annotate blinks in raw data 

        # find blinks
        eog_events = mne.preprocessing.find_eog_events(raw,ch_name=eog_ch_name)
        n_blinks = len(eog_events)

        # Turn blink events into Annotations of 0.5 seconds duration,
        # each centered on the blink event:
        onset = eog_events[:, 0] / raw.info['sfreq'] - blink_onset_time
        duration = np.repeat(blink_dur, n_blinks)
        description = ['bad blink'] * n_blinks
        annot_bad.append(onset, duration, description)

    annotated_bad_raw.set_annotations(annot_bad)
    return annotated_bad_raw


# epoch data according to events of interest (in event_id), with no automatic rejection
def epoching(raw, picks, event_id, tmin, tmax, baseline, bad_ch_list, stim_ch_name):

    # mark already known bad channels
    raw.info['bads'] = bad_ch_list 

    # find all events in recorded data
    events = mne.find_events(raw, stim_channel=stim_ch_name)

    # epoch data and reject epochs containing bad annotated segments
    epochs = mne.Epochs(raw, events, event_id, tmin, tmax, picks=picks, baseline=baseline, reject_by_annotation=True)  
    
    # remove bad data in epochs_good dataset
    epochs_good = epochs.copy()
    epochs_good.drop_bad()
    
    # create list of bad rejected epochs after selection
    epochs_before_selection = epochs.selection     #epochs before manual rejection
    epochs_after_selection = epochs_good.selection     #epochs after manual rejection
    
    bad_trials= list(set(epochs_before_selection)-set(epochs_after_selection)) #create an array with bad trials 
    idx_epochs_reject=np.zeros(len(bad_trials))                #precompute array
    for idx_trial in range(len(bad_trials)):
        temp=bad_trials[idx_trial]
        temp2=np.where(epochs_before_selection==temp)
        idx_epochs_reject[idx_trial]=temp2[0] 

    return epochs_good,idx_epochs_reject



