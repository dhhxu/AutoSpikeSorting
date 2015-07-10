function [] = draw_clusters(spike_matrix, class)
% DRAW_CLUSTERS plot identified clusters and their mean spike.
%
% DRAW_CLUSTERS(SPIKE_MATRIX, CLASS)
%
% Given spike waveforms in matrix SPIKE_MATRIX and the classification vector
% CLASS generated by some clustering procedure, plot the identified clusters 
% and their mean spikes.
%
% INPUT:
% SPIKE_MATRIX  NxM matrix, rows are spikes
% CLASS         1-D integer vector of the cluster assignments
%
% OUTPUT:
% NONE

    if isempty(spike_matrix)
        error('Invalid spike matrix');
    elseif isempty(class)
        error('Invalid class vector');
    elseif size(spike_matrix) ~= length(class)
        error('Dimension mismatch between spike matrix and class vector');
    end
    
    draw_clusters_core(spike_matrix, class);

end

function [] = draw_clusters_core(spike_matrix, class)

    clusters = separate_clusters(spike_matrix, class);
    nClusters = length(unique(class));
    
    for i = 1:nClusters
        plot_spikes_with_mean(clusters{i}, 'r');
    end

end