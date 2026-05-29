function data = filter_MRCP(data, fs)

% 0.3 - 3 Hz Bandpass filter for MRCP

[b,a] = butter(4, [0.3 3]/(fs/2), 'bandpass');

data = filtfilt(b, a, data')';

end