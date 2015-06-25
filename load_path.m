function [] = load_path(root)
% LOAD_PATH Loads necessary scripts and data for spike sorting into path.
%
% LOAD_PATH(root)
%
% Add the project script files located in parent directory ROOT to the MATLAB
% path. Generally ROOT is the output of the `pwd` function. Also loads external
% MATLAB scripts by TDT. If a load fails, terminates with an error.
%
% Current external scripts:
%   Superspiketrain
%   spiketrain
%
% INPUT:
% ROOT      String of the project root directory
%
% OUTPUT:
% NONE

    try
        addpath(genpath(root));
        addpath(genpath('\\khri-ses.adsroot.itcs.umich.edu\ses\3Shared\Matlab Scripts\Superspiketrain'));
        addpath(genpath('\\khri-ses.adsroot.itcs.umich.edu\ses\3Shared\Matlab Scripts\spiketrain'));
    catch
        error('Path load failed.');
    end
end