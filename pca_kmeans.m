function class = pca_kmeans(info)
% PCA_KMEANS baseline clustering procedure against which novel procedures are
% evaluated.
%
% CLASS = PCA_KMEANS(INFO)
%
% Baseline K-means clustering using PCA for features. Takes in spike information
% described in the INFO struct and outputs a CLASS vector of integer labels for
% each spike.
%
% Filter: bandpass filter with elliptic passband (300-3000 Hz)
% Detection: determined from TDT timestamps
% Extraction: Symmetric window of 32 samples corresponding to ~1.3 ms
% Features: PCA with coefficents corresponding to at least 80% variance
% Clustering: k-means, K must be specified by user
%
% INPUT:
% INFO      Struct containing spike data
%
% OUTPUT:
% CLASS     1-D vector of integer class labels

%% Step 1: Filtering

%% Step 2: Spike extraction and alignment

%% Step 3: Feature Extraction

    features = pca_coeff(.8, size(info.SPIKE_MATRIX, 2), info.SPIKE_MATRIX);

%% Step 4: Clustering

    nc = preview_pca_clusters(info.SPIKE_MATRIX);

    if nc
        class = kmeans(features, nc);
    else
        error('Invalid estimate entered');
    end

%% Step 5: Evaluation
% Put code for evaluating the quality of the clustering step.

%    draw_clusters(info.SPIKE_MATRIX, class);
   
   updated = find_outliers(features, class, 3);
   
   
%    for i = 1:nc
%       index = find(class == i);
%       isodist = isolation_distance(features, index);
%       fprintf('Base: Isolation distance for cluster %d: %2.2f\n', i, isodist);
%    end
   
   

%% Step 6: Additional Processing (if necessary)

%% Step 7: Visualization (optional)
% Please add the line 'opengl software' to your visualization scripts.

    plotPca2d(features, class);

    plotPca2d(features, updated);
