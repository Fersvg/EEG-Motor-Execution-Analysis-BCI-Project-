function ERP_runs = accumulate_trials(ERP_runs, data_ep_good, labels, classes, n_classes)

% Append clean trials to class-specific containers

for c = 1:n_classes
    
    % Find trials belonging to current class
    idx = find(labels == classes(c));
    
    if isempty(idx)

        continue;
    end
    
    % Extract trials for this class
    data_class = data_ep_good(idx, :, :);
    
    % Concatenate trials across runs
    ERP_runs{c} = cat(1, ERP_runs{c}, data_class);
    
end

end