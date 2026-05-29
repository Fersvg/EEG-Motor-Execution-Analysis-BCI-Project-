function [data,bad_channels] = preprocess(data, fs)

% Preprocess (Detrend + Notch + Bandpass + Bad channels detection + CAR)

% Detrend 
data = detrend(data')';

% Notch (50 Hz)
[b,a] = butter(2, [49 51]/(fs/2), 'stop');
data = filtfilt(b, a, data')';

% Bandpass (0.3 - 70 Hz)
[b,a] = butter(4, [0.3 70]/(fs/2), 'bandpass');
data = filtfilt(b, a, data')';

% Bad channels detection
bad_channels = detect_bad_channels(data, fs);

% CAR
data = apply_car(data, bad_channels);

end