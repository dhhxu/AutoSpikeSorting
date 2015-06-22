function [ status ] = load_path()
% LOAD_PATH Loads necessary scripts for spike sorting into path.
%
% load_path()
%
% Loads Matlab scripts used for spike sorting. The current scripts being loaded
% into the path are:
%   Superspiketrain
%   spiketrain
%   wave_clus_2.0wb
%
% If more scripts are needed, add the path of their parent directory to the
% try block.
%
% Input:
% NONE
%
% Output:
% "status": 0 = no issues, 1 = problem.

    status = 1;
    
    try
        addpath(genpath('\\khri-ses.adsroot.itcs.umich.edu\ses\3Shared\Matlab Scripts\Superspiketrain'));
        addpath(genpath('\\khri-ses.adsroot.itcs.umich.edu\ses\3Shared\Matlab Scripts\spiketrain'));
        addpath(genpath('\\khri-ses.adsroot.itcs.umich.edu\ses\Daniel X\wave_clus_2.0wb'));
    catch
        warning('Path load failed.');
        return;
    end
    
    status = 0;
