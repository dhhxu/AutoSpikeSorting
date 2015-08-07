function [averageWaveform] = get_mean_spike(cluster_matrix)
% GET_MEAN_SPIKE calculate the mean spike template from a spike cluster
%
% AVERAGEWAVEFORM = GET_MEAN_SPIKE(CLUSTER_MATRIX)
%
% Given a matrix CLUSTER_MATRIX of spikes from a cluster resulting from some
% clustering algorithm, generate the average spike waveform from the spikes in
% that cluster. Returns the average spike AVERAGEWAVEFORM.

    if isempty(cluster_matrix)
        error('Invalid cluster matrix');
    end
    
    averageWaveform = mean(cluster_matrix, 1);
end