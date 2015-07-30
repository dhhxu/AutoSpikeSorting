function class = gmm(data, k)
% GMM Gaussian Mixture Model algorithm
%
% CLASS = GMM(DATA, K)
%
% INPUT:
% DATA      NxM matrix of spikes. Rows are spikes
% K         integer of number of clusters to partition DATA into
%
% OUTPUT:
% CLASS     Nx1 vector of integer class labels.


%% Features

    features = pca_coeff(1, 3, data);

%% Clustering
    
    class = cluster(fitgmdist(features, k), features);
    
end

