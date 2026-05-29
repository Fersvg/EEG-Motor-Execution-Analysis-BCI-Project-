function results = process_subject_MRCP(subj)

% Full EEG MRCP pipeline for one subject
% Outputs:
%   results.MRCP_Cz
%   results.MRCP_Topo
%   results.time

params = get_params_MRCP();

MRCP_runs = cell(params.n_classes,1);

fprintf('Processing subject %d...\n', subj);

for run = params.runs

    fprintf('Run %d...\n', run);
    
    %Load data
    [data, events, chanlocs] = load_run_data(subj, run);
    
    % Detrend + Notch(50 Hz) + Bandpass(0.3 - 70 Hz) + Bad channels detection + CAR
    data = preprocess(data, params.fs);
    
    % Build eeglab movement onset
    EEG = build_eeglab_mov(data, events, chanlocs, params.fs);

    % ICA
    EEG = run_ica(EEG);

    % Interpolate bad channels
    EEG = interpolate(EEG, chanlocs);
    
    % Decimation
    [data, events] = decimate_data(EEG.data, events, params);
    
    % Bandpass (0.3 - 3 Hz)
    data = filter_MRCP(data, params.fs_new);
    
    % Build eeglab movement onset
    EEG = build_eeglab_mov(data, events, chanlocs, params.fs_new);
    
    % Epoching
    [data_ep, labels, time, EEG_ep] = epoch_MRCP(EEG, params);
    
    % Compute response time
    rt = compute_rt(events, EEG_ep, params.fs_new);
    
    % Trial rejection
    [~, data_ep_good] = trial_rejection(data_ep, labels, rt);

    % Accumulate trials by movement
    MRCP_runs = accumulate_trials(MRCP_runs, data_ep_good, labels, params.classes, params.n_classes);
    
    % MRCP per subject

    n_time = size(MRCP_runs{1}, 3);

    MRCP_subject = nan(params.n_classes, n_time);   
    MRCP_full = cell(params.n_classes, 1);          

    cz = 30;

    for c = 1:params.n_classes
    
        data = MRCP_runs{c}; 
    
        % All channels (Topogram)
        MRCP_full{c} = squeeze(mean(data, 1, 'omitnan'));  
    
        % Cz channel (Cz curve)
        Cz_trials = squeeze(data(:, cz, :));              
        MRCP_subject(c,:) = mean(Cz_trials, 1, 'omitnan');
    
    end
end

% Output
results.MRCP_Cz = MRCP_subject;
results.MRCP_Topo = MRCP_full;
results.time = time;

fprintf('Subject %d done\n', subj);

end
