function [] = load_path(root)
% LOAD_PATH Loads necessary scripts and data for spike sorting into path.
%
% LOAD_PATH(ROOT)
%
% Add the project script files located in parent directory ROOT to the MATLAB
% path. Generally ROOT is the output of the `pwd` function. Also loads external
% scripts located in the 'code' directory.
%
% INPUT:
% ROOT      String of the project root directory, usually `pwd`
%
% OUTPUT:
% NONE

    if isempty(root)
        error('Missing argument');
    end
    
    fprintf('%s: start\n', mfilename);
    
    % Suppress .git warning
    warning('off', 'MATLAB:dispatcher:pathWarning');

    try
        addpath(genpath(root));

        % third-party scripts
        codePath = fullfile(root, 'code');
        addpath(genpath(codePath));
        
        % Superspiketrain scripts
        sst_path = fullfile('U:', '3shared' , 'Matlab Scripts', ...
                            'Superspiketrain');
        addpath(genpath(sst_path));

    catch
        error('\nPath load failed.');
    end
    
    % remove .git/
    try
        rmpath(genpath(fullfile(root, '.git')));
    catch
        error('\nFailed to remove .git directory');
    end
    
    warning('on', 'MATLAB:dispatcher:pathWarning');
    
    fprintf('%s: done\n', mfilename);
end