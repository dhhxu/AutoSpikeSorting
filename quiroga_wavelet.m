%% Summary
% This script, given a block number and a channel number, finds the
% timestamps of spike occurrences and fetches the corresponding spike
% data in the stream. The window is about 2-3 ms.
% Next, the fetched spikes have WT applied on them. Then the 10 best
% wavelet coefficients are selected as per Quiroga 2004.

%% Globals & Setup
% Load other scripts
% Important one is TDT2mat.m
opengl software

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

clear snip_chan_loc

%% Associate snippet timestamp to stream data

% Use discrete values.
strm_idx = floor(snip_ts * strm_fs);

% This corresponds to a
% roughly 2.7 ms window size for the given sampling rate.
WINDOW = 32;

%% build the matrix of spike data in BLOCK and CHANNEL.

spike_matrix = get_spikes(strm_data, strm_idx, 32);

%% Wavelet decomposition (Quiroga 2004)

n = size(spike_matrix, 1);
s = size(spike_matrix, 2);

wavelet_coeff = zeros(n, s);
l_matrix = [];

LVL = 4;
WAVELET = 'haar';

for i = 1:length(spike_matrix)
    [c, l] = wavedec(spike_matrix(i, :), LVL, WAVELET);
    wavelet_coeff(i, 1:s) = c(1:s);
    l_matrix = vertcat(l_matrix, l); %#ok<AGROW>
    clear c l
end


%% Coefficent selection via modified KS test (Lillefors).
% Source: Wave_clus (Quiroga)

NUM_COEFF = 10;

for i = 1:s
    col = wavelet_coeff(:, i);
    thr = 3 * std(col);
    thr_min = mean(col) - thr;
    thr_max = mean(col) + thr;
    
    valid = wavelet_coeff((col > thr_min & col < thr_max), i);
    if length(valid) > NUM_COEFF;
        [ksstat] = test_ks(valid);
        [~, ~, k2] = lillietest(valid);
        sd(i) = ksstat; %#ok<*SAGROW>
        sd2(i) = k2;
    else
        sd(i) = 0;
        sd2(i) = 0;
    end
    clear thr_min thr_max thr col
end

[~, I] = sort(sd, 2, 'descend');
[~, I2] = sort(sd2, 2, 'descend');

% Indices of the coefficients to use.
coeffs(1:NUM_COEFF) = I(1:NUM_COEFF);
coeffs2(1:NUM_COEFF) = I2(1:NUM_COEFF);

%% plot

wavelet_coeff_reduced = wavelet_coeff(:, coeffs);

figure('Name', 'First 3 coefficients');
scatter3(wavelet_coeff_reduced(:, 1), wavelet_coeff_reduced(:, 2), wavelet_coeff_reduced(:, 3), 0.9);
% scatter(wavelet_coeff_reduced(:, 1), wavelet_coeff_reduced(:, 2), 0.9);
    
    
%% compare to PCA

[C, S, L] = pca(spike_matrix);

pca_coord = S(:, 1:3);

figure('Name', 'PCA');
% scatter3(pca_coord(:, 1), pca_coord(:, 2), pca_coord(:,3), 0.9);
scatter(pca_coord(:, 1), pca_coord(:, 2), 0.9);

%% PCA on aligned stream data

[Ca, Sa, La] = pca(align_spikes(spike_matrix, 10, 'neg', 'n', 2));
figure('Name', 'Aligned PCA');
scatter(Ss(:, 1), Ss(:, 2), 0.9);


%% PCA on snippet data

[Cs, Ss, Ls] = pca((snip_data));

figure('Name', 'Snip PCA');
scatter(Ss(:, 1), Ss(:, 2), 0.9);

%% test own alignment


plot_spikes(align_spikes(spike_matrix, 10, 'neg', 'n', 2));

%%
plot_spikes(align_simple(spike_matrix, 10, 'min'));
