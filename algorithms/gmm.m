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
    
    class = cluster(fitgmdist(data, k), data);
    
end

