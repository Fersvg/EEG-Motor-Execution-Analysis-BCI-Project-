clear; clc;

%% GET PARAMETERS

params = get_params_MRCP();

subjects    = params.subjects;
n_subjects  = params.n_subjects;
n_classes   = params.n_classes;

movement_names = {'Elbow Flex', 'Elbow Ext', 'Supination', 'Pronation', 'Close Hand', 'Open Hand', 'Rest'};

%% INITIALIZATION

MRCP_all     = cell(n_subjects, n_classes);
MRCP_Cz_all  = [];

%% OPEN EEGLAB

eeglab

%% CREATE FOLDERS

if ~exist('MRCP Inter-subject variability', 'dir')

    mkdir('MRCP Inter-subject variability');

end

if ~exist('MRCP GrandMean', 'dir')

    mkdir('MRCP GrandMean');

end

if ~exist('MRCP Topograms', 'dir')

    mkdir('MRCP Topograms');
    
end

%% LOAD / PROCESS SUBJECTS

fprintf('Processing all subjects...\n');

for s = 1:n_subjects

    subj = subjects(s);

    filename = sprintf('results_MRCP_S%02d.mat', subj);

    % Load
    if exist(filename, 'file')

        load(filename, 'results');

    else

        % Process
        results = process_subject_MRCP(subj);

        save(filename, 'results');

    end

    R = results;

    if s == 1

        % Time vector
        time = R.time;

        % Initialization MRCP_Cz_all
        MRCP_Cz_all = nan(n_subjects, n_classes, length(time));

    end

    for c = 1:n_classes

        MRCP_all{s, c} = R.MRCP_Topo{c};

        MRCP_Cz_all(s, c, :) = R.MRCP_Cz(c, :);

    end

end

%% D4: Cz Curve (INTER-SUBJECT VARIABILITY + GRAND MEAN)

for c = 1:n_classes
   
    Cz_all = squeeze(MRCP_Cz_all(:, c, :));

    legend_entries = {};

    % Inter-subject variability
    fprintf('\n D4: Cz Curve (INTER-SUBJECT VARIABILITY) \n');

    figure;

    hold on;

    set(gcf, 'color', 'w');

    for s = 1:n_subjects
        
        Cz_signal = Cz_all(s, :);
        
        plot(time, Cz_signal, 'LineWidth', 1.2);

        legend_entries{end+1} = sprintf('Sujeto %d', subjects(s));

    end

    xlabel('Time (s)');
    ylabel('Amplitude (\muV)');

    title(sprintf('MRCP Cz - Inter-subject variability - %s', movement_names{c}));

    legend(legend_entries, 'Location', 'best');

    grid on;
    
    saveas(gcf, fullfile('MRCP Inter-subject variability', sprintf('MRCP_Cz_InterSubject_%s.png', movement_names{c})));

    close(gcf);
    
    % Grand Mean
    fprintf('\n D4: Cz Curve (GRAND MEAN) \n');

    grand_mean = mean(Cz_all, 1, 'omitnan');
    
    figure;
    
    set(gcf, 'color', 'w');

    plot(time, grand_mean, 'LineWidth', 2);

    xlabel('Time (s)');
    ylabel('Amplitude (\muV)');

    title(sprintf('MRCP Cz - Grand Mean - %s', movement_names{c}));

    grid on;

    saveas(gcf, fullfile('MRCP GrandMean', sprintf('MRCP_Cz_GrandMean_%s.png', movement_names{c})));

    close(gcf);

end

%% D5: TOPOGRAMS

fprintf('\n D5: Topograms \n');

grand_topos = cell(1, n_classes);

for c = 1:n_classes
    
    % Pre-movement Minimum Peak

    pre_idx = find(time < 0);

    [~, idx] = min(grand_mean(pre_idx));

    peak_idx = pre_idx(idx);

    t_peak   = time(peak_idx);
    
    % window (-100 ms - 100 ms)
    win_idx = find(time >= t_peak - 0.1 & time <= t_peak + 0.1);
    
    % Topo per Subject

    all_topo = [];
    
    for s = 1:n_subjects
        
        topo = MRCP_all{s, c};  
        
        topo = mean(topo(:, win_idx), 2, 'omitnan');
        
        all_topo(:, end+1) = topo;

    end
    
    grand_topos{c} = -median(all_topo, 2, 'omitnan');

end

% Global Scale

all_vals = cell2mat(grand_topos');

max_val = prctile(all_vals, 95);

% Plot Topograms

for c = 1:n_classes

    figure;

    topo = grand_topos{c};

    topo = fillmissing(topo, 'constant', 0);

    topoplot(topo, 'loc61eeg.ced', 'electrodes', 'on', 'numcontour', 0, 'gridscale', 150);

    colormap(flipud(hot));

    colorbar;

    clim([0 max_val]);

    set(gcf, 'color', 'w');

    title(sprintf('Topoplot MRCP - %s', movement_names{c}));

    saveas(gcf, fullfile('MRCP Topograms', sprintf('MRCP_Topoplot_%s.png', movement_names{c})));

    close(gcf);

end