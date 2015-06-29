function [idx] = threshold_simple(data, thr)
% THRESHOLD_SIMPLE Detect spikes via amplitude thresholding
%
% IDX = THRESHOLD_SIMPLE(DATA, THR)
%
% This function detects and locates the time points of spikes in DATA with
% amplitude exceeding THR. Specifically, only considers positive spikes.
% 
% INPUT:
% DATA      1xN numerical vector of raw data
% THR       positive numeric threshold to detect spikes
%
% OUTPUT:
% IDX       1xN numerical vector of indices of detected spikes within DATA.

    if isempty(data)
        error('Empty data');
    elseif thr < 0
        error('Invalid threshold: %2.2f', thr);
    end

    idx = [];
    for i = 1:length(data)
        if data(i) > thr
            idx = [idx i];          %#ok<AGROW>
        end
    end
end