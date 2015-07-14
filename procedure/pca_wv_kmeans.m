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

%     features = pca_coeff(.8, size(spikes, 2), spikes);
    features = pca_coeff(1, 3, spikes);

%% Step 4: Clustering

    K = preview_pca_clusters(features);

    if ~K
        error('Invalid estimate entered');
    end
    
    MAX_ITER = 20;
    total = 0;
    totaldn = 0;
    for i = 1:MAX_ITER
        class = kmeans(features, K);
        updated = find_outliers(features, class, 2);
        actual = features(updated > 0, :);
        value = db_index(actual, updated(updated > 0));
        dn = indexDN(actual, updated(updated>0));
        total = total + value;
        totaldn = totaldn + dn;
    end
    
    fprintf('db index: %2.2f; dn index: %2.2f\n', total / MAX_ITER, ...
             totaldn / MAX_ITER);

%% Step 5: Evaluation
% Put code for evaluating the quality of the clustering step.

   draw_clusters(spikes, updated);
   
   for i = 1:K
      index = find(updated == i);
      isodist = isolation_distance(features, index);
      lr = l_ratio(features, index);
      fprintf('WFilter + base: Isolation/Lratio for cluster %d: %2.2f/%2.2f\n', i, isodist, lr);
   end
   
   

%% Step 6: Additional Processing (if necessary)

%% Step 7: Visualization (optional)
% Please add the line 'opengl software' to your visualization scripts.



