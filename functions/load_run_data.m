function [data, events, chanlocs] = load_run_data(subj, run)

% Load EEG data for a given subject and run

filename = sprintf('S%d/ME_S%02d_r%02d.mat', subj, subj, run);

if ~isfile(filename)
    warning('File not found: %s', filename);
    data = []; 
    events = []; 
    chanlocs = [];
    return;
end

EEG_orig = load(filename);

data = double(EEG_orig.EEG.data(1:61, :));
events = EEG_orig.EEG.events;
chanlocs = EEG_orig.EEG.chanlocs(1:61);

end