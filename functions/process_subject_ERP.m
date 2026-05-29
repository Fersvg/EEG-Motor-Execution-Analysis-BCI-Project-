function results = process_subject_ERP(subj)

% Full EEG ERP pipeline for one subject
% Outputs:
%   results.ERP_subject
%   results.bad_channels_all
%   results.good_trials_matrix_all
%   results.class_labels_all
%   results.time

params = get_params_ERP();

n_runs = params.n_runs;
n_classes = params.n_classes;

bad_channels_all = cell(1, n_runs);
good_trials_matrix_all = cell(1, n_runs);
class_labels_all = cell(1, n_runs);
ERP_runs = cell(n_classes, 1);

fprintf('Processing subject %d...\n', subj);

for run = params.runs
   
    fprintf('Run %d...\n', run);
    
    % Load
    [data, events, chanlocs] = load_run_data(subj, run);
    
    % Detrend + Notch(50 Hz) + Bandpass(0.3 - 70 Hz) + Bad channels detection + CAR
    [data,bad_channels] = preprocess(data, params.fs);
    bad_channels_all{run} = bad_channels;
    
    % Build egglab stimulus onset
    EEG = build_eeglab_stim(data, events, chanlocs, params.fs);
    
    % ICA
    EEG = run_ica(EEG);
    
    % Interpolate bad channels
    EEG = interpolate(EEG, chanlocs);
    
    % Epoching
    [data_ep, labels, time, EEG_ep] = epoch_data(EEG, params);
    class_labels_all{run} = labels;
    
    % Compute response time
    rt = compute_rt(events, EEG_ep, params.fs);
    
    % Trial rejection
    [good_matrix,data_ep_good] = trial_rejection(data_ep, labels, rt);
    good_trials_matrix_all{run} = good_matrix;
    
    % Accumulate trials by movement
    ERP_runs = accumulate_trials(ERP_runs, data_ep_good, labels, params.classes, n_classes);
    
end

% ERP per movement in Cz channel

n_time = size(ERP_runs{1}, 3);

ERP_subject = nan(n_classes, n_time);

cz = 30;

for c = 1:n_classes
    
    data = ERP_runs{c}; 
    
    Cz_trials = squeeze(data(:, cz, :));
    
    ERP_subject(c, :) = mean(Cz_trials, 1, 'omitnan');
    
end

% Output
results.ERP_subject = ERP_subject;
results.bad_channels_all = bad_channels_all;
results.good_trials_matrix_all = good_trials_matrix_all;
results.class_labels_all = class_labels_all;
results.time = time;

fprintf('Subject %d done\n', subj);

end
