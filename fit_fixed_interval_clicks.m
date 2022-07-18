%% setup paths
% CHANGE THESE TWO LINES
project_dir = '~/projects/test_dyn/boydmeredith_piet_data/';
fixeddatapath = '/Users/oroville/projects/sandbox/fixed_rat.mat'

data_dir = fullfile(project_dir, 'data');
res_dir = fullfile(project_dir, 'results');
if ~exist(data_dir,'dir') | ~exist(res_dir,'dir')
    error('data and results directories don''t exist yet')
end

%% load rat data
ratname = 'H037';
load(fullfile(data_dir, ratname),'data')
%% get analytical model fit to rat data
% code at https://github.com/Brody-Lab/accumulation-model
data(1).ratname = ratname;
overwrite = 0;
% fit/load analytical model fit to rat
fit = fit_rat_analytical(data, 'data_dir', data_dir, ...
    'results_dir', res_dir, 'overwrite', overwrite)
%% load fixed interval data
load(fixeddatapath,'fixed')
fixeddata = fixed.K359;
%% get model predictions for fixed interval data
[buptimes,nantimes,streamIdx] = vectorize_clicks({fixeddata.leftbups},...
    {fixeddata.rightbups});
stim_dur = [fixeddata.T];
xbf = fit.final;
all_right_choices = true(size(stim_dur))';
[~, ma, va, ~, ~, fixed_model_pr] = compute_LL_vectorized(buptimes,streamIdx,...
            stim_dur, all_right_choices, xbf,...
            'nantimes', nantimes);
%% Plot psychometrics
% this psychometric plotter is available in 
% https://github.com/Brody-Lab/boydmeredith_logistic_kernel

% poisson clicks rat data
poiss_Delta = [data.Delta]';
poiss_model_pr = fit.pr';
pokedR = [data.pokedR]';
% fixed interal click data 
fixed_Delta = [fixeddata.deltaclicks]';
% fake fixed interal choices using model predictions
fixed_pokedR = fixed_model_pr > rand(size(fixed_model_pr));
model_color = [1.0000    0.5490    0.5490];
fixed_model_color = [0.5490    0.5490 1.0000    ];

figure(1); clf
ax = axes;
plotPsychometric(poiss_Delta, poiss_model_pr, 'axHandle', ax, 'dataLineStyle','', ...
    'compute_fit',0,'dataShaded',1,'dataColor', model_color)
plotPsychometric(poiss_Delta, pokedR, 'axHandle', ax, 'compute_fit',0,'dataLineStyle','.')
xlabel('click difference (R-L)')
ylabel('P(go right)')


plotPsychometric(fixed_Delta, fixed_model_pr, 'axHandle', ax, 'dataLineStyle','', ...
    'compute_fit',0,'dataShaded',1,'dataColor',fixed_model_color)
plotPsychometric(fixed_Delta, fixed_model_pr, 'axHandle', ax, 'compute_fit',0,'dataLineStyle','.')

xlabel('click difference (R-L)')
ylabel('P(go right)')

axis tight

