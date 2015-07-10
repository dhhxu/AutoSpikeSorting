function [updated_class] = find_outliers(feature_matrix, class, threshold)
% FIND_OUTLIERS assign outlier spikes to noise cluster.
%
% UPDATED_CLASS = FIND_OUTLIERS(SPIKE_MATRIX,CLASS, THRESHOLD)
%
% Given a feature representation of spike waveform data stored in matrix
% FEATURE_MATRIX and the class labels CLASS for each waveform, identify, for
% each cluster, the spikes whose distance exceed THRESHOLD times the standard
% deviation of the mean feature spike. Then assign the found spikes to a noise
% cluster. The result will be a new class vector, similar to the original CLASS
% vector, except the noise spikes will be given a new class (-1);
%
% As an example, if CLASS has two labels, the UPDATED_CLASS will have three
% labels, the third being the noise cluster label.
%
% INPUT:
% FEATURE_MATRIX    NxF matrix of waveform feature representation.
% CLASS             Nx1 vector of integer class labels)
% THRESHOLD         Integer of the scaling factor. The threshold is set to
%                   THRESHOLD * standard deviation.
% OUTPUT:
% UPDATED_CLASS     Nx1 vector where outlier spikes' class is set to a new
%                   class. This new class is set to -1;
    
    feature_clusters = separate_clusters(feature_matrix, class);
    nClusters = length(feature_clusters);
    
    % Array holding feature cluster centers.
    f_means = zeros(nClusters, 1);
    
    % Array holding standard deviation of distance for each cluster
    f_sds = zeros(nClusters, 1);
    
    for i = 1:nClusters
        m = feature_clusters{i};
        f_mean = get_mean_spike(m);
        
        % N x 1 vector of distances between cluster points and center
        D = pdist2(m, f_mean);
        
        f_sds(i) = std(D);
        
    end
    
    updated_class = class;
    
    nSpikes = size(feature_matrix, 1);
    
    for j = 1:nSpikes
        spike_class = class(j);
        spike = feature_matrix(j, :);
        
        class_mean = f_means(spike_class);
        
        d = pdist2(spike, class_mean);
        
        sd = f_sds(spike_class);
        
        if d > threshold * sd
            % outlier
            updated_class(j) = -1;
        end
    end
end