function [coefficients] = pca_coeff(spike_matrix, cutoff, max_coeff)
% PCA_COEFF Returns a subset of the score matrix to be used as features
%
% COEFFICIENTS = PCA_COEFF(SPIKE_MATRIX, CUTOFF, MAX_COEFF)
%
% Run PCA on the data matrix SPIKE_MATRIX and return the principal component
% score coefficients for use in later clustering algorithms. The coefficients
% returned must comprise at least CUTOFF variance of the data. The number of
% coefficients actually returned will be at most MAX_COEFF.
%
% INPUT:
% SPIKE_MATRIX  MxN numeric matrix with M spike waveforms of length N
% CUTOFF        Postive number between 0 and 1 for the desired variance
% MAX_COEFF     Positive integer of maximum number of score coefficients desired
%
% OUTPUT:
% COEFFICIENTS  MxC matrix, where each row is the representation of the waveform
%               in PCA space. C is at most MAX_COEFF.

    pca_info = pca_apply(spike_matrix);
    nCoeff = pca_limit(pca_info.latent, cutoff, max_coeff);
    coefficients = pca_info.score(:, 1:nCoeff);
end