function [idx] = quiroga_threshold(data)
% QUIROGA_THRESHOLD Amplitude threshold spikes using method in Quiroga 2004
%
% IDX = QUIROGA_THRESHOLD(DATA)
%
% Detects spikes in DATA vector according to positive amplitude thresholding.
% The threshold is determined by Quiroga's method of using the median as an
% estimator of background noise. The formula is as found below:
%
% Thr = 4 * median( |x| / 0.6745 )
%
% where x is the neural signal with background noise.
% 
% INPUT:
% DATA  1xN numerical vector of raw data
%
% OUTPUT:
% IDX   indices of detected spikes within DATA

    threshold = 4 * median(abs(data) / 0.6745);
    idx = threshold_simple(data, threshold);

end
