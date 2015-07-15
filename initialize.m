% Initialization Script
%
% The purpose of the script is to prepare the environment for automatic spike
% sorting algorithms to work in. The motivation for this script is that the raw
% data is large and takes up some time to load. We wish to reduce this loading
% time by loading the data only once and have that data saved to the workspace.
%
% Below is a list of tasks the script performs:
%
%   1. Recursively add the project directory to the MATLAB path. This allows the
%      algorithms to access other helper functions.
%
%   2. Load the stream and snippet data from a TDT tank and block, the location
%      of which will be specified by the user. The tank/block combination will
%      be saved for later use. (for details, see LOAD_GENERAL)
%
%   3. Save extracted data to a struct called INFO.
%
%      The following fields are present in the INFO struct:
%
%       strm         struct containing raw stream data and other info
%       snip         struct containing timestamps as determined by TDT
%       tank         string of the tank name
%       blocknum     integer of the block number
%
%   As this struct is intended to be shared among multiple algorithms, its
%   fields and their contents should not be modified.
%
%   All user-made algorithms must perform at a minimum the following:
%   	a. feature extraction
%       b. clustering
%
%   Algorithms may also perform the filtering step.
%
%   For more detail on the algorithm format, see also COMPARE_PROCEDURE.

%% Start
fprintf('\ninitialize: start\n');
load_path(pwd);  % pwd should be the root of your project directory.

%% Data selection
[strm, snip, tank_name, block_num] = prompt_data();

if isempty(strm) || isempty(snip) || isempty(tank_name) ...
   || ~block_num
    error('No tank/block chosen.');
end

% Strm.data may have empty rows due to some channels not used
tmp = strm.data;
tmp(all(tmp == 0, 2), :) = [];

INFO.strm = strm;
INFO.strm.data = tmp;
INFO.snip = snip;
INFO.tank = tank_name;
INFO.blocknum = block_num;

clear strm snip tank_name block_num tmp;

%% end

fprintf('\ninitialize: end\n');

