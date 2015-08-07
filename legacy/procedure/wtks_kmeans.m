function class = wtks_kmeans(data, k)
% WTKS_KMEANS wavelet transform features with k-means.
%
% CLASS = WTKS_KMEANS(INFO)
%
% Uses Quiroga's wavelet transform method. INFO contains spike waveform data and
% other variables of use. Default processing of the data is described below:
%
% Features: Wavelet Transform coefficients selected via KS test
% Clustering: k-means
%
% INPUT:
% INFO      Struct containing spike data
%
% OUTPUT:
% CLASS     1-D vector of integer class labels

%% Alignment


%% Features

    features = pca_with_ks(0.7, 10, data);

%% Clustering

    class = kmeans(features, k);


