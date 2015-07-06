function [wavelet_coeffs] = quiroga_wavelet(spike_matrix)
% QUIROGA_WAVELET wavelet transform of spikes via Quiroga's method (2004).
%
% WAVELET_COEFFS = QUIROGA_WAVELET(SPIKE_MATRIX)
%
% Implementation of Quiroga's feature extraction method of extracting wavelet
% coefficients via the Lilliefors modification of the Kolmogorov-Smirnov (KS)
% test. Applies this feature extraction method to the matrix of spike waveforms,
% SPIKE_MATRIX, where each row is a spike waveform, and the columns are waveform
% samples. Returns a matrix with the same number of rows as SPIKE_MATRIX and 10
% columns for the wavelet coefficients, as described in Quiroga 2004.
%
% Requires the Wavelet Toolbox.
%
% INPUT:
% SPIKE_MATRIX      MxN numeric matrix of spike waveforms
% 
% OUTPUT:
% WAVELET_COEFFS    Mx10 numeric matrix of KS test selected wavelet transform
%                   coefficients.
%
% Quiroga, R. Quian, Zoltan Nadasdy, and Yoram Ben-Shaul.
% "Unsupervised spike detection and sorting with wavelets and superparamagnetic
% clustering." Neural computation 16.8 (2004): 1661-1687.

    if ~exist('wavedec', 'file')
        error('Missing Wavelet toolbox');
    end

    if isempty(spike_matrix)
        error('Invalid spike matrix');
    end
    
    LEVEL = 4;
    WAVELET = 'haar';
    NUM_COEFF = 10;
    
    [n, p] = size(spike_matrix);
    
    coeff_matrix = zeros(n, p);
    
    for i = 1:n
        [C, ~] = wavedec(spike_matrix(i, :), LEVEL, WAVELET);
        coeff_matrix(i, 1:p) = C(1:p);
    end
    
    best_coeff_indices = select_coeffs(coeff_matrix, NUM_COEFF);
    
    wavelet_coeffs = coeff_matrix(:, best_coeff_indices(1:10));

end

function [best_coeff_indices] = select_coeffs(coeff_matrix, max_coeff)
% Use Lilliefors modification of KS test to calculate the best MAX_COEFF
% coefficients of COEFF_MATRIX.

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
