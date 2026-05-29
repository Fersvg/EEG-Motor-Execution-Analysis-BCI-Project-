clear; clc;

%% GET PARAMETERS

params = get_params();

n_runs = params.n_runs;
subjects = params.subjects;
n_subjects = params.n_subjects;
classes = params.classes;
n_classes = params.n_classes;
fs = params.fs;

movement_names = {'Elbow Flex', 'Elbow Ext', 'Supination', 'Pronation', 'Close Hand', 'Open Hand', 'Rest'};

% FC4 FCC2h Cz CCP6h
channels_of_interest = [17 23 30 40];
channel_names = {'FC4', 'FCC2h', 'Cz', 'CCP6h'};

%% CREATE ERP GRAND MEAN FOLDER

if ~exist('ERP_GrandMean_figures', 'dir')

    mkdir('ERP_GrandMean_figures');
    
end

%% OPEN EEGLAB

eeglab

%% INITIALIZATION

bad_channels_all_total = cell(n_subjects, n_runs);
good_trials_matrix_total = cell(n_subjects, n_runs);
class_labels_total = cell(n_subjects, n_runs);


%% LOAD/PROCESS SUBJECTS

fprintf('Processing all subjects...\n');

for s = 1:n_subjects

    subj = subjects(s);

    filename = sprintf('results_ERP_S%02d.mat', subj);
    
    % Load
    if exist(filename, 'file')

        load(filename, 'results');

    else

        % Process
        results = process_subject_ERP(subj);

        save(filename, 'results');

    end
 
    R = results;

    if s == 1

        % Time vector
        time = R.time;

        % Initialization ERP_subject_all
        ERP_subject_all = nan(n_subjects, n_classes, length(time));

    end
    
    ERP_subject_all(s, :, :) = R.ERP_subject;
    
    bad_channels_all_total(s, :) = R.bad_channels_all;

    good_trials_matrix_total(s, :) = R.good_trials_matrix_all;

    class_labels_total(s, :) = R.class_labels_all;

end

%% D1: BAD CHANNELS 

fprintf('\n D1: BAD CHANNELS \n');

D1_table = cell(n_subjects, n_runs);

for s = 1:n_subjects

    for run = 1:n_runs
        
        bad_ch = bad_channels_all_total{s, run};
        
        if isempty(bad_ch)

            D1_table{s, run} = '[]';

        else

            D1_table{s, run} = strtrim(sprintf('%d ', bad_ch));

        end
        
    end

end

col_names = arrayfun(@(r) sprintf('run%d', r), 1:n_runs, 'UniformOutput', false);
row_names = arrayfun(@(subj) sprintf('S%d', subj), subjects, 'UniformOutput', false);

T_D1 = cell2table(D1_table, 'VariableNames', col_names);

T_D1.subject = row_names';

T_D1 = movevars(T_D1, 'subject', 'Before', 1);

disp(T_D1);

writetable(T_D1, 'D1_bad_channels.csv', 'Delimiter', ';');

%% D2: GOOD TRIALS PERCENTAGE

fprintf('\n D2: GOOD TRIALS PERCENTAGE \n');

rows = {};

data_table = [];

for s = 1:length(subjects)
    
    subj = subjects(s);
    
    for c = 1:n_classes
        
        total_trials = 0;

        good_counts = zeros(1,length(channels_of_interest));
        
        for run = 1:n_runs
            
            M = good_trials_matrix_total{s, run};

            labels = class_labels_total{s, run};
            
            class_idx = find(labels == classes(c));
            
            total_trials = total_trials + length(class_idx);
            
            for ch = 1:length(channels_of_interest)

                good_counts(ch) = good_counts(ch) + sum(~isnan(M(class_idx, channels_of_interest(ch))));

            end

        end
        
        if total_trials > 0

            perc = good_counts / total_trials * 100;

        else

            perc = zeros(1, length(channels_of_interest));

        end
        
        rows{end+1, 1} = sprintf('S%d - %s', subj, movement_names{c});

        data_table(end+1, :) = perc;
        
    end
end

data_table = round(data_table, 2);

T_D2 = array2table(data_table, 'VariableNames', channel_names);

T_D2.subject = rows;

T_D2 = movevars(T_D2, 'subject', 'Before', 1);

disp(T_D2);

writetable(T_D2, 'D2_good_trials.csv', 'Delimiter', ';');

%% D3 SUBJECT ERP

fprintf('\n D3: SUBJECT ERP \n');

for s = 1:length(subjects)
    
    subj = subjects(s);
    
    % Create Subject ERP Folder
    folder_name = sprintf('ERP_S%d_figures', subj);

    if ~exist(folder_name, 'dir')

        mkdir(folder_name);

    end

    for c = 1:n_classes

        ERP = squeeze(ERP_subject_all(s, c, :));

        figure;

        set(gcf, 'color', 'w');
        
        plot(time, ERP, 'LineWidth', 1.5)

        grid on;

        title(sprintf('%s (S%d)', movement_names{c}, subj))

        xlabel('Time (s)');
        ylabel('Amplitude (\muV)');

        xline(0, '--k', '0 (warning)');
        xline(2, '--k', '2 (imperative)');

        xlim([-2.5 6]);

        saveas(gcf, fullfile(folder_name, sprintf('S%d_%s.png', subj, movement_names{c})));

        close(gcf);

    end

end

%% D3: GRAND MEAN ERP

fprintf('\n D3: GRAND MEAN ERP \n');

ERP_grand = squeeze(mean(ERP_subject_all, 1, 'omitnan'));

for c = 1:n_classes

    ERP = squeeze(ERP_grand(c, :));

    figure;

    set(gcf, 'color', 'w');

    plot(time, ERP, 'LineWidth', 1.5);

    grid on;

    title(sprintf('Grand Average - %s', movement_names{c}))

    xlabel('Time (s)')
    ylabel('Amplitude (\muV)')

    xline(0,'--k', '0 (warning)');
    xline(2,'--k', '2 (imperative)');

    xlim([-2.5 6])

    saveas(gcf, fullfile('ERP_GrandMean_figures', sprintf('Grand_%s.png', movement_names{c})));

    close(gcf);

end
