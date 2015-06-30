function [nCoeff] = pca_limit(latent, totalVariance, maxCoeff)
% PCA_LIMIT Determine the number of principal coefficients to reach a target variance
%
% NCOEFF = PCA_LIMIT(LATENT, TOTALVARIANCE, MAXCOEFF)
%
% Returns the number of principal coefficients that account for at least
% TOTALVARIANCE variance. Uses LATENT as part of the calculations. MAXCOEFF is
% the upper bound on the number of coefficients returned by this function.
%
% INPUT:
% LATENT            Nx1 numeric vector of principal coefficient variances
% TOTALVARIANCE     Target variance desired. Should be a double between 0 and 1
% MAXCOEFF          Integer of maximum number of coefficients desired
%
% OUTPUT:
% NCOEFF            Positive integer of number of principal coefficients that
%                   account for at least TOTALVARIANCE variance

    if isempty(latent)
        error('Empty principal coefficient variance vector');
    elseif totalVariance > 1 || totalVariance < 0
        error('Invalid desired variance: %2.2f', totalVariance);
    elseif maxCoeff < 1
        error('Invalid coefficient count cutoff: %d', maxCoeff);
    end
    
    nCoeff = maxCoeff;

    cumulative = cumsum(latent) ./ sum(latent);
    for i = 1:length(cumulative)
        if cumulative(i) >= totalVariance
            if i < maxCoeff
                nCoeff = i;
            end
            return
        end
    end
end
