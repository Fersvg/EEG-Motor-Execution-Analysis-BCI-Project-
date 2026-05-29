function EEG = build_eeglab_stim(data, events, chanlocs, fs)

% Create EEGLAB structure (stimulus onset)

EEG = eeg_emptyset;
EEG.data = data;
EEG.srate = fs;
EEG.nbchan = size(data, 1);
EEG.pnts = size(data, 2);
EEG.trials = 1;
EEG.chanlocs = chanlocs;
EEG.event = [];

for e = 1:size(events, 1)

    % Event type
    EEG.event(e).type = events(e, 1);

    % Stimulus latency
    EEG.event(e).latency = events(e, 2);
end

EEG = eeg_checkset(EEG, 'eventconsistency');

end