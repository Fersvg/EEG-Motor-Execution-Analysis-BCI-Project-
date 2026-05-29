function [data_ep, labels, time, EEG_ep] = epoch_MRCP(EEG, params)

% Segment EEG into trials for MRCP

event_types = [EEG.event.type];

EEG.event = EEG.event(ismember(event_types, params.classes));

EEG = eeg_checkset(EEG,'eventconsistency');

EEG_ep = pop_epoch(EEG, num2cell(params.classes), [params.tmin params.tmax]);

% Baseline before brain response
EEG_ep = pop_rmbase(EEG_ep, [-2300 -2050]);

data_ep = permute(EEG_ep.data, [3 1 2]); % [trials x channels x time]

labels = [EEG_ep.event.type];

time = EEG_ep.times / 1000;

end
