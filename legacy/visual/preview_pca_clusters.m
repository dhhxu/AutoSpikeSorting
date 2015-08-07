function nClusters = preview_pca_clusters(spike_matrix, dim)
% PREVIEW_PCA_CLUSTERS Get user estimate of number of clusters by showing plot
% of PCA projections.
%
% NCLUSTERS = PREVIEW_PCA_CLUSTERS(SPIKE_MATRIX)
%             Plot first two principal components.
%
% NCLUSTERS = PREVIEW_PCA_CLUSTERS(SPIKE_MATRIX, DIM)
%             Plot first DIM principal components. DIM is 2 or 3.
%
% Given spike waveform data in matrix SPIKE_MATRIX, where each row is a spike
% waveform, plot the first two principal components in 3D space (default).
% Then prompts the user to make an estimate on the number of possible clusters.
%
% Optionally, the DIM parameter controls the number of PCs to display. DIM must
% be either 2 or 3.
%
% Note that if the user hits 'cancel', NCLUSTERS will be returned as zero.
%
% INPUT:
% SPIKE_MATRIX  NxM matrix of spike waveform data, where rows are spikes
% DIM           (optional) integer (2 or 3) of number of PCs to display.
%               Default: 2
%
% OUTPUT:
% NCLUSTERS     User estimate of the number of clusters. Must be positive

    SetDefaultValue(2, 'dim', 2);

    pca_visual(spike_matrix, dim);
    
    prompt = {sprintf('Estimate of number of clusters')};
    numlines = 1;
    name = 'Estimate cluster count';
    def = {''};
    options.WindowStyle = 'normal';
    
    while true
        input = inputdlg(prompt, name, numlines, def, options);
        
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
            if dim == 2
                close('PCA 2D');
            elseif dim == 3
                close('PCA 3D');
            end

            return;
        end

    end

end