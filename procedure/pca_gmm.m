function class = pca_gmm(data, k)
% PCA_GMM Standard PCA features fitted to Gaussian Mixture Model
%
% CLASS = PCA_GMM(DATA, K)
%
% INFORMATION:
% Features:         First 3 principal components via PCA
% Algorithm:        EM + GMM
%
% INPUT:
% DATA      NxM matrix of spikes. Rows are spikes
% K         integer of number of clusters to partition DATA into
%
% OUTPUT:
% CLASS     Nx1 vector of integer class labels.
%
% See also PCA

%% Features

    features = pca_coeff(1, 3, data);

%% Clustering
    
    class = cluster(fitgmdist(features, k), features);
    
end

