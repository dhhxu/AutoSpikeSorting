function [feature_handle] = sorter_get_feature(base_dir)
% SORTER_GET_FEATURE get handle of user-chosen feature function
%
%   FEATURE_HANDLE = SORTER_GET_FEATURE() dialog prompt starts in the current
%   working directory.
%
%   FEATURE_HANDLE = SORTER_GET_FEATURE(BASE_DIR) dialog prompt starts in the
%   directory BASE_DIR. If BASE_DIR is empty or does not exist, starts in the
%   current working directory.
%
%   Prompt user with a file open dialog to select a feature function file to use
%   for the sorter program. The feature function must have the following
%   signature:
%   
%       feat_matrix = @(data_matrix)
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
%   FEATURE_HANDLE  function handle of the feature function. If the operation is
%                   cancelled, this is an empty string.

    SetDefaultValue(1, 'base_dir', '');

    feature_handle = '';

    [feature_name, ~, ~] = uigetfile('*.m', 'Select feature function', ...
                                     base_dir);

    if isequal(feature_name, 0)
        warning('No feature selected');
        return
    end

    [~, name, ~] = fileparts(feature_name);

    feature_handle = str2func(name);

end
