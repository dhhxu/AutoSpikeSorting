function [clusters] = separate_clusters(spike_matrix, class)
% SEPARATE_CLUSTERS Divide spikes into their respective clusters
%
% CLUSTERS = SEPARATE_CLUSTERS(SPIKE_MATRIX, CLASS)
%
% Given a cluster assignment vector CLASS, split the waveform matrix
% SPIKE_MATRIX into individual matrices, one for each unique cluster identified.
%
% INPUT:
% SPIKE_MATRIX  MxN numeric matrix of detected spike waveforms. Each row
%               corresponds to a detected spike, and the columns correspond to
%               samples.
% CLASS         Mx1 integer vector containing the cluster assignment for each
%               spike waveform.

    if isempty(spike_matrix)
        error('Invalid spike matrix');
    elseif isempty(class)
        error('Invalid class vector');
    elseif length(class) ~= length(spike_matrix)
        error('Class vector is not same length as spike matrix');
    end
    
    clusters = separate(spike_matrix, class);

end

function [clusters] = separate(spike_matrix, class)
    numClasses = length(unique(class));
    clusters = cell(1, numClasses);
    freeRow = ones(1, numClasses);
    
    for i = 1:numClasses
        nRows = sum(class == i);
        nCols = size(spike_matrix, 2);
        clusters{i} = zeros(nRows, nCols);
    end
    
    for i = 1:length(spike_matrix)
        cls = class(i);
        spike = spike_matrix(i, :);
        rowIndex = freeRow(cls);
        clusters{cls}(rowIndex, :) = spike;
        freeRow(cls) = rowIndex + 1;
    end

end