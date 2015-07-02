function [manual_sorted] = convert_sorted_plx(varargin)
% CONVERT_SORTED_PLX converts .plx file containing spike assignments to a cell
% structure.
%
% MANUAL_SORTED = CONVERT_SORTED_PLX() Interactive, file-open dialog for the
%                 user to select the .plx file.
%
% MANUAL_SORTED = CONVERT_SORTED_PLX(PLX_PATH) Non-interactive, PLX_PATH is a
%                 string of the absolute path to the .plx file.
%
% Requires files from the Plexon Offline SDK for Matlab.
%
% Given a .plx file that is provided either interactively or as an argument,
% this function converts it to a cell structure. The result, MANUAL_SORTED,
% can be saved to a .mat file if so desired.
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
    
end