function class = wtks_kmeans(info)
% WTKS_KMEANS wavelet transform features with k-means.
%
% CLASS = WTKS_KMEANS(INFO)
%
% Uses Quiroga's wavelet transform method. INFO contains spike waveform data and
% other variables of use. Default processing of the data is described below:
%
% Filter: bandpass filter with elliptic passband (300-3000 Hz)
% Detection: determined from TDT timestamps
% Extraction: Symmetric window of 32 samples corresponding to ~2.6 ms @~12.2 kHz
%
% Usage: save this file to a new function and give it a descriptive name.
%
% Features: Wavelet Transform coefficients selected via KS test
% Clustering: k-means
%
% INPUT:
% INFO      Struct containing spike data
%
% OUTPUT:
% CLASS     1-D vector of integer class labels
%
% See also INITIALIZE.

%% Step 1: Filtering

%% Step 2: Spike extraction and alignment

%% Step 3: Feature Extraction
    features = quiroga_wavelet(info.SPIKE_MATRIX);

%% Step 4: Clustering

    nc = preview_clusters(info.SPIKE_MATRIX);

    if nc
        class = kmeans(features, nc);
    else
        error('Invalid estimate entered');
    end

%% Step 5: Evaluation
% Put code for evaluating the quality of the clustering step.



%% Step 6: Additional Processing (if necessary)

%% Step 7: Visualization (optional)
% Please add the line 'opengl software' to your visualization scripts.


