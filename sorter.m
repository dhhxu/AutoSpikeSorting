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

if isempty(TANK) || isempty(PATH)
    return;
end

tank_info.tank = TANK;
tank_info.path = PATH;

clear TANK PATH;

%% Get data save directory
DATA_PATH = sorter_get_dir();

if isempty(DATA_PATH)
    return
end

%% Get sorting procedure
PROC = sorter_get_procedure();

%% Get RF super blocks
tic
[superblocks, rf_idx] = build_rfblock(tank_info.path, DATA_PATH);
toc
%% Cluster by channel, construct SST objects
sorter_cluster_superblock(superblocks, PROC, tank_info, SST_PATH);

%% Save clustering results on per-block basis


fprintf('\nsorter: end\n');