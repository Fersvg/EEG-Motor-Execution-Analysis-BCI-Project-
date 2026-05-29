function results = process_subject_ERD(subj)

% Full EEG ERD pipeline for one subject
% Outputs:
%   results.ERD_mu
%   results.ERD_beta
%   results.time

params = get_params_ERD();

n_runs = params.n_runs;
n_classes = params.n_classes;

ERD_all_mu   = cell(n_runs, n_classes);
ERD_all_beta = cell(n_runs, n_classes);

fprintf('Processing subject %d...\n', subj);

for run = params.runs
    
    fprintf('Run %d...\n', run);
    
    % Load data
    [data, events, chanlocs] = load_run_data(subj, run);
    
    % Detrend + Notch(50 Hz) + Bandpass(0.3 - 70 Hz) + Bad channels detection + CAR
    data= preprocess(data, params.fs);
    
    % Build eeglab movement onset
    EEG = build_eeglab_mov(data, events, chanlocs, params.fs);

    % ICA
    EEG = run_ica(EEG);

    % Interpolate bad channels
    EEG = interpolate(EEG, chanlocs);
    
    % Epoching
    [data_ep, labels, time, EEG_ep] = epoch_data(EEG, params);
    
    % Compute response time
    rt = compute_rt(events, EEG_ep, params.fs);

    % Band filtering: Mu band (8 - 13 Hz)
  
    [b,a] = butter(4, [8 13]/(params.fs/2), 'bandpass');

    data_ep_mu = nan(size(data_ep));

    for t = 1:size(data_ep, 1)

        for ch = 1:size(data_ep, 2)

            signal = squeeze(data_ep(t, ch, :));

            filtered = filtfilt(b, a, signal);

            data_ep_mu(t, ch, :) = reshape(filtered, 1, 1, []);

        end
    end

    % Band filtering: Beta band (13 - 30 Hz)

    [b,a] = butter(4, [13 30]/(params.fs/2),'bandpass');

    data_ep_beta = nan(size(data_ep));

    for t = 1:size(data_ep, 1)

        for ch = 1:size(data_ep, 2)

            signal = squeeze(data_ep(t, ch, :));

            filtered = filtfilt(b, a, signal);

            data_ep_beta(t, ch, :) = reshape(filtered, 1, 1, []);

        end
    end

    % Trial rejetion
    [good_matrix, ~] = trial_rejection(data_ep, labels, rt);

    % Apply trial rejection to Mu/Beta data

    data_ep_good_mu = data_ep_mu;
    data_ep_good_beta = data_ep_beta;

    for t = 1:size(data_ep, 1)
    
        bad_channels = isnan(good_matrix(t, :));
    
        data_ep_good_mu(t, bad_channels, :) = NaN;
    
        data_ep_good_beta(t, bad_channels, :) = NaN;
    
    end
    
    for c = 1:n_classes
        
        class_value = params.classes(c);
        idx = (labels == class_value);
        
        if sum(idx) == 0
            continue;
        end
        
        % Compute ERD for mu band

        data_class_mu = data_ep_good_mu(idx, :, :);

        ERD_mu = compute_ERD_pipeline(data_class_mu, params, time);
        
        % Compute ERD for beta band

        data_class_beta = data_ep_good_beta(idx, :, :);

        ERD_beta = compute_ERD_pipeline(data_class_beta, params, time);
        
        ERD_all_mu{run, c} = ERD_mu;
        ERD_all_beta{run, c} = ERD_beta;
        
    end
    
end

% Output
results.ERD_mu = ERD_all_mu;
results.ERD_beta = ERD_all_beta;
results.time = time;

fprintf('Subject %d done\n', subj);

end
