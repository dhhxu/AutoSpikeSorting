function [] = load_path(root)
% LOAD_PATH Loads necessary scripts and data for spike sorting into path.
%
% LOAD_PATH(ROOT)
%
% Add the project script files located in parent directory ROOT to the MATLAB
% path. Generally ROOT is the output of the `pwd` function. Also loads external
% scripts located in the 'code' directory.
%
%
% INPUT:
% ROOT      String of the project root directory, usually `pwd`
%
% OUTPUT:
% NONE

    if isempty(root)
        error('Missing argument');
    end

    try
        addpath(genpath(root));
        % third-party scripts
        codePath = fullfile(root, 'code');
        addpath(genpath(codePath));
    catch
        error('Path load failed.');
    end
    
    % remove .git/
    try
        rmpath(genpath(fullfile(root, '.git')));
    catch
        error('Failed to remove .git directory');
    end
end