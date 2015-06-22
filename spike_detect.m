function [idx, amp] = spike_detect(data, threshold)
% SPIKE_DETECT Detect spikes via amplitude thresholding.
%
% spike_detect(data, threshold)
%
% This function detects and locates the time points of spikes in DATA with
% amplitude exceeding THRESHOLD. Specifically, only considers positive spikes.
% 
% Input:
% "data": 1xN numerical vector of raw data.
% "threshold": threshold to detect spikes.
%
% Output:
% "idx": indicies of detected spikes within DATA.
% "amp": amplitude of detected spikes.

idx = [];
amp = [];

for i = 1:length(data)
    if data(i) > threshold
        idx = [idx i];          %#ok<AGROW>
        amp = [amp data(i)];    %#ok<AGROW>
    end
end
