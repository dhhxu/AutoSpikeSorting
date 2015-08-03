function class = sorter_kmeans(data, k)
% SORTER_KMEANS simple wrapper for Matlab's kmeans for use with automatic spike
% sorter.
%
% CLASS = SORTER_KMEANS(DATA, K)
%
% K-means clustering on matrix DATA, where rows are spikes.
%
% INPUT:
% DATA      NxM matrix of spike data. Rows are spikes.
% K         Positive integer greater than 1 of number of clusters
%
% OUTPUT:
% CLASS     Nx1 integer vector of class labels.

    class = kmeans(data, k);

end