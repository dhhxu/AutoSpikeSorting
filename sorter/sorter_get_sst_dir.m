function [path] = sorter_get_sst_dir(base_dir)
% SORTER_GET_SST_DIR get superspiketrain save directory from user.
%
% PATH = SORTER_GET_SST_DIR(BASE_DIR) 
%
% Get the path to the directory to save superspiketrain objects to. If no 
% directory is selected, this is an error and PATH will be empty string.
%
% INPUT:
% BASE_DIR      (optional) base directory to start search from
%
% OUTPUT:
% PATH          String of the path to save SST objects to

    SetDefaultValue(1, 'base_dir', '');

    path = uigetdir(base_dir);

    if ~path
        warning('No SST path selected');
        return
    end

end