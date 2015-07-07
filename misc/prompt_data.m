function [strm_struct, snip_struct, name, block_num] = prompt_data()
% PROMPT_DATA load tank/block data given user input.
%
% [STRM_STRUCT, SNIP_STRUCT, NAME] = PROMPT_DATA()
%
% Get user input for the tank/block to load. The functionality is the
% same as LOAD_GENERAL, except with user input.
%
% Note: this function should be called
%
% INPUT:
% NONE
%
% OUTPUT:
% STRM_STRUCT   Struct of raw stream data
% SNIP_STRUCT   Struct of TDT snippet data including timestamps
% NAME          Name of the source tank
% BLOCK_NUM     Block number

    path = uigetdir();

    % path will look like: PATH TO TANK / BLOCK-N

    [tank_path, block, ~] = fileparts(path);

    % get block number
    C = strsplit(block, '-');
    block_num = str2num(C{2});
    clear C;

    [strm_struct, snip_struct] = load_general(tank_path, block_num, pwd);
    [~, name, ~] = fileparts(tank_path);
    
end