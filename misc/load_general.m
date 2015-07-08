function [strm, snip] = load_general(path, block, root)
% LOAD_GENERAL Load block data into workspace.
%
% [STRM, SNIP] = LOAD_GENERAL(PATH, BLOCK, ROOT)
%
% Requires TDT2mat.m
%
% Load stream and snippet structs from data in a TDT tank (directory). The tank
% is located at the absolute path PATH. Only data in block number BLOCK is
% loaded.
%
% Most of the time, this function will be called by a clustering script.
% Generally the clustering script is a child of the project root directory ROOT,
% which is an absolute path. Usually ROOT will be equivalent to `pwd`
%
% The structure of the file system is as follows:
%
%   ..
%    |__ ROOT/
%           |__ your_clustering_script.m
%
% If this is the first time the tank located at path PATH is loaded in this
% manner, the data struct containing the STRM and SNIP structs will be saved to
% a .mat file for convenient later access. This .mat file will be called
% <TANK>-Block-<BLOCK>.mat (brackets shown for clarity).
%
% The name TANK is the name of the directory described by PATH. The file will be
% saved at the same level as ROOT.
%
% As an example, after this function is invoked on TANK, BLOCK for the first
% time, the file system will look like:
%
%   ..
%    |__ TANK-Block-BLOCK.mat
%    |__ ROOT/
%           |__ your_clustering_script.m
%
% If this is not the first time this function has been called on TANK and BLOCK,
% simply loads the saved .mat file.
%
% INPUT:
% PATH      String of the absolute path to the tank directory
% BLOCK     Positive integer of the desired block
% ROOT      String of the absolute path of the project.
%
% OUTPUT:
% STRM      Struct containing raw stream data
% SNIP      Struct containing snippet data with timestamps of user-identified
%           spike waveforms
%
% See also TDT2mat

    if block <= 0
        error('Invalid block: %d', block);
    elseif isempty(path)
        error('Empty tank path');
    elseif isempty(root)
        error('Empty root path');
    elseif ~exist('TDT2mat', 'file')
        error('TDT2mat required');
    elseif ~exist(path, 'dir')
        error('Missing tank: %s', path);
    end

    parent = fileparts(root);
    data = load_block(path, block, parent);
    
    strm = data.streams.STRM;
    snip = data.snips.CSPK;
end

function [data] = load_block(tank_path, block, parent)
% Helper function. Returns the data struct from TDT2mat call to TANK and BLOCK.
% If the BLOCK has been loaded before by a previous call to load_general, it
% should have been saved to a file. In this case, this function simply loads
% that saved file into the workspace.

    [~, tank_name, ~] = fileparts(tank_path);

    mat_name = sprintf('%s-Block-%d.mat', tank_name, block);
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
    