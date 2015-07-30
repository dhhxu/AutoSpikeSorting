function [coeffs] = pca75(spikes)
% PCA75 get the coefficients that capture 75% of variance, capped at 10.
%
% COEFFS = PCA75(SPIKES)
%
% This is a wrapper for the PCA_COEFF function and serves as a generic handle to
% the sorter program. The coefficents returned either capture at least 75% of
% the variance or are capped at 10.
%
% INPUT:
% SPIKES    Matrix of spikes. Rows correspond to spikes.
%
% OUTPUT:
% COEFFS    Matrix of PCA coefficients.

    coeffs = pca_coeff(.75, 10, spikes);

end