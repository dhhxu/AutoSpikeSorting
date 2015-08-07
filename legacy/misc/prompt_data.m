function [strm_struct, snip_struct, name, block_num] = prompt_data()
% PROMPT_DATA load tank/block data given user input.
%
% [STRM_STRUCT, SNIP_STRUCT, NAME] = PROMPT_DATA()
%
% Get user input for the tank/block to load. The functionality is the
% same as LOAD_GENERAL, except with user input.
%
% If 'cancel' is selected, no path is chosen and all output fields will be
% empty. The user must then re-run the section containing this function to
% get another dialog prompt.
%
% INPUT:
% NONE
%
% OUTPUT:
% STRM_STRUCT   Struct of raw stream data
% SNIP_STRUCT   Struct of TDT snippet data including timestamps
% NAME          Name of the source tank
% BLOCK_NUM     Block number

    strm_struct = [];
    snip_struct = [];
    name = '';
    block_num = 0;

    path = uigetdir('U:/');
    
    if ~path
        warning('No tank/block selected. Returning empty results');
        return;
    end

    % path should look like: PATH TO TANK / BLOCK-N. If not this is an error.

    [tank_path, block, ~] = fileparts(path);

    % get block number
    C = strsplit(block, '-');
    
    if length(C) < 2
        error('Invalid block directory selected');
    end
    
    [block_num, status] = str2num(C{2});
    if ~status
        error('Invalid block directory selected.');
    end

    [strm_struct, snip_struct] = load_general(tank_path, block_num, pwd);
    [~, name, ~] = fileparts(tank_path);
    
end