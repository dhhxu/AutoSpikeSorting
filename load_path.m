function [] = load_path(root)
% LOAD_PATH Loads necessary scripts and data for spike sorting into path.
%
% LOAD_PATH(ROOT)
%
% Add the project script files located in parent directory ROOT to the MATLAB
% path. Generally ROOT is the output of the `pwd` function. Also loads external
% scripts located in the 'code' directory, which is at the same level as ROOT.
%
% Current external scripts:
%   ../code/*
%
% INPUT:
% ROOT      String of the project root directory
%
% OUTPUT:
% NONE

    try
        addpath(genpath(root));
%         addpath(genpath('\\khri-ses.adsroot.itcs.umich.edu\ses\3Shared\Matlab Scripts\Superspiketrain'));
%         addpath(genpath('\\khri-ses.adsroot.itcs.umich.edu\ses\3Shared\Matlab Scripts\spiketrain'));

        % Currently only use TDT2mat.m as an external script.
        codePath = fullfile(fileparts(root), 'code');
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