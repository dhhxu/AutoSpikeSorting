function [ status ] = load_path()
% LOAD_PATH Loads necessary scripts for spike sorting into path.
%
% LOAD_PATH()
%
% Loads Matlab scripts used for spike sorting. The current scripts being loaded
% into the path are:
%   Superspiketrain
%   spiketrain
%
% If more scripts are needed, add the path of their parent directory to the
% try block.
%
% Input:
% NONE
%
% Output:
% STATUS    Return code. Possible values:
%               0 = success
%               1 = problem

status = 1;

try
    addpath(genpath('\\khri-ses.adsroot.itcs.umich.edu\ses\3Shared\Matlab Scripts\Superspiketrain'));
    addpath(genpath('\\khri-ses.adsroot.itcs.umich.edu\ses\3Shared\Matlab Scripts\spiketrain'));
catch
    warning('Path load failed.');
    return;
end

status = 0;
