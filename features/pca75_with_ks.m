function [features] = pca75_with_ks(spike_matrix)
% PCA75_WITH_KS Select PCA coefficients using Lilliefor's modification of KS
% test modified for use with sorter program.
%
% FEATURES = PCA75_WITH_KS(SPIKE_MATRIX)
%
% Given spike waveform data in SPIKE_MATRIX, where rows are spikes and columns
% are samples, apply PCA. The number of coefficients selected is the minumum of
% the number of coefficients that represent at least 75% variance and
% 10 coefficents. Then the actual selection is done based on the Lilliefors
% modification of the Kolmogorov-Smirnov test. Note that the coefficients
% selected may not meet the 75% variance parameter - that parameter is there
% to help automatically determine the number of coefficients to select.
%
% INPUT:
% SPIKE_MATRIX  MxN Numerical matrix of spike waveform data
%
% OUTPUT:
% FEATURES      Mx(number of coefficients selected) matrix of the PCA feature
%               representation of the spike data.

    pca_info = pca_apply(spike_matrix);
    nCoeff = pca_limit(pca_info.latent, .75, 10);
    
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