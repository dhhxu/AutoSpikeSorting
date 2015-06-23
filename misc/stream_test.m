%% Summary
% This script is intended to explore the raw stream and snippet data in a
% tank. Limited to one block and to one channel.

% Conclusions:
% STRM and PDEC are the same data but sampled at different rates. LPFS
% most likely is Local Field Potential data, which we do not focus on.

%% Globals & Setup
% Load other scripts
% Important one is TDT2mat.m
addpath(genpath('\\khri-ses.adsroot.itcs.umich.edu\ses\3Shared\Matlab Scripts\Superspiketrain'));
addpath(genpath('\\khri-ses.adsroot.itcs.umich.edu\ses\3Shared\Matlab Scripts\spiketrain'));
addpath(genpath('\\khri-ses.adsroot.itcs.umich.edu\ses\Daniel X\wave_clus_2.0wb'));

ROOT = fullfile('E:', 'AutoMaticSorter');

TANK_NAME = 'AOS002';
BLOCK = 1;
CHANNEL = 1;

addpath(genpath(ROOT));

TANK_PATH = fullfile(ROOT, TANK_NAME);

if ~exist(TANK_PATH, 'dir')
    error('Tank %s does not exist\n', TANK_NAME)
end

%% Load data.

try
    block_str = sprintf('Block-%d', BLOCK);
    % Get stream and snippet data only
    data = TDT2mat(TANK_PATH, block_str, 'Type', [ 3 4 ], 'Verbose', false);
    
catch
   error('[ERROR] Missing block: %d\n', BLOCK)
end

clear block_str

%% Get data structs.

strm_struct = data.streams.STRM;
snip_struct = data.snips.CSPK;

%% isolate channel, get other information.

strm_data = strm_struct.data(CHANNEL, :);

snip_chan_loc = snip_struct.chan == CHANNEL;
snip_data = snip_struct.data(snip_chan_loc, :);
snip_ts = snip_struct.ts(snip_chan_loc);        % Units in seconds

% snip_flat = reshape(snip_data', 1, []);

% Normalize the timestamps to begin at t = 0.
snip_ts_norm = snip_ts - snip_ts(1);

%% Load filter

FILTER = 'IIR_filter.mat';

try
    iir = load(FILTER);
catch
    error('Missing filter: %s\n', FILTER);    
end

clear FILTER

%% Filter data

% strm_filtered = filter(iir.IIR, strm_data);
strm_filtered = fix_filter(strm_data);

%% Window data
% Make a "video" displaying original data and bandpass filtered data
% side by side.

show_video = 0;             % 0: no video; 1: video

strm_fs = strm_struct.fs;

% TODO: handle remaining data in the last (incomplete) window.
strm_window_size = floor(strm_fs * 50 / 1000);

j = 1;

% constant for thresholding.
k = 7;

% indices of detected spikes/outliers
detected = [];

figure('Name', 'STRM_Comparison');
for i = 1:floor(length(strm_data) / strm_window_size)
    range = (1 + (i - 1) * strm_window_size):(i * strm_window_size);
    sd = std(abs(strm_filtered(range)));
    [idx, amp] = spike_detect(strm_filtered(range), k * sd);
    detected = [detected (idx + (i - 1) * strm_window_size)];
    
    if show_video
        subplot(2, 1, 1);
        plot(strm_filtered(range));
        hold on;
        plot(idx, amp, 'r.');
        hold off;
        xlim([0 strm_window_size]);
        title(sprintf('Raw STRM data, %2.2f s.d. threshold', k));

        subplot(2, 1, 2);
        intervals = interspike_interval(idx);
        histogram(intervals.', 50);
        title('STRM Interspike Intervals');
        drawnow;
        pause(0.02);
    end
end

if ~show_video
    close STRM_Comparison;
end

%% Comparison of thresholding scheme to snippet data.

figure('Name', 'detect');

detected_times = detected / strm_fs;

plot(detected_times, 'r');

hold on;
plot(snip_ts_norm.', 'b');
plot(snip_ts.', 'g');
hold off;

title(sprintf('Comparison of Snippet to Thresholding scheme of %2.2f s.d', k));
legend('Detected STRM spikes', 'TDT Snippets', 'TDT Snippets no norm', 'Location', 'southeast');
xlabel('Spike');
ylabel('Timestamp');
