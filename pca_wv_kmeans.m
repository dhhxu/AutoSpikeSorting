function class = pca_wv_kmeans(info)
% PCA_WV_KMEANS same as PCA_KMEANS, but with wavelet filtering.
%
% CLASS = PCA_WV_KMEANS(INFO)
%
% Baseline K-means clustering using PCA for features. Takes in spike information
% described in the INFO struct and outputs a CLASS vector of integer labels for
% each spike. Uses wavelet filtering instead of bandpass filtering.
%
% Filter: wavelet filtering with 5 level decomposition corresponding to roughly
%         200 Hz cutoff
% Detection: determined from TDT timestamps
% Extraction: Symmetric window of 32 samples corresponding to ~2.6 ms
% Features: PCA with coefficents corresponding to at least 80% variance
% Clustering: k-means, K must be specified by user
%
% INPUT:
% INFO      Struct containing spike data
%
% OUTPUT:
% CLASS     1-D vector of integer class labels

%% Step 1: Filtering
    filtered = wavelet_filter(info.CHAN_DATA, 5);

%% Step 2: Spike extraction and alignment
    spikes = tdt_spikes(filtered, info.STRM_STRUCT, info.SNIP_STRUCT, ...
                        info.CHANNEL, info.WINDOW);

%% Step 3: Feature Extraction

    features = pca_coeff(.8, size(spikes, 2), spikes);

%% Step 4: Clustering

    nc = preview_clusters(spikes);

    if nc
        class = kmeans(features, nc);
    else
        error('Invalid estimate entered');
    end

%% Step 5: Evaluation
% Put code for evaluating the quality of the clustering step.

   draw_clusters(spikes, class);
   
   for i = 1:nc
      index = find(class == i);
      isodist = isolation_distance(features, index);
      fprintf('WV: Isolation distance for cluster %d: %2.2f\n', i, isodist);
   end

%% Step 6: Additional Processing (if necessary)

%% Step 7: Visualization (optional)
% Please add the line 'opengl software' to your visualization scripts.

    plotPca2d(features, class);


