%% Summary
% This script, given a block number and a channel number, finds the
% timestamps of spike occurrences and fetches the corresponding spike
% data in the stream. The window is about 2-3 ms.

%% Globals & Setup
% Load other scripts
% Important one is TDT2mat.m
if load_path()
    error('Failed to load path!');
end

ROOT = fullfile('E:', 'AutoMaticSorter');

TANK_NAME = 'AOS002';
BLOCK = 1;
CHANNEL = 1;

addpath(genpath(ROOT));

%% Load data.

[status, data] = load_simple(TANK_NAME, BLOCK, ROOT);

if status
    error('Error in load_simple. Check warning messages.');
end

%% Get data structs.

strm_struct = data.streams.STRM;
snip_struct = data.snips.CSPK;

%% isolate channel, get other information.

strm_data = strm_struct.data(CHANNEL, :);
strm_fs = strm_struct.fs;                       % Sample rate (Hz)

snip_chan_loc = snip_struct.chan == CHANNEL;
snip_data = snip_struct.data(snip_chan_loc, :);
snip_ts = snip_struct.ts(snip_chan_loc);        % Units in seconds

%% Associate snippet timestamp to stream data

% Use discrete values.
strm_idx = floor(snip_ts * strm_fs);

% 2 ms window -- this is half of the window!
window = floor(1 / 1000 * strm_fs);

% The TDT snippet data uses a 30 sample window. This corresponds to a
% roughly 2-3 ms window size for the given sampling rate.
WINDOW = 15;

%% Plot spike video, compare stream to snippet.
% Also build the matrix of spike data in BLOCK and CHANNEL.

show_video = 0;

spike_matrix = zeros(length(strm_idx), 2 * WINDOW + 1);

for i = 1:length(strm_idx)
    interval = (strm_idx(i) - WINDOW):(strm_idx(i) + WINDOW);

    if interval(1) >= 1 && interval(end) <= length(strm_data)
        % Avoid out of bound vector access (ideally should not occur).
        spike_matrix(i, :) = strm_data(interval);
        
        if show_video
            figure('Name', 'Stream Spikes'); %#ok<UNRCH>
            subplot(2, 1, 1); 
            plot(strm_data(interval));
            title('Stream data');

            subplot(2, 1, 2);
            plot(snip_data(i, :), 'r');
            title('Snippet data');
            
            suptitle(sprintf('Spikes from Block %d, Channel %d', BLOCK, CHANNEL));
            drawnow;
            pause(0.02);
        end
    end
end

%% try band pass filtering spikes -- uses Quiroga's fix_filter method.

spike_matrix_f = zeros(length(strm_idx), 2 * WINDOW + 1);

for i = 1:length(spike_matrix)
    spike_matrix_f(i, :) = fix_filter(spike_matrix(i, :));
end

show_video_2 = 1;

if show_video_2
   figure('Name', 'filtered spikes');
   for i = 1:length(spike_matrix_f)
       subplot(3, 1, 1);
       plot(spike_matrix(i, :));
       title('Stream spikes');
       
       subplot(3, 1, 2);
       plot(spike_matrix_f(i, :));
       title('Filtered spikes');
       
       subplot(3, 1, 3);
       plot(snip_data(i, :), 'r');
       title('Snippet data');
       
       drawnow;
       pause(0.02);
   end
end

%% Compare Quiroga's filter to custom designed one by fdatool

FILTER = 'IIR_filter.mat';

try
    iir = load(FILTER);
catch
    error('Missing filter: %s\n', FILTER);    
end

%% Filter using our filter

spike_matrix_custom = zeros(length(strm_idx), 2 * WINDOW + 1);

for i = 1:length(spike_matrix)
    spike_matrix_custom(i, :) = filter(iir.IIR, spike_matrix(i, :));
end

%% Actual comparison between filters.
% Note that Quiroga's filter is faster than the custom one.

figure('Name', 'Filter comparison');

for i = 1:length(spike_matrix_custom)
    subplot(2, 1, 1);
    plot(spike_matrix_custom(i, :));
    subplot(2, 1, 2);
    plot(spike_matrix_f(i, :), 'r');
    
    drawnow;
    pause(0.02);
end

suptitle('Filter comparison');
legend('Custom', 'Quiroga', 'Location', 'southeast');