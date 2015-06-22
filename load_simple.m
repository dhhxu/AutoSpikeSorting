function [status, data] = load_simple(tank, block, root)
% LOAD_SIMPLE Load block data into workspace and add containing folder to path.
%
% LOAD_SIMPLE(tank, block, root)
%
% Load the data struct representing BLOCK in TANK. The TANK is located
% in ROOT, which is loaded into the current path. If this is the first time TANK
% is loaded in this manner, saves the data struct to TANK-Block-1.mat
%
% INPUT:
% TANK      String of the tank name
% BLOCK     Positive integer of the desired block
% ROOT      String containing the parent folder of the desired tank
%
% OUTPUT:
% STATUS    Return code. Possible values:
%               0 = success
%               1 = fail
% DATA      A struct representing the block data. See TDT2mat.m for more details

status = 1;
data = [];

if block <= 0 || isempty(tank) || isempty(root)
    return;
end

try
    addpath(genpath(root));
catch
    warning('Failed to add to path: %s\n', root);
    return;
end

tank_path = fullfile(root, tank);

mat_name = sprintf('%s-Block-%d.mat', tank, block);
mat_path = fullfile(root, mat_name);

if ~exist(mat_path, 'file')
    fprintf('.mat file not found for: %s\nCreating one...\n', mat_name);
    
    if ~exist(tank_path, 'dir')
        warning('Missing tank: %s\n', tank);
        return;
    end

    try
        block_str = sprintf('Block-%d', block);
        data = TDT2mat(tank_path, block_str, 'Type', [ 3 4 ], 'Verbose', false);
    catch
        warning('Missing block: %d\n', BLOCK);
        return;
    end
    
    save(mat_path, '-struct', 'data', '-v7.3');

else
    fprintf('.mat file found for: %s\nLoading it...\n', mat_name);
    data = load(mat_path);
end

status = 0;
    