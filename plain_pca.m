%% Shell for automated spike sorting algorithms
% The purpose of this function is to provide a base platform to make using and
% testing various methods for all the spike sorting steps easier.
% 
% To use this skeleton, change all occurrences of 'FILL' with the
% appropriate values. For example, you may need to add a string or a function
% statement. Then, save the skeleton to a descriptive file name for later
% use/modification. The skeleton itself need not be modified otherwise.
%
% The data is assumed to be from TDT, and the 'Load' section makes this
% assumption.
%
% In spike sorting, we cluster spikes belonging to a particular channel within
% a single tank. In principle, the skeleton could loop over all channels in all
% blocks for a given tank. As this may not be very fast, the skeleton is
% currently limited to clustering spikes on a single channel basis. However, it
% can be extended to handle other channels/blocks if so desired.
%
% In other words, run this script for a single tank, block, and channel.
%
% Note that the given steps are merely guidelines. Depending on the procedure,
% some steps may be unused or be invoked in a different order. Furthermore, the
% comments in each step are suggested ways of implementing that particular step.
% Please modify them to suit your particular needs.
%
% The ideal usage case would be a single function for all steps (excluding Steps
% 0 and 7), as this implies consistency in the output format across different
% functions for each step and fits the 'plug and play' intentions of this
% skeleton.

% function plain_pca

%% Step 0: Load paths and data
% Loads path, requisite for accessing external scripts and data.

ROOT = pwd;
TANK = 'AOS002';
BLOCK = 1;
CHANNEL = 1;

load_path(ROOT);

[strm_struct, snip_struct] = load_simple(TANK, BLOCK, ROOT);


%% Step 1: Filtering and preprocessing
% You should implement your filter and/or preprocessing methods as functions for
% ease of usage in this skeleton.
% Functions should generally be in the form:
%
%   processed_data = FUNCTION(data, ...)
%
% where DATA is raw spike voltage data and '...' signifies additional arguments
% specific to the function used. PROCESSED_DATA generally should be a one
% dimensional vector of the processed raw data.

% FILL
% processed_data = FUNCTION(data, ...);

chan = 1;

strm_data = strm_struct.data(1, :);

figure;
plot(strm_data);


strm_neo = neo_apply(strm_data, 1:length(strm_data));

figure;
plot(strm_neo);

%% Step 2: Spike detection
% You should implement your detection method as a function for ease of usage in
% this skeleton.
% The function should generally be in the form:
%
%   spike_indices = FUNCTION(processed_data, ...);
%
% where PROCESSED_DATA is the processed data from Step 1 and '...' signifies
% additional arguments specific to the function used. SPIKE_INDICES generally
% should be a one dimensional vector of indices of detected spike occurrences.

% FILL
% spike_indices = FUNCTION(processed_data, ...);


%% Step 3: Spike recovery
% You should implement your recovery method as a function for ease of usage in
% this skeleton.
% The function should generally be in the form:
%
%   spike_matrix = FUNCTION(spike_indices, ...);
%
% where SPIKE_INDICES is the vector of indices representing spike occurrences
% from Step 2 and '...' signifies additional arguments specific to the function
% used. SPIKE_MATRIX is generally a MxN matrix where M is the number of
% recovered spike waveforms and N is the number of samples in a waveform.

% FILL
% spike_matrix = FUNCTION(spike_indices, ...);


%% Step 4: Feature Extraction
% You should implement your feature extraction method as a function for ease of
% usage in this skeleton.
% The function should generally be in the form:
%
%   features = FUNCTION(spike_matrix, ...);
%
% where SPIKE_MATRIX is the MxN waveform matrix from Step 3 and '...' signifies
% additional arguments specific to the function used. Unlike previous steps,
% the format of the FEATURES output is up to you to define, as there are many
% ways to represent spike features.

% FILL
% features = FUNCTION(spike_matrix, ...);


%% Step 5: Clustering
% You should implement your clustering algorithm as a function for ease of
% usage in this skeleton.
% The function should generally be in the form:
%
%   classification = FUNCTION(features, ...);
%
% where FEATURES is the output derived from Step 4 and '...' signifies
% additional arguments specific to the function used. Similar to Step 4, the
% output CLASSIFICATION is dependent on the function and may require additional
% processing.
%
% Ideally, the post-processing step could be implemented within the
% clustering function so that CLASSIFICATION format will be consistent across
% different clustering functions.

% FILL
% classification = FUNCTION(features, ...);


%% Step 6: Additional Processing (if necessary)


%% Step 7: Visualization (optional)

opengl software