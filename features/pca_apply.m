function [pca_info] = pca_apply(spike_matrix)
% PCA_APPLY Wrapper for pca() to return results in struct form.
%
% PCA_INFO = PCA_APPLY(SPIKE_MATRIX)
%
% Convenience function with the same behavior as pca(SPIKE_MATRIX). SPIKE_MATRIX
% is a MxN matrix with M spike waveforms spanning N samples. Returns the
% complete results of pca() in a struct. See pca() for more information on the
% struct fields.
%
% INPUT:
% VARARGIN          See pca() for input information
% 
% OUTPUT:
% PCA_INFO          Struct whose fields correspond to the output of pca()
%                   See pca() for information on the fields.

    pca_info = struct();
    [C, S, L, T, E, M] = pca(spike_matrix);
    
    pca_info.coeff = C;
    pca_info.score = S;
    pca_info.latent = L;
    pca_info.tsquared = T;
    pca_info.explained = E;
    pca_info.mu = M;

end