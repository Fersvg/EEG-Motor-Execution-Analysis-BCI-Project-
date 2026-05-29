function EEG = interpolate(EEG, chanlocs)

% Interpolate bad channels

EEG = pop_interp(EEG, chanlocs, 'spherical');

end