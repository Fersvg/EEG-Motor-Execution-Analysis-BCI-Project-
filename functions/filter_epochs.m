function data_filt = filter_epochs(data_ep, fs, band)

    [n_trials, n_channels, n_samples] = size(data_ep);

    % reshape → (trials*channels) × samples
    data_2D = reshape(data_ep, n_trials*n_channels, n_samples);

    % filtro
    [z,p,k] = butter(4, band/(fs/2), 'bandpass');
    [sos,g] = zp2sos(z,p,k);
    data_filt_2D = filtfilt(sos,g,data_2D')';

    % reshape de vuelta
    data_filt = reshape(data_filt_2D, n_trials, n_channels, n_samples);

end
