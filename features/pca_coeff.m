function [coefficients] = pca_coeff(cutoff, max_coeff, varargin)
% PCA_COEFF Returns a subset of the score matrix to be used as features
%
% COEFFICIENTS = PCA_COEFF(CUTOFF, MAX_COEFF, ...)
%
% Run PCA with standard arguments represented by ... (see pca() for information
% on input arguments. Returns the principal component score coefficients for
% use in later clustering algorithms. The coefficients returned must comprise at
% least CUTOFF variance of the data. The number of coefficients actually
% returned will be at most MAX_COEFF.
%
% Note the minimum number of coefficients returned is 3, for ease of use
% with feature space plotter functions.
%
% INPUT:
% CUTOFF        Postive number between 0 and 1 for the desired variance
% MAX_COEFF     Positive integer of maximum number of score coefficients desired
% ...           See pca() for information on input parameters
%
% OUTPUT:
% COEFFICIENTS  MxC matrix, where each row is the representation of the waveform
%               in PCA space. C is at most MAX_COEFF.

    pca_info = pca_apply(varargin{1:end});
    nCoeff = pca_limit(pca_info.latent, cutoff, max_coeff);
%     fprintf('number of coefficients selected: %d\n', nCoeff);

    if nCoeff < 3
        nCoeff = 3;
    end

    coefficients = pca_info.score(:, 1:nCoeff);
end