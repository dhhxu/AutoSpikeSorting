% Tank sorter script
%
% Perform semi-automatic spike sorting on a TDT data tank. The user supervises
% spike alignment and number of clusters.
%
% Clustering is performed on the scale of receptive fields and each channel is
% clustered individually. Although TDT's data is on the block scale, receptive
% fields may span several blocks and/or parts of blocks. To accommodate this,
% "superblocks" are created from the tank data. Each superblock may contain one
% or more blocks, and/or parts of blocks. Furthermore, a superblock will contain
% exactly one receptive field.
%
% After clustering is completed for a channel on a superblock, a Superspiketrain
% object is constructed for each unit identified in that channel.
% Figures/statistics are also generated for each channel. This is repeated for
% each channel on each superblock.
%
% The generated data files will be stored in a directory with the same name as
% the tank chosen. This directory will be located in an user-specified data
% directory.
%
% Author: Daniel Xu (dhhxu88@gmail.com)
% Mentor: David Martel

fprintf('\nsorter: begin\n');

%% Initialization

% Improve figure rendering performance.
set(0, 'DefaultFigureRenderer', 'OpenGL');

% This function assumes that SORTER.M is in the project root e.g.
% '.../AutoSpikeSorting/'
load_path(pwd);

%% Get tank path
[tank, tank_path] = sorter_get_tank('U:/');

if isempty(tank) || isempty(tank_path)
    return
end

tank_info.tank = tank;
tank_info.path = tank_path;

clear tank tank_path;

%% Get feature file
[feat_handle] = sorter_get_feature(fullfile(pwd, 'features'));

if isempty(feat_handle)
    return
end

pause(1);

%% Get algorithm file
[algo_handle] = sorter_get_algorithm(fullfile(pwd, 'algorithms'));

if isempty(algo_handle)
    return
end

pause(1);

%% Get data save directory
DATA_PATH = uigetdir2('', 'Select data output directory');

if isempty(DATA_PATH)
    warning('No data directory selected');
    return
end

%% Get RF super blocks
tic
[superblocks, ~, ~] = build_rfblock(tank_info.path, DATA_PATH);
toc

%% Cluster by channel, construct SST objects
if isempty(superblocks)
    warning('No superblocks available');
    return
end

sorter_cluster_superblock(superblocks, feat_handle, algo_handle, tank_info, ...
                          DATA_PATH);

%%
fprintf('\nsorter: end\n');
