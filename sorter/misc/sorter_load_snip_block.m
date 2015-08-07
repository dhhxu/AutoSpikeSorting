function [snip, epoc] = sorter_load_snip_block(path, block, data_dir, sav)
% SORTER_LOAD_SNIP_BLOCK Load block data into workspace.
%
%   [SNIP, EPOC] = SORTER_LOAD_SNIP_BLOCK(PATH, BLOCK, DATA_DIR) Load block
%   struct and save it to a mat file.            
%
%   [SNIP, EPOC] = SORTER_LOAD_SNIP_BLOCK(PATH, BLOCK, DATA_DIR, false) Load
%   block data struct but don't save data.
%
%   Load snippet and epoch structs from a TDT tank (directory). The tank
%   is located at the absolute path PATH. Only data in block number BLOCK is
%   loaded.
%
%   If this is the first time the tank located at path PATH is loaded in this
%   manner, the data struct containing the SNIP struct will be saved to
%   a .mat file for convenient later access. This .mat file will be called
%   <TANK>-Block-<BLOCK>.mat. This is the default behavior. Otherwise, the SAV
%   variable can be set to False if saving to .mat file is undesired.
%
%   The name TANK is the name of the directory described by PATH. The file will
%   be saved to the DATA_DIR directory.
%
%   If this is not the first time this function has been called on TANK and
%   BLOCK, simply loads the saved .mat file if it exists in DATA_DIR.
%
% INPUT:
% PATH      String of the absolute path to the tank directory.
% BLOCK     Positive integer of the desired block.
% DATA_DIR  String of the absolute path of the project.
% SAV       (optional) Set to false to not save to .mat file. Default: true
%
% OUTPUT:
% SNIP      Struct containing snippet data with timestamps of user-identified
%           spike waveforms
% EPOC      Struct containing epoch information
%
% See also TDT2MAT.

    if block <= 0
        error('Invalid block: %d', block);
    elseif isempty(path)
        error('Empty tank path');
    elseif isempty(data_dir)
        error('Empty data directory path');
    elseif ~exist(data_dir, 'dir')
        error('Data directory does not exist');
    elseif ~exist('TDT2mat', 'file')
        error('TDT2mat required');
    elseif ~exist(path, 'dir')
        error('Missing tank: %s', path);
    end
    
    SetDefaultValue(4, 'sav', true);

    data = load_block(path, block, data_dir, sav);

    snip = data.snips.CSPK;
    epoc = data.epocs;
end

function [data] = load_block(tank_path, block, loc, sav)
% Helper function. Returns the data struct from TDT2mat call to TANK and BLOCK.
% If the BLOCK has been loaded before by a previous call to 
% sorter_load_snip_block, with the save option set to true, it should have been
% saved to a file. In this case, this function simply loads
% that saved file into the workspace.

    [~, tank_name, ~] = fileparts(tank_path);

    mat_name = sprintf('%s-Block-%d.mat', tank_name, block);
    mat_path = fullfile(loc, mat_name);

    if ~exist(mat_path, 'file')

        try
            block_str = sprintf('Block-%d', block);
            data = TDT2mat(tank_path, block_str, 'Type', [2, 3], ...
                           'Verbose', false);
        catch
            error('Missing block: %d\n', block);
        end

        if sav
            fprintf('.mat file not found for: %s\nCreating one...\n', mat_name);
            save(mat_path, '-struct', 'data', '-v7.3');
        end

    else
        fprintf('.mat file found for: %s\nLoading it...\n', mat_name);
        data = load(mat_path);
    end
end
    