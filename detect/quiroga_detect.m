%% Summary
% This script attempts to replicate the spike detection method outlined in
% Quiroga 2004. After the signal is bandpass filtered, the threshold is
% automatically determined to be a constant multiple of the estimated standard
% deviation of the noise.

%% Globals & Setup
% Load other scripts
% Important one is TDT2mat.m

if load_path()
    error('Failed to load path!');
end

ROOT = fullfile('E:', 'AutoMaticSorter');
addpath(genpath(ROOT));

TANK_NAME = 'AOS002';
BLOCK = 1;
CHANNEL = 1;

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
strm_fs = strm_struct.fs;

snip_chan_loc = snip_struct.chan == CHANNEL;
snip_data = snip_struct.data(snip_chan_loc, :);
snip_ts = snip_struct.ts(snip_chan_loc);

% Normalize the timestamps to begin at t = 0.
snip_ts_norm = snip_ts - snip_ts(1);

clear snip_chan_loc

%% Use fix_filter function
% Source: WaveClus 2.0 (Quiroga)
% Bandpass filter 300 - 3000 Hz

if exist('fix_filter', 'file')
    strm_filtered = fix_filter(strm_data);
else
    error('Missing function: fix_filter\n');
end

%% Amplitude thresholding
% The filtered signal is broken up into 50 ms intervals. Within an interval,
% estimate the s.d. of the background noise.]
% Formula: sd_noise = median { |x| / 0.6745}
% Threshold: 4 * sd_noise
% Source: Quiroga 2004

show_video = 0;             % 0: no video; 1: video

% TODO: handle remaining data in the last (incomplete) window.
strm_window_size = floor(strm_fs * 50 / 1000);

% Constant for thresholding. Value of 4 used by Quiroga.
k = 4;

% indices of detected spikes/outliers
detected = [];

figure('Name', 'STRM_Comparison');
for i = 1:floor(length(strm_data) / strm_window_size)
    range = (1 + (i - 1) * strm_window_size):(i * strm_window_size);
    sd = median(abs(strm_filtered(range)) / 0.6745);
    
    [idx, amp] = spike_detect(strm_filtered(range), k * sd);
    detected = [detected (idx + (i - 1) * strm_window_size)];
    
    if show_video
        plot(strm_filtered(range));
        hold on;
        refline(0, k * sd);
        refline(0, - 1 * k * sd);
        plot(idx, amp, 'r.');
        hold off;
        xlim([0 strm_window_size]);
        
        drawnow;
        pause(0.02);
    end
end

if ~show_video
    close STRM_Comparison;
end

%% Recover spikes from indices

% Corresponds to roughly 2-3 ms window. Note that this is half a window. A full
% window spans 31 indices.
WINDOW = 15;

spike_matrix = [];

right_end = -1;

for i = 1:length(detected)
    w = (detected(i) - WINDOW):(detected(i) + WINDOW);
    if w(1) > right_end
        % Avoid overlaps -- detected indices may be part of the same spike
        right_end = w(end);
        spike_matrix = [ spike_matrix ; strm_filtered(w) ];
    end
end

%% Display recovered spikes

figure('Name', 'Recovered Spikes');
for i = 1:min(length(spike_matrix), length(snip_data))
    subplot(2, 1, 1);
    plot(spike_matrix(i, :));
    title('Quiroga Spikes');
    
    subplot(2, 1, 2);
    plot(snip_data(i, :));
    title('Snippet Spikes');
    
    drawnow;
    pause(0.02);
end

