function [strm, snip] = load_simple(tank, block, root)
% LOAD_SIMPLE Load block data into workspace.
%
% [STRM, SNIP] = LOAD_SIMPLE(TANK, BLOCK, ROOT)
%
% Requires TDT2mat.m
%
% Load the data struct (see TDT documentation for struct details) located in
% tank named TANK, block number BLOCK. The tank directory is at the same level
% as ROOT, which generally is the same as `pwd`. This function should not be
% called alone; it should only be invoked by the clustering script.
%
% The structure of the file system is as follows:
%
%   ..
%    |__ TANK/
%    |__ ROOT/
%
% If this is the first time TANK is loaded in this manner, this function 
% saves the data struct to TANK-Block-BLOCK.mat, which is at the same level
% as TANK and ROOT. So, after this function is invoked, the file system will
% look like:
%
%   ..
%    |__ TANK/
%    |__ ROOT/
%    |__ TANK-Block-BLOCK.mat
%
% INPUT:
% TANK      String of the tank name. Should be an existing directory
% BLOCK     Positive integer of the desired block
% ROOT      String of the path of the project files
%
% OUTPUT:
% STRM      Struct containing raw stream data
% SNIP      Struct containing snippet data with timestamps of user-identified
%           spike waveforms

    if block <= 0 || isempty(tank) || isempty(root)
        error('Invalid block: %d', block);
    elseif isempty(tank)
        error('Empty tank');
    elseif isempty(root)
        error('Empty root path');
    elseif ~exist('TDT2mat', 'file')
        error('TDT2mat required');
    end

    parent = fileparts(root);
    tank_path = fullfile(parent, tank);

    if ~exist(tank_path, 'dir')
        error('Missing tank: %s', tank);
    end

    data = load_block(tank, tank_path, block, parent);
    
    strm = data.streams.STRM;
    snip = data.snips.CSPK;
end

function [data] = load_block(tank, tank_path, block, parent)
% Helper function. Returns the data struct from TDT2mat call to TANK and BLOCK.
% If the BLOCK has been loaded before by a previous call to load_simple, it
% should have been saved to a file. In this case, this function simply loads
% that saved file into the workspace.

    mat_name = sprintf('%s-Block-%d.mat', tank, block);
    mat_path = fullfile(parent, mat_name);

    if ~exist(mat_path, 'file')
        fprintf('.mat file not found for: %s\nCreating one...\n', mat_name);

        try
            block_str = sprintf('Block-%d', block);
            data = TDT2mat(tank_path, block_str, 'Type', [ 3 4 ], ...
                'Verbose', false);
        catch
            error('Missing block: %d\n', block);
        end

        save(mat_path, '-struct', 'data', '-v7.3');
    else
        fprintf('.mat file found for: %s\nLoading it...\n', mat_name);
        data = load(mat_path);
    end
end
    