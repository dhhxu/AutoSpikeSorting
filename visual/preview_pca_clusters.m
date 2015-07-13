function nClusters = preview_pca_clusters(spike_matrix)
% PREVIEW_PCA_CLUSTERS Get user estimate of number of clusters by showing 2D
% plot of first 2 principal components.
%
% NCLUSTERS = PREVIEW_PCA_CLUSTERS(SPIKE_MATRIX)
%
% Given spike waveform data in matrix SPIKE_MATRIX, where each row is a spike
% waveform, plot the first three principal components in 3D space. Then prompts
% the user to make an estimate on the number of possible clusters.
%
% Note that if the user hits 'cancel', NCLUSTERS will be returned as zero.
%
% INPUT:
% SPIKE_MATRIX  NxM matrix of spike waveform data, where rows are spikes
%
% OUTPUT:
% NCLUSTERS     User estimate of the number of clusters. Must be positive

    pca_visual(spike_matrix, 2);
    
    prompt = {sprintf('Estimate of number of clusters')};
    numlines = 1;
    name = 'Estimate cluster count';
    
    while true
        input = inputdlg(prompt, name, numlines);
        
        if isempty(input)
           warning('No estimate entered. Returning 0'); 
           nClusters = 0;
           return;
        end
        
        [nClusters, status] = str2num(input{1});
        if ~status || nClusters < 1
            warning('Invalid estimate entered: %s', input{1});
            continue;
        else
            fprintf('Number of selected clusters: %d\n', nClusters);
            close('PCA 2D');
            return;
        end
    end

end