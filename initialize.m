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
%      will be saved in the STRM_STRUCT and SNIP_STRUCT structs. Furthermore,
%      the raw stream data for all channels will be stored in STRM_DATA.
%
%      Note that this requires the TDT2mat.m function.
%
%   3. Prompt user for channel to use. Then extract the raw channel data to 
%      CHAN_DATA vector. Note that if a different channel is desired later on,
%      simply re-run the section labeled Step 3 to get the select channel
%      dialog.
%
%   4. Bandpass filter the selected channel data (300-3000 Hz) and extract spike
%      waveforms using timestamps from snippet information. The extracted spikes
%      will be by default 32 samples (corresponding to ~2.6 ms at roughly 12.2
%      kHz).
%
%   5. Align the spike waveforms on peaks. The user will be prompted to enter
%      alignment options. The aligned spikes are stored in matrix SPIKE_MATRIX.
%
%   Do note that the user algorithm may implement a different version of Steps 4
%   and 5. But the result from step 5 must be saved to a new variable name other
%   than SPIKE_MATRIX. See 'Requirements for user-made algorithms' below for
%   details.
%
%   After this script finishes running, it bundles the above variables that are
%   capitalized into a struct called INFO. This struct is then passed to
%   user-made algorithms (see below for more details).
%
% Requirements for user-made algorithms:
%
%   The following variable names must be used (though the use of the
%   variables is optional):
%
%   STRM_STRUCT         struct containing raw stream data and other info
%   STRM_DATA           matrix of raw data for all channels
%   CHAN_DATA           1-D vector of raw data for the user-specified channel
%   SNIP_STRUCT         struct containing timestamps as determined by TDT
%   CHANNEL             channel to perform clustering on
%   SPIKE_MATRIX        matrix of spike waveforms in channel CHANNEL
%
%   Furthermore, the values of these variables should not be modified. Instead,
%   make a copy of them by assigning them a new variable name. Note the
%   uppercase notation as a reminder to not change the values and/or assign to
%   new values.
%
%   All user-made algorithms must perform at a minimum the following:
%   	a. feature extraction
%       b. clustering
%
%   Adhering to the minimum imposes the restriction of bandpass filtered data,
%   as currently the only detection method in use uses TDT timestamps to locate
%   spike events. However, user algorithms may implement their own filtering
%   method but must use TDT's spike extraction method (see TDT_SPIKES). Also,
%   the alternative filter method must be clearly documented in the algorithm
%   header.
%
%   WARNING: Take care not to overwrite the SPIKE_MATRIX created by this script!
%
%   The following is the expected signature of user-algorithms:
%
%       class = your_algorithm(INFO)
%
%       where 'your_algorithm' clearly describes the feature extraction method
%       and clustering algorithm used, and INFO is the struct generated by the
%       initialization script.
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
load_path(pwd);  % pwd should be the root of your project directory.

%% Step 2: Data selection
[STRM_STRUCT, SNIP_STRUCT, tank_name, block_num] = prompt_data();

if isempty(STRM_STRUCT) || isempty(SNIP_STRUCT) || isempty(tank_name) ...
   || ~block_num
    error('No tank/block chosen.');
end

STRM_DATA = STRM_STRUCT.data;

INFO.STRM_DATA = STRM_DATA;
INFO.STRM_STRUCT = STRM_STRUCT;
INFO.SNIP_STRUCT = SNIP_STRUCT;

%% Step 3: Channel selection.
% If 'cancel' is called, this script will not clear the loaded data. Instead,
% rerun this section again.
nChannels = size(STRM_STRUCT.data, 1);
CHANNEL = prompt_channel(nChannels);

if ~CHANNEL
    error('No channel selected. Re-run Step 3 to restart.');
end

CHAN_DATA = STRM_STRUCT.data(CHANNEL, :);

fprintf('Loaded Tank %s, Block %d, Chan %d\n', tank_name, block_num, CHANNEL);
clear tank_name block_num;

INFO.CHANNEL = CHANNEL;
INFO.CHAN_DATA = CHAN_DATA;

%% Step 4: Filtering and extraction.

D = defaults();

processed_data = bpf(CHAN_DATA, D.LO, D.HI, STRM_STRUCT.fs * 2);
spikes = tdt_spikes(processed_data, STRM_STRUCT, SNIP_STRUCT, CHANNEL, ...
                    D.WINDOW);

clear processed_data;

%% Step 5: Spike Alignment
% Hitting 'cancel' will put erroneous values for option, shift, and window,
% causing the script to abort. The variables will be saved, and the process can
% be restarted by re-running this section.
[option, shift, window] = prompt_align(spikes);

if isempty(option) || ~shift || ~window
    error('Invalid alignment options. Re-run Step 5 to restart.');
else
    fprintf('Aligning spikes on %s, max shift %d, window size %d\n', option, ...
           shift, window);
end

SPIKE_MATRIX = align_custom(spikes, shift, option, window / 2, ...
                            window / 2);

clear option shift window;

INFO.SPIKE_MATRIX = SPIKE_MATRIX;
%%
% Environment is finished loading. Run your scripts either here, in the
% command prompt, or in a dedicated framework (recommended).

