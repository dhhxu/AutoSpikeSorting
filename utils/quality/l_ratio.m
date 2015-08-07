function [lratio] = l_ratio(feature_matrix, cluster_indices)
% L_RATIO calculate L-ratio cluster evaluation metric.
%
% LRATIO = L_RATIO(FEATURE_MATRIX, CLUSTER_INDICES)
%
% Compute the L-ratio for the cluster c. All spikes are represented in feature
% space described by a NxF FEATURE_MATRIX, where rows are spikes, and the
% feature space is F-dimensional. The cluster c is described by a vector of
% indices into FEATURE_MATRIX.
%
% This metric is derived from Schmitzer-Torbert's 2005 paper. Lratio is
% positively correlated with Type II errors (false omissions). Should be used in
% conjunction with Isolation Distance to evaluate clustering quality. Lower
% Lratio and higher Isolation Distance together indicate better cluster quality.
%
% INPUT:
% FEATURE_MATRIX    NxF matrix of feature vectors of spike waveforms. The
%                   feature space is F-dimensional.
% CLUSTER_INDICES   1D vector of indices into FEATURE_MATRIX that correspond to
%                   spikes in the cluster to be evaluated.
%
% OUTPUT:
% LRATIO            The L-ratio cluster quality measure.
%
% Schmitzer-Torbert, N., Jackson, J., Henze, D., Harris, K., & Redish, A. D.
% (2005). Quantitative measures of cluster quality for use in extracellular
% recordings. Neuroscience, 131(1), 1-11.

    if isempty(feature_matrix)
        error('Invalid feature matrix');
    elseif isempty(cluster_indices)
        error('Invalid cluster index vector');
    end
    
    lratio = l_ratio_core(feature_matrix, cluster_indices);
    
end

function [lratio] = l_ratio_core(feature_matrix, cluster_indices)
    
    [N, F] = size(feature_matrix);
    
    % cluster spike count
    nc = length(cluster_indices);
    % non cluster spikes
    others = setdiff(1:N, cluster_indices);
    % Mahal distance of all spikes from cluster c center
    D = mahal(feature_matrix, feature_matrix(cluster_indices, :));
    p = 1 - chi2cdf(D(others), F);
    lratio = sum(p) / nc;
    
end