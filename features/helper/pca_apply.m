function [pca_info] = pca_apply(varargin)
% PCA_APPLY Wrapper for pca() to return results in struct form.
%
% PCA_INFO = PCA_APPLY(...)
%
% Convenience function with the same behavior as pca(). This is identical to the
% pca() function except it returns a struct instead of a vector. This is to keep
% the workspace clean.
%
% INPUT:
% ...          See pca() for information on input arguments
% 
% OUTPUT:
% PCA_INFO     Struct whose fields correspond to the output of pca().
%              See pca() for information on the fields

    pca_info = struct();
    [C, S, L, T, E, M] = pca(varargin{1:end});
    
    pca_info.coeff = C;
    pca_info.score = S;
    pca_info.latent = L;
    pca_info.tsquared = T;
    pca_info.explained = E;
    pca_info.mu = M;

end