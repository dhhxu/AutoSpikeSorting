function [algo_handle] = sorter_get_algorithm(base_dir)
% SORTER_GET_ALGORITHM get handle of user-chosen sorter algorithm function.
%
%   ALGO_HANDLE = SORTER_GET_ALGORITHM() dialog prompt starts in the current
%   working directory.
%
%   ALGO_HANDLE = SORTER_GET_ALGORITHM(BASE_DIR) dialog prompt starts in the
%   directory BASE_DIR. If BASE_DIR is empty or does not exist, starts in the
%   current working directory.
%
%   Prompt user with a file open dialog to select a sorting algorithm function
%   file to use for the sorter program. The algorithm function must have the
%   following signature:
%   
%       class = @(data_matrix, k)
%
%   However, this function does not validate the selected function file.
%
%   If the user cancels the operation, returns an empty string.
%
%   INPUT:
%   BASE_DIR    (optional) String of the path to the directory the file open
%               dialog starts in. Default is empty string.
%
%   OUTPUT:
%   ALGO_HANDLE  function handle of the algorithm function. If the operation
%                   is cancelled, this is an empty string.

    SetDefaultValue(1, 'base_dir', '');

    algo_handle = '';

    [algo_name, ~, ~] = uigetfile('*.m', 'Select algorithm function', ...
                                     base_dir);

    if isequal(algo_name, 0)
        warning('No sorter algorithm selected');
        return
    end

    [~, name, ~] = fileparts(algo_name);

    algo_handle = str2func(name);

end
