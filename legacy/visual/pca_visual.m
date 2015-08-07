function [] = pca_visual(spike_matrix, dim)
% PCA_VISUAL Visualize the principal components to assist in determining
% the number of clusters by hand.
%
% PCA_VISUAL(SPIKE_MATRIX, DIM)
%
% Given spike waveform data SPIKE_MATRIX, where rows are spikes and columns are
% samples, plot the first three principal components (via PCA) in DIM-D space.
% This aims to assist in 'eyeballing' the data to determine the number of
% clusters present, which is required for some clustering algorithms such as
% k-means
%
% INPUT:
% SPIKE_MATRIX  NxM matrix, rows are spikes
% DIM           Integer of number of dimensions to plot. Either 2 or 3.
% 
% OUTPUT:
% NONE

    if isempty(spike_matrix)
        error('Invalid spike matrix');
    end
    
    pca_info = pca_apply(spike_matrix);
    
    if dim == 2 || dim == 3
        cmd = sprintf('plotPca%dd(pca_info.score)', dim);
        eval(cmd);
    else
        error('Dim must be 2 or 3');
    end

end