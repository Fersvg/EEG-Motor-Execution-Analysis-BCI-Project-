function [data_dec, events] = decimate_data(data, events, params)

% Reduce sampling rate of EEG data and update event timings

factor = params.decim_factor;

% Resample data
data_dec = resample(data', 1, factor)';

% Update event sample indices
events(:,2) = round(events(:,2) / factor);
events(:,3) = round(events(:,3) / factor);

end