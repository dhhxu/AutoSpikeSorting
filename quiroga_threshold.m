function [idx, amp] = quiroga_threshold(data)
% QUIROGA_THRESHOLD Amplitude threshold spikes using method in Quiroga 2004
%
% QUIROGA_THRESHOLD(data)
%
% This function uses Quiroga's method for automatically determining the
% threshold for spikes. The formula is as follows:
%
% Thr = 4 * median( |x| / 0.6745 )
%
% where x is the neural signal with background noise.
% 
% INPUT:
% data: 1xN numerical vector of raw data.
%
% OUTPUT:
% idx: indices of detected spikes within DATA.
% amp: amplitude of detected spikes.

idx = [];
amp = [];

threshold = 4 * median(abs(data) / 0.6745);

for i = 1:length(data)
    if data(i) > threshold
        idx = [idx i];          %#ok<AGROW>
        amp = [amp data(i)];    %#ok<AGROW>
    end
end
