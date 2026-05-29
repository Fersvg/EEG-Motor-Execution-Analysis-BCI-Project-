function ERD = compute_ERD_pipeline(data_class, params, time)

    % Power
    power = data_class.^2;

    % Movmean per trial

    window = round(0.150 * params.fs);

    power_smooth = movmean(power, window, 3, 'omitnan');

    % mean between trials
    power_avg = squeeze(mean(power_smooth, 1, 'omitnan'));
 
    % Baseline [-1.5 -1]

    idx_base = (time >= -1.5 & time <= -1);

    baseline = mean(power_avg(:, idx_base), 2, 'omitnan');

    baseline(baseline < eps) = NaN;

    % ERD
    ERD = 100 * (power_avg - baseline) ./ baseline;

end