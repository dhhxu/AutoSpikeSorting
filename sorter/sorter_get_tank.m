function [tank, path] = sorter_get_tank(base_dir)
% SORTER_GET_TANK get tank name and path from user
%
% [TANK, PATH] = SORTER_GET_TANK(BASE_DIR)
%
% Gets the tank name TANK and path PATH from the user. If the directory does not
% exist, both TANK and PATH will be empty strings.
%
% Note: does not check if the directory is an actual tank.
%
% INPUT:
% BASE_DIR      (optional) base directory to start search from. If not specified
%               or if does not exist, start search from current wd.
%
% OUTPUT:
% TANK          String of tank name
% PATH          String of absolute tank path.

    SetDefaultValue(1, 'base_dir', 'U:/');

    path = uigetdir(base_dir);
    tank = '';

    if ~path
        warning('No path chosen');
        path = '';
        return
    end

    [~, tank, ~] = fileparts(path);

end