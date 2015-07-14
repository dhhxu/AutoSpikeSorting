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
% Extraction: Symmetric window of 32 samples corresponding to ~2.6 ms
% Features: First 3 PCA components
% Clustering: k-means, K determined by evalclusters
%
% INPUT:
% INFO      Struct containing spike data
%
% OUTPUT:
% CLASS     1-D vector of integer class labels
%
% See also EVALCLUSTERS

%% Features

    features = pca_coeff(1, 3, info.SPIKE_MATRIX);

%% Clustering

    K = preview_pca_clusters(info.SPIKE_MATRIX);

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
    
end

