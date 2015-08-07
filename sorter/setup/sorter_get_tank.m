function [tank, path] = sorter_get_tank(base_dir)
% SORTER_GET_TANK get tank name and path from user
%
%   [TANK, PATH] = SORTER_GET_TANK() dialog opens in the current working
%   directory.
%
%   [TANK, PATH] = SORTER_GET_TANK(BASE_DIR) dialog opens in the directory
%   BASE_DIR. If this directory does not exist, the current working directory is
%   used instead.
%
% Gets the tank name TANK and path PATH from the user via a dialog. If the
% user cancels the operation, both TANK and PATH will be empty strings.
%
% Note: does not check if the directory is an actual tank.
%
% INPUT:
% BASE_DIR      (optional) base directory to start search from. If not specified
%               or if does not exist, start search from current working
%               directory.
%
% OUTPUT:
% TANK          String of tank name.
% PATH          String of absolute tank path.

    SetDefaultValue(1, 'base_dir', '');

    path = uigetdir2(base_dir, 'Select tank to open');
    tank = '';

    if isempty(path)
%         warning('No path chosen');
        path = '';
        return
    end

    [~, tank, ~] = fileparts(path);

end