function idx = get_ROI(values, percentile)

    % Find valid values (ignore NaNs)
    valid_idx = ~isnan(values);

    valid_values = values(valid_idx);
    
    % Sort values from lowest to highest
    [~, order] = sort(valid_values);

    % Compute how many values to select based on the given percentage
    n_roi = round(percentile * length(valid_values));
    
    % Get the original positions of valid values
    valid_positions = find(valid_idx);

    % Return the indices of the lowest values according to the percentage
    idx = valid_positions(order(1:n_roi));

end