function pca_kmeans
% PCA_KMEANS baseline clustering procedure against which novel procedures are
% evaluated.
%
% Filter: bandpass filter with elliptic passband (300-3000 Hz)
% Detection: determined from TDT timestamps
% Extraction: Symmetric window of 32 samples corresponding to ~1.3 ms
% Features: PCA with coefficents corresponding to at least 80% variance
% Clustering: k-means, K must be specified by user

%% Constants
% Put your constants here for convenience.

% For bandpass filtering
FILTER_LOW = 300;
FILTER_HIGH = 3000;

% For recovery
WINDOW = 32;

% Alignment
MAX_SHIFT = 10;

% For k-means clustering.
NUM_CLUSTERS = 2;

%% Step 1: Filtering

processed_data = bpf(STRM_DATA, FILTER_LOW, FILTER_HIGH, STRM_STRUCT.fs * 2);

%% Step 2: Spike extraction and alignment

spikes = tdt_spikes(processed_data, STRM_STRUCT, SNIP_STRUCT, CHANNEL, ...
               WINDOW);
spike_matrix = align_custom(spikes, MAX_SHIFT, 'min', WINDOW / 2, ...
                            WINDOW / 2);

%% Step 4: Feature Extraction

features = pca_coeff(.8, size(spike_matrix, 2), spike_matrix);

%% Step 5: Clustering
class = kmeans(features, NUM_CLUSTERS);

%% Step 6: Evaluation
% Put code for evaluating the quality of the clustering step.

clusters = separate_clusters(spike_matrix, class);

for i = 1:NUM_CLUSTERS
    plot_spikes_with_mean(clusters{i}, 'r');
end

%% Step 7: Additional Processing (if necessary)

%% Step 8: Visualization (optional)
% Please add the line 'opengl software' to your visualization scripts.

plotPca2d(features, class);


