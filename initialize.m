% Initialization Script
%
% The purpose of the script is to prepare the environment for automatic spike
% sorting algorithms to work in. The motivation for this script is that the raw
% data is large and takes up some time to load. We wish to reduce this loading
% time by loading the data only once and have that data saved to the workspace.
% Doing it this way is cleaner than if this script was written as a function as
% function variables are not accessible from outside the function. In this way,
% multiple algorithms are able to access the same raw data, which reduces
% initialization overhead as well as provides a consistent means to objectively
% compare different algorithms.
%
% Below is a list of tasks the script performs:
%
%   1. Recursively add the project directory to the MATLAB path. This allows the
%      algorithms to access other helper functions.
%
%   2. Load the stream and snippet data from a TDT tank and block, the location
%      of which will be specified by the user. Please refer to LOAD_SIMPLE or
%      LOAD_GENERAL for the internal details on this process. The loaded data
%      will be saved in the STRM_STRUCT and SNIP_STRUCT structs.
%
%      Note that this requires the TDT2mat.m function.
%
%   3. Prompt user for channel to use. The resulting data is stored in
%      STRM_DATA. Note that if a different channel is desired later on, simply
%      re-run the section labeled Step 3 to get the select channel dialog.
%
%
% Requirements for user-made algorithms:
%
%   The following variable names must be used (though the use of the variables
%   is optional):
%
%   STRM_STRUCT         struct containing raw stream data and other info
%   STRM_DATA           1-D vector of raw data for the user-specified channel
%   SNIP_STRUCT         struct containing timestamps as determined by TDT
%   CHANNEL             channel to perform clustering on
%
%   Furthermore, the values of these variables should not be modified. Instead,
%   make a copy of them by assigning them a new variable name. Note the
%   uppercase notation as a reminder to not change the values and/or assign to
%   new values.
%
%   All user-made algorithms must perform the following functions before
%   performing feature extraction and clustering:
%
%       a. Filter the data
%       b. Extract spikes corresponding to timestamps in SNIP_STRUCT. The result
%          should be be a matrix called SPIKE_MATRIX. The rows correspond to
%          spikes, columns to samples.
%
%   In general, the algorithms should be written as nonparametric functions to
%   avoid cluttering the workspace. The output should be the classification
%   vector, which will aid in clustering evaluation and algorithm comparison. In
%   other words, the structure of an algorithm is as follows:
%
%       class = your_algorithm();
%
%
% Usage:
%
%   Assuming that the requirements for the user-made algorithms detailed above
%   have been satisified:
%
%   Run this script (INITIALIZE) by typing 'initialize' in the command prompt
%   (make sure to be in the project root!) or clicking the 'RUN' button in the
%   editor. Then do the following:
%
%       - Enter the path to tank/block
%       - Enter the channel number
%       - Run your algorithms (see below for more details)
%
%
% Running user-made algorithms:
% 
%   There are several ways this part can be done; it is up to the user to come
%   up with the best method suited to the situation. That being said, some
%   suggested ways of doing this step:
%
%       a. Quick evaluation / sanity checking:
%           i) put the name of the script(s) in the last section of this script,
%              which you can treat as 'scratch space.' Not recommended if
%              comparisons and/or evaluations are desired later on.
%           ii) type the name of the script(s) in the command prompt. Same
%               purpose as i) and also not recommended for later comparison
%               and/or evaluations.
%
%       b. Better framework:
%           i) write a script/function that calls the algorithms to compare
%              and/or evaluate and handles the comparison/evaluation steps.
%              This method is cleaner and is easier to extend/modify.
%
%   Comparing a) and b), option b) is the preferred method for processing and or
%   evaluating the clustering results across different user algorithms. This is
%   because INITIALIZE is designed solely to setup the environment for the
%   algorithms to run in. Functions that do not relate to this objective should
%   be written as their own independent scripts/functions.

%% Step 1
fprintf('Begin initialization\n');
load_path(pwd);

%% Step 2: Data selection
[STRM_STRUCT, SNIP_STRUCT, tank_name, block_num] = prompt_data();

%% Step 3: Channel selection.
% If 'cancel' is called, this script will not clear the loaded data. Instead,
% rerun this section again.
nChannels = size(STRM_STRUCT.data, 1);
CHANNEL = prompt_channel(nChannels);
STRM_DATA = STRM_STRUCT.data(CHANNEL, :);

fprintf('Loaded Tank %s, Block %d, Chan %d\n', tank_name, block_num, CHANNEL);

%%
% Environment is finished loading. Run your scripts either here, in the
% command prompt, or in a dedicated framework (recommended).

