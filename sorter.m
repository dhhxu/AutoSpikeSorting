% Tank sorter script
%
% Perform semi-automatic spike sorting on a TDT data tank. The user supervises
% block receptive field detection, spike alignment, and number of clusters.
%
% Clustering is performed on the scale of receptive fields and each channel is
% clustered individually.
%
% After clustering is completed for a receptive field, a Superspiketrain object
% is constructed for each unit on a channel for all channels for that receptive
% field. The object will be saved to a user-specified directory.
%
% The actual class labels will be saved on a per-block basis for future
% validation.

fprintf('\nsorter: begin\n');

%% Load paths
load_path(pwd);

%% Get tank path
[TANK, PATH] = sorter_get_tank();

%% Get SST save directory
SST_PATH = sorter_get_sst_dir();

%% Get sorting procedure
[procedure] = sorter_get_procedure();

%% Detect RFs
% rf_blocks = find_rfs(PATH);     % cell structure

%% Check detected RFs


%% Get RF super blocks
[superblocks, ~] = build_rfblock(PATH);

%% Cluster by channel, construct SST objects


%% Save clustering results on per-block basis


fprintf('\nsorter: end\n');