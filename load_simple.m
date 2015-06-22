function [status, data] = load_simple(tank, block, root)
% LOAD_SIMPLE Load block data into workspace and add containing folder to path.
%
% load_simple(tank, block, root)
%
% Load the data struct representing BLOCK in TANK. The TANK is located
% in ROOT, which is loaded into the current path.
%
% Input:
% "tank": string of the tank name.
% "block": positive integer of the desired block.
% "root": string containing the parent folder of the desired tank.
%
% Output:
% "status": 0 = success, 1 = fail
% "data": a struct representing the block data. See TDT2mat.m for more details.

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
    
    status = 0;
    