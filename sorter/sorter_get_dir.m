function [path] = sorter_get_dir(base_dir)
% SORTER_GET_DIR get a directory path from user.
%
% PATH = SORTER_GET_DIR(BASE_DIR)
%
% Get a directory path from the user. The directory is guaranteed to exist. If
% no directory is selected (i.e. user cancels the operation), an empty string is
% returned. BASE_DIR is the start directory to begin the search.
%
% INPUT:
% BASE_DIR      (optional) base directory to start search from. Default: empty
%               string.
%
% OUTPUT:
% PATH          String of the path to the user-selected directory

    SetDefaultValue(1, 'base_dir', '');

    path = uigetdir(base_dir);

    if ~path
        path = '';
        warning('No path selected');
        return
    end

end