function class = pca_kmeans(data, k, info)
% PCA_KMEANS baseline clustering procedure against which novel procedures are
% evaluated.
%
% CLASS = PCA_KMEANS(DATA, K, INFO)
%
% Baseline K-means clustering using PCA for features. Takes in spike information
% described in the INFO struct and outputs a CLASS vector of integer labels for
% each spike.
%
% Filter: bandpass filter with elliptic passband (300-3000 Hz)
% Detection: determined from TDT timestamps
% Extraction: Symmetric window of 32 samples corresponding to ~2.6 ms
% Features: First 3 PCA components
% Clustering: k-means, K determined by evalclusters
%
% INPUT:
% DATA      matrix of aligned spikes. Rows are spikes
% K         integer of number of clusters
% INFO      Struct containing spike data
%
% OUTPUT:
% CLASS     1-D vector of integer class labels

%% Features

    features = pca_coeff(1, 3, data);

%% Clustering


    if ~K
        error('Invalid estimate entered');
    end
    
    MAX_ITER = 20;
    for i = 1:MAX_ITER
        class = kmeans(features, K);
    end
    
end

