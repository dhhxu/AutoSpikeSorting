function [procedure_handle] = sorter_get_procedure(base_dir)
% SORTER_GET_PROCEDURE get clustering procedure handle from user.
%
% PROCEDURE_HANDLE = SORTER_GET_PROCEDURE()
%
% PROCEDURE_HANDLE = SORTER_GET_PROCEDURE(BASE_DIR)
%
% Get the clustering procedure handle from user. The output is empty string if
% the user selects cancel.
%
% INPUT:
% BASE_DIR              (optional) directory string to start search from.
%
% OUTPUT:
% PROCEDURE_HANDLE      Function handle of cluster procedure to use.

    SetDefaultValue(1, 'base_dir', '');

    [proc_name, ~, ~] = uigetfile('*.m', 'Select procedure', base_dir);

    if isequal(proc_name, 0)
        proc_name = '';
        warning('No procedure selected');
        return
    end
    
    [~, name, ~] = fileparts(proc_name);

    eval(sprintf('procedure_handle = @%s;', name));
end