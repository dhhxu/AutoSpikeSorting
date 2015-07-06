function [] = pca_visual(spike_matrix)
% PCA_VISUAL Visualize the first 3 principal components to assist in determining
% the number of clusters by hand.
%
% PCA_VISUAL(SPIKE_MATRIX)
%
% Given spike waveform data SPIKE_MATRIX, where rows are spikes and columns are
% samples, plot the first three principal components (via PCA) in 3D space. This
% aims to assist in 'eyeballing' the data to determine the number of clusters
% present, which is required for some clustering algorithms such as k-means.

    if isempty(spike_matrix)
        error('Invalid spike matrix');
    end
    
    pca_info = pca_apply(spike_matrix);
    plotPca3d(pca_info.score);

end