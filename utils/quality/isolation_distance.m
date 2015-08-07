function [iso_dist] = isolation_distance(feature_matrix, cluster_indices)
% ISOLATION_DISTANCE Calculate the isolation distance of a cluster.
%
% ISO_DIST = ISOLATION_DISTANCE(FEATURE_MATRIX, CLUSTER_INDEX)
%
% Cluster quality metric computing how isolated a cluster is from non-cluster
% points. All spikes are represented in feature space described by a NxF
% FEATURE_MATRIX, where rows are spikes, and the feature space is F-dimensional.
% The cluster c is described by a vector of indices into FEATURE_MATRIX.
%
% Note that the number of points in any given cluster must not exceed half of
% the total number of points. If this occurs, NaN is returned.
%
% The metric comes from Schmitzer-Torbert's 2005 paper. Isolation distance is
% negatively correlated with Type I errors (false positives). High isolation
% distance with low L-ratio indicates better cluster quality.
%
% INPUT:
% FEATURE_MATRIX    NxF matrix of N waveforms with F dimensions
% CLUSTER_INDICES   Mx1 vector of indices of the cluster to evaluate isolation
%                   distance for.
%
% OUTPUT:
% ISO_DIST          Isolation distance. If conditions do not hold, will be -1.
%
% Schmitzer-Torbert, N., Jackson, J., Henze, D., Harris, K., & Redish, A. D.
% (2005). Quantitative measures of cluster quality for use in extracellular
% recordings. Neuroscience, 131(1), 1-11.

    if isempty(feature_matrix)
        error('Invalid feature matrix');
    elseif isempty(cluster_indices)
        error('Invalid cluster index vector');
    end
    
    iso_dist = iso_dist_core(feature_matrix, cluster_indices);

end

function dist = iso_dist_core(feature_matrix, cluster_indices)
    dist = -1;
    nc = length(cluster_indices);
    others = setdiff(1:size(feature_matrix, 1), cluster_indices);
    
    if nc > length(others)
        warning('Cannot calculate isolation distance. Nc too large');
        return;
    end
    
    D = mahal(feature_matrix, feature_matrix(cluster_indices, :));
    
    other_distances = D(others);
    sorted = sort(other_distances);
    
    dist = sorted(nc);

end

