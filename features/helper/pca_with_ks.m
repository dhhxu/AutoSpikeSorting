function [features] = pca_with_ks(cutoff, max_coeff, spike_matrix)
% PCA_WITH_KS Select PCA coefficients using Lilliefor's modification of KS test.
%
% FEATURES = PCA_WITH_KS(CUTOFF, MAX_COEFF, SPIKE_MATRIX)
%
% Given spike waveform data in SPIKE_MATRIX, where rows are spikes and columns
% are samples, apply PCA. The number of coefficients selected is the minumum of
% the number of coefficients that represent at least CUTOFF variance and
% MAX_COEFF. Then the actual selection is done based on the Lilliefors
% modification of the Kolmogorov-Smirnov test. Note that the coefficients
% selected may not meet the CUTOFF variance parameter - that parameter is there
% to help automatically determine the number of coefficients to select.
%
% INPUT:
% CUTOFF        Number between 0 and 1 of the minimum total variance required
% MAX_COEFF     Maximum number of coefficients to select.
% SPIKE_MATRIX  MxN Numerical matrix of spike waveform data
%
% OUTPUT:
% FEATURES      Mx(number of coefficients selected) matrix of the PCA feature
%               representation of the spike data.

    pca_info = pca_apply(spike_matrix);
    nCoeff = pca_limit(pca_info.latent, cutoff, max_coeff);
    
    score_matrix = pca_info.score;
    indices = select_coeffs(score_matrix, nCoeff);
    features = score_matrix(:, indices);
    
end

function [best_coeff_indices] = select_coeffs(coeff_matrix, max_coeff)
% Use Lilliefors modification of KS test to calculate the best MAX_COEFF
% coefficients of COEFF_MATRIX. Returns the indices of the coefficients.

    ks_values = zeros(1, size(coeff_matrix, 2));
    
    for i = 1:size(coeff_matrix, 2)
        column = coeff_matrix(:, i);
        spread = 3 * std(column);
        max_threshold = mean(column) + spread;
        min_threshold = mean(column) - spread;
        
        valid_indices = column > min_threshold & column < max_threshold;
        valid_elements = coeff_matrix(valid_indices, i);
        
        if length(valid_elements) > max_coeff
            [~, ~, kstat] = lillietest(valid_elements);
            ks_values(i) = kstat;
        else
            ks_values(i) = 0;
        end
    end
    
    [~, ordered_coeff_indices] = sort(ks_values, 2, 'descend');
    best_coeff_indices = ordered_coeff_indices(1:max_coeff);

end