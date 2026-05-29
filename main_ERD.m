clear; clc;

%% GET PARAMETERS

params = get_params_ERD();

subjects   = params.subjects;
n_subjects =params.n_subjects;
n_classes  = params.n_classes;

movement_names = {'Elbow Flex', 'Elbow Ext', 'Supination', 'Pronation', 'Close Hand', 'Open Hand', 'Rest'};

%% OPEN EEGLAB

eeglab;

%% CREATE FOLDERS

if ~exist('ERD Topograms', 'dir')

    mkdir('ERD Topograms');

end

if ~exist('ERD ROI curves', 'dir')

    mkdir('ERD ROI curves');

end

if ~exist('ERD Inter-subject variability', 'dir')

    mkdir('ERD Inter-subject variability');
    
end

%% INITIALIZATION

ERD_mu_all   = cell(n_subjects, n_classes);
ERD_beta_all = cell(n_subjects, n_classes);

%% LOAD/PROCESS SUBJECTS

fprintf('Processing all subjects...\n');

for s = 1:n_subjects

    subj = subjects(s);

    filename = sprintf('results_ERD_S%02d.mat', subj);

    % Load
    if exist(filename, 'file')

        load(filename, 'results');

    else

        % Process
        results = process_subject_ERD(subj);

        save(filename, 'results');

    end

    % Mean between runs
    for c = 1:n_classes

        % Mu band

        ERD_mu_runs = results.ERD_mu(:, c);

        tmp = cat(3, ERD_mu_runs{:});

        ERD_mu_all{s, c} = mean(tmp, 3, 'omitnan');

        % Beta band

        ERD_beta_runs = results.ERD_beta(:, c);

        tmp = cat(3, ERD_beta_runs{:});

        ERD_beta_all{s, c} = mean(tmp, 3, 'omitnan');

    end

    % Time vector
    time = results.time;

end

%% GRAND MEAN BETWEEN SUBJECTS

grand_mu   = cell(1, n_classes);
grand_beta = cell(1, n_classes);

for c = 1:n_classes

    % Mu band
    tmp = cat(3, ERD_mu_all{:, c});

    grand_mu{c} = mean(tmp, 3, 'omitnan');

    % Beta band
    tmp = cat(3, ERD_beta_all{:, c});

    grand_beta{c} = mean(tmp, 3, 'omitnan');

end

%% ERD AROUD MOVEMENT

idx_window = (time >= -0.1 & time <= 0.1);

min_mu   = cell(1, n_classes);
min_beta = cell(1, n_classes);

for c = 1:n_classes

    ERD_mu   = grand_mu{c};
    ERD_beta = grand_beta{c};

    % Minimum ERD per channel
    min_mu{c} = min(ERD_mu(:, idx_window), [], 2);

    min_beta{c} = min(ERD_beta(:, idx_window), [], 2);

end

%% ROI (10% ELECTRODES)

ROI_mu   = cell(1, n_classes);
ROI_beta = cell(1, n_classes);

for c = 1:n_classes

    ROI_mu{c} = get_ROI(min_mu{c}, 0.1);

    ROI_beta{c} = get_ROI(min_beta{c}, 0.1);

end

%% GLOBAL TOPOGRAM SCALE

all_vals = [];

for c = 1:n_classes

    all_vals = [all_vals; min_mu{c}; min_beta{c}];

end

max_val = prctile(abs(all_vals), 95);

%% D6: ROI CURVES (GRAND MEAN)

fprintf('\n D6: ROI CURVES (GRAND MEAN) \n');

for c = 1:n_classes

    figure;

    set(gcf, 'color', 'w');

    ERD_mu   = grand_mu{c};
    ERD_beta = grand_beta{c};

    % ROI mean

    % Mu
    mu_roi = mean(ERD_mu(ROI_mu{c}, :), 1, 'omitnan');

    %Beta
    beta_roi = mean(ERD_beta(ROI_beta{c}, :), 1, 'omitnan');

    % Plots

    plot(time, mu_roi, 'b', 'LineWidth', 1.2);

    hold on;

    plot(time, beta_roi, 'r', 'LineWidth', 1.2);

    xline(0, 'k--');

    xlabel('Time (s)');
    ylabel('ERD (%)');

    ylim([-100 100]);

    % To avoid artifacts from the epoching limits
    xlim([params.tmin params.tmax - 0.5]);

    legend('Mu', 'Beta');

    title(['Grand Mean - ' movement_names{c}]);

    grid on;

    saveas(gcf,fullfile('ERD ROI curves', sprintf('ERD_GrandMean_%s.png', movement_names{c})));

    close(gcf);

end

%% D6: ROI CURVES (INTER-SUBJECT VARIABILITY)

fprintf('\n D6: ROI CURVES (INTER-SUBJECT VARIABILITY) \n');

for c = 1:n_classes

    figure;

    set(gcf, 'color', 'w');

    % Mu band

    subplot(2, 1, 1);

    hold on;

    legend_entries = {};

    for s = 1:n_subjects

        ERD_mu = ERD_mu_all{s, c};

        mu_roi = mean(ERD_mu(ROI_mu{c}, :), 1, 'omitnan');

        plot(time, mu_roi, 'LineWidth', 1.2);

        legend_entries{end + 1} = sprintf('Subject %d', subjects(s));

    end

    xline(0, 'k--');

    xlabel('Time (s)');
    ylabel('ERD Mu (%)');

    ylim([-120 120]);

    % To avoid artifacts from the epoching limits
    xlim([params.tmin params.tmax - 0.5]);

    title(['Inter-subject variability Mu - ' movement_names{c}]);

    legend(legend_entries, 'Location', 'best');

    grid on;

    % Beta band

    subplot(2, 1, 2);

    hold on;

    legend_entries = {};

    for s = 1:n_subjects

        ERD_beta = ERD_beta_all{s, c};

        beta_roi = mean(ERD_beta(ROI_beta{c}, :), 1, 'omitnan');

        plot(time, beta_roi, 'LineWidth', 1.2);

        legend_entries{end + 1} = sprintf('Subject %d', subjects(s));

    end

    xline(0, 'k--');

    xlabel('Time (s)');
    ylabel('ERD Beta (%)');

    ylim([-120 120]);

    % To avoid artifacts from the epoching limits
    xlim([params.tmin params.tmax - 0.5]);

    title(['Inter-subject variability Beta - ' movement_names{c}]);

    legend(legend_entries, 'Location', 'best');

    grid on;

    saveas(gcf, fullfile( 'ERD Inter-subject variability', sprintf('ERD_InterSubject_%s.png', movement_names{c})));

    close(gcf);

end

%% D7: TOPOGRAMS

fprintf('\n D7: TOPOGRAMS \n');

for c = 1:n_classes

    figure;

    set(gcf, 'color', 'w');

    % Mu band

    subplot(2, 1, 1);

    topo = min_mu{c};

    topo = fillmissing(topo, 'constant', 0);

    topoplot(topo, 'loc61eeg.ced', 'electrodes', 'on', 'numcontour', 0, 'gridscale', 150);

    clim([-max_val max_val]);

    title(['Topogram - Mu - ' movement_names{c}]);

    % Beta band

    subplot(2, 1, 2);

    topo = min_beta{c};

    topo = fillmissing(topo, 'constant', 0);

    topoplot(topo, 'loc61eeg.ced', 'electrodes', 'on', 'numcontour', 0, 'gridscale', 150);

    clim([-max_val max_val]);

    title(['Topogram - Beta - ' movement_names{c}]);

    colormap(jet);
    colorbar;

    saveas(gcf, fullfile('ERD Topograms', sprintf('ERD_Topograms_Mu_Beta_%s.png', movement_names{c})));

    close(gcf);

end