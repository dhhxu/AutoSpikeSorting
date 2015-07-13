function class = wtks_kmeans(info)
% WTKS_KMEANS wavelet transform features with k-means.
%
% CLASS = WTKS_KMEANS(INFO)
%
% Uses Quiroga's wavelet transform method. INFO contains spike waveform data and
% other variables of use. Default processing of the data is described below:
%
% Filter: bandpass filter with elliptic passband (300-3000 Hz)
% Detection: determined from TDT timestamps
% Extraction: Symmetric window of 32 samples corresponding to ~2.6 ms @~12.2 kHz
%
% Usage: save this file to a new function and give it a descriptive name.
%
% Features: Wavelet Transform coefficients selected via KS test
% Clustering: k-means
%
% INPUT:
% INFO      Struct containing spike data
%
% OUTPUT:
% CLASS     1-D vector of integer class labels
%
% See also INITIALIZE.

%% Step 1: Filtering

%% Step 2: Spike extraction and alignment

%% Step 3: Feature Extraction
    features = quiroga_wavelet(info.SPIKE_MATRIX);

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

   draw_clusters(info.SPIKE_MATRIX, updated);
   
   for i = 1:K
      index = find(updated == i);
      isodist = isolation_distance(features, index);
      lr = l_ratio(features, index);
      fprintf('Quiroga WT: Isolation/Lratio for cluster %d: %2.2f/%2.2f\n', i, isodist, lr);
   end

%% Step 6: Additional Processing (if necessary)

%% Step 7: Visualization (optional)
% Please add the line 'opengl software' to your visualization scripts.


