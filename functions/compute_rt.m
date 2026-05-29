function rt = compute_rt(events, EEG_ep, fs)

% Compute reaction time (RT) aligned with epoched trials

event_types = events(:, 1);
stim  = events(:, 2);
onset = events(:, 3);

n_trials = length(EEG_ep.event);
rt = zeros(1, n_trials);

for i = 1:n_trials
    
    % Trial information from epoched EEG

    type = EEG_ep.event(i).type;
    latency = round(EEG_ep.event(i).latency);
    
    % Find candidate events with matching type
    candidates = find(event_types == type);
    
    % Select the closest event in time
    [~, best_idx] = min(abs(onset(candidates) - latency));
    
    % Get corresponding index in events table
    idx = candidates(best_idx);
    
    % Compute RT in seconds (onset - stimulus)
    rt(i) = (onset(idx) - stim(idx)) / fs;
    
end

end