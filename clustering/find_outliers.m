function [updated_class] = find_outliers(feature_matrix, class, threshold)
% FIND_OUTLIERS assign outlier spikes to noise cluster.
%   UPDATED_CLASS = FIND_OUTLIERS(FEATURE_MATRIX, CLASS) Remove spikes that are
%   more than 2 s.d. from mean cluster spike in feature space by assigning them
%   to zero class.
%
%   UPDATED_CLASS = FIND_OUTLIERS(FEATURE_MATRIX, CLASS, THRESHOLD) Custom
%   threshold.
%
% Given a feature representation of spike waveform data stored in matrix
% FEATURE_MATRIX and the class labels CLASS for each waveform, identify, for
% each cluster, the spikes whose distance exceed THRESHOLD times the standard
% deviation of the mean feature spike. Then assign the found spikes to a noise
% cluster. The result will be a new class vector, similar to the original CLASS
% vector, except the noise spikes will be given the zero class;
%
% As an example, if CLASS has two labels, the UPDATED_CLASS will have three
% labels, the third being the noise cluster label.
%
% INPUT:
% FEATURE_MATRIX    NxF matrix of waveform feature representation.
% CLASS             Nx1 vector of integer class labels)
% THRESHOLD         (optional) Integer of the scaling factor. The threshold is
%                   set to THRESHOLD * standard deviation. (Default: 2)
% OUTPUT:
% UPDATED_CLASS     Nx1 vector where outlier spikes' class is set to a new
%                   class. This new class is set to 0;

    SetDefaultValue(3, 'threshold', 2);

    [nSpikes, nFeatures] = size(feature_matrix);
    
    feature_clusters = separate_clusters(feature_matrix, class);
    nClusters = length(feature_clusters);
    
    % Matrix holding feature cluster centers.
    f_means = zeros(nClusters, nFeatures);
    
    % Array holding standard deviation of distance for each cluster
    f_sds = zeros(nClusters, 1);
    
    for i = 1:nClusters
        m = feature_clusters{i};
        f_mean = get_mean_spike(m);
        f_means(i, :) = f_mean;
        
        D = pdist2(m, f_mean);
        f_sds(i) = std(D);
    end
    
    updated_class = class;
    
    for j = 1:nSpikes
        spike_class = class(j);
        spike = feature_matrix(j, :);
        
        class_mean = f_means(spike_class, :);
        
        d = pdist2(spike, class_mean);
        
        sd = f_sds(spike_class);
        
        if d > threshold * sd
            % outlier
            updated_class(j) = 0;
        end
    end
end