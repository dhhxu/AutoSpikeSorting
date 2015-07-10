function class = pca_em(info)
% PCA_EM Standard PCA features with EM clustering using GMM.
%
% CLASS = PCA_EM(INFO)
%
% Template for spike sorting algorithms. INFO contains spike waveform data and
% other variables of use. Default processing of the data is described below:
%
% Filter: bandpass filter with elliptic passband (300-3000 Hz)
% Detection: determined from TDT timestamps
% Extraction: Symmetric window of 32 samples corresponding to ~2.6 ms @~12.2 kHz
%
% Features: PCA, scores with 80% variance
% Clustering: EM with Gaussian Mixture Model
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


%% Step 4: Clustering


%% Step 5: Evaluation
% Put code for evaluating the quality of the clustering step.



%% Step 6: Additional Processing (if necessary)

%% Step 7: Visualization (optional)
% Please add the line 'opengl software' to your visualization scripts.


