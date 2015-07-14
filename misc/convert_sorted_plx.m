function [manual_sorted, tank, blocknum] = convert_sorted_plx(varargin)
% CONVERT_SORTED_PLX converts .plx file containing spike assignments to a cell
% structure and extracts file metadata.
%
% [MANUAL_SORTED, TANK, BLOCKNUM] = CONVERT_SORTED_PLX()
%                 Interactive, file-open dialog for the user to select the .plx
%                 file.
%
% [MANUAL_SORTED, TANK, BLOCKNUM] = CONVERT_SORTED_PLX(PLX_PATH)
%                 Non-interactive, PLX_PATH is a string of the absolute path to
%                 the .plx file.
%
% Requires files from the Plexon Offline SDK for Matlab.
%
% Given a .plx file that is provided either interactively or as an argument,
% this function converts it to a cell structure. The result, MANUAL_SORTED,
% can be saved to a .mat file if so desired. The .plx file describes data in a
% block belonging to a tank.
%
% This function also extracts the tank name and block number for later use in
% the variables TANK and BLOCKNUM, respectively.
%
% INPUT:
% PLX_PATH      String of the absolute path to the .plx file to be converted
%
% OUTPUT:
% MANUAL_SORTED Cell structure containing the spike assignments for each channel
%               as well as their time stamps. The structure of the cell is as
%               follows:
%
%               ----------|-----------|-----|----------
%               Unsorted  | Unsorted  | ... | Unsorted
%               ----------|-----------|-----|----------
%               Unit a    | Unit a    | ... | Unit a
%               ----------|-----------|-----|----------
%               Unit b    | Unit b    | ... | Unit b
%               ----------|-----------|-----|----------
%                  []           .
%                  []           .
%                  []           .
%                  []       Unit n
%               ----------|-----------|-----|----------
%
%               The columns of the cell correspond to channels. Each of the
%               elements represents a cluster of spikes. Each element is a one
%               dimensional double vector containing the timestamps of the
%               spikes assigned to it (units: seconds).
%
%               Note that some channels may have more units than others, so the
%               cell will be padded with empty vectors such that it is
%               rectangular-shaped.
% TANK          String of the tank name
% BLOCKNUM      Integer of the block number.
    
    plx_path = '';
    
    if nargin > 1
        error('Too many arguments: %d', nargin);        
    elseif nargin == 1
        plx_path = varargin{1};
        if ~exist(plx_path, 'file')
            error('Path not found: %s', plx_path);
        end
    end
    
    manual_sorted = readall_custom(plx_path);
    
    % Code to delete empty rows from the cell was taken from:
    % http://www.mathworks.com/matlabcentral/newsreader/view_thread/164617
    manual_sorted(all(cellfun(@isempty, manual_sorted), 2), :) = [];
    % Delete empty columns.
    manual_sorted(:, all(cellfun(@isempty, manual_sorted), 1)) = [];
    
    [tank, blocknum] = parse_filename(path);

end

function [tank, block_num] = parse_filename(path)
% Parse the path to the .plx file and get the tank name and block number. This
% assumes that the file name begins with: <TANK>_Block-<BLOCK_NUM>_...plx
% If the file name is valid, returns the tank name and block number. Otherwise,
% returns empty string for TANK and 0 for BLOCK_NUM, if the function cannot
% parse out the field.

    tank = '';
    block_num = 0;

    parts = strsplit(path, '_');
    
    if length(parts) < 2
        warning('Could not parse plx file name as it is too short');
        return;
    end
    
    prefix = parts{1};
    [~, tank, ~] = fileparts(prefix);
    
    block_part = parts{2};
    tmp = strsplit(block_part, '-');
    
    if length(tmp) < 2
        warning('Missing block number');
        return;
    end
    
    [block_num, status] = str2num(tmp{2});
    if ~status
        error('Could not parse block number');
    end
end