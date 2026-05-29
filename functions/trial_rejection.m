function [good_matrix, data_ep_good] = trial_rejection(data_ep, labels, rt)

% Reject bad trials based on RT and outliers

n_trials = size(data_ep, 1);
n_channels = size(data_ep, 2);

good_matrix = ones(n_trials, n_channels);

for t = 1:n_trials
    
    trial = squeeze(data_ep(t, :, :));
    
    % RT-based trial rejection

    if labels(t) ~= 1542 % Rest not included

        if rt(t) < 0.1 || rt(t) > 2

            good_matrix(t, :) = NaN;

            continue;

        end

    end
    
    %Statistical features

    trial_var  = var(trial, 0, 2);
    trial_kurt = kurtosis(trial, 0, 2);

    %Normalization (z-score)
    
    z_var = zscore(trial_var);
    z_kurt = zscore(trial_kurt);
    
    for ch = 1:n_channels

        % Amplitude threshold (artifact rejection)

        if max(abs(trial(ch, :))) > 150

            good_matrix(t, ch) = NaN;

        end

        % Variance/Kurtosis outlier detection
        
        if abs(z_var(ch)) > 5 || abs(z_kurt(ch)) > 5

            good_matrix(t, ch) = NaN;

        end
        
    end
    
end

% Apply rejection mask to data
data_ep_good = data_ep;

for t = 1:n_trials

    for ch = 1:n_channels
        
        if isnan(good_matrix(t, ch))

            data_ep_good(t, ch, :) = NaN;

        end
        
    end
end

end