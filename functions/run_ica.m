function EEG = run_ica(EEG)

% ICA cleaning using SOBI + ICLabel

EEG = pop_runica(EEG, 'icatype', 'sobi');

EEG = pop_iclabel(EEG, 'default');

% ICLabel-based artifact rejection (threshold 0.7)
EEG = pop_icflag(EEG,[NaN NaN;
                     0.7 1;
                     0.7 1;
                     0.7 1;
                     0.7 1;
                     0.7 1;
                     NaN NaN]);

EEG = pop_subcomp(EEG, [], 0);

end