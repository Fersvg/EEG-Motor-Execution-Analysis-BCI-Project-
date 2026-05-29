function params = get_params_ERD()

% Global ERD parameters

params.fs = 512;
params.runs = 1:10;
params.n_runs = length(params.runs);
params.subjects = [1 3 4 5 6 7 9 12];
params.n_subjects = length(params.subjects);
params.classes = [1536 1537 1538 1539 1540 1541]; %Rest not included
params.n_classes = length(params.classes);
params.tmin = -2.5;
params.tmax = 5.5;

end