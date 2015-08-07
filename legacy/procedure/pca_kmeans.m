function class = pca_kmeans(data, k)
% PCA_KMEANS baseline clustering procedure to evaluate novel procedures
% against.
%
% CLASS = PCA_KMEANS(DATA, K)
%
% INFORMATION:
% Features:         First 3 principal components via PCA
% Algorithm:        K-means
%
% INPUT:
% DATA      NxM matrix of spikes. Rows are spikes
% K         integer of number of clusters to partition DATA into
%
% OUTPUT:
% CLASS     Nx1 vector of integer class labels.
%
% See also PCA

%% Alignment
    aligned = data;

%% Features

    features = pca_coeff(1, 3, aligned);

%% Clustering
    
    class = kmeans(features, k);
    
end

