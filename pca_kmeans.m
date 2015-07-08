function pca_kmeans
% PCA_KMEANS baseline clustering procedure against which novel procedures are
% evaluated.
%
% Filter: bandpass filter with elliptic passband (300-3000 Hz)
% Detection: determined from TDT timestamps
% Extraction: Symmetric window of 32 samples corresponding to ~1.3 ms
% Features: PCA with coefficents corresponding to at least 80% variance
% Clustering: k-means, K must be specified by user


%% Step 1: Filtering

%% Step 2: Spike extraction and alignment

%% Step 4: Feature Extraction

    features = pca_coeff(.8, size(SPIKE_MATRIX, 2), SPIKE_MATRIX);

%% Step 5: Clustering

    nc = preview_clusters(SPIKE_MATRIX);

    if nc
        class = kmeans(features, nc);
    else
        error('Invalid estimate entered');
    end

%% Step 6: Evaluation
% Put code for evaluating the quality of the clustering step.

    clusters = separate_clusters(spike_matrix, class);

    for i = 1:nc
        plot_spikes_with_mean(clusters{i}, 'r');
    end

%% Step 7: Additional Processing (if necessary)

%% Step 8: Visualization (optional)
% Please add the line 'opengl software' to your visualization scripts.

    plotPca2d(features, class);


