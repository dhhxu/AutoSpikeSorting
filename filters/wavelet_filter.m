function [filtered] = wavelet_filter(data, max_level)
% wavelet_filter high pass filter of data using wavelet transform
%
% FILTERED = WAVELET_FILTER(DATA, MAX_LEVEL)
%
% High pass filter using wavelets. The code is adapted from Wiltschko's
% wavelet filtering method. Filters raw data DATA using MAX_LEVEL level wavelet
% decomposition using default Daubechies(4) mother wavelet as described in
% Wiltschko's paper.
%
% Notable changes: The code has been adapted from the tetrode case to a single
% electrode case.
%
% INPUT:
% DATA      1xM matrix of continuous recorded raw data
% MAX_LEVEL Integer of the level of decomposition on the data. This integer
%           implicitly defines the cutoff frequency of the filter.
%           Specifically, cutoff = sampling rate / (2 ^(max_level + 1))
%
% OUTPUT:
% FILTERED  1xM matrix of the filtered data
%
% Wiltschko AB, Gage GJ, Berke JD (2008). Wavelet filtering before spike
% detection preserves waveform shape and enhances single-unit discrimination.
% Journal of Neuroscience Methods 173: 34-40.
    
    % Daubechies(4) wavelet
    wavelet = 'db4';
    % Decompose data
    [C, L] = wavedec(data, max_level, wavelet);
    % Zero out approximation coefficients
    C = wthcoef('a', C, L);
    % Reconstruct
    filtered = waverec(C, L, wavelet);
    
end