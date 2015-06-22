function [intervals] = interspike_interval(data)
% INTERSPIKE_INTERVAL Calculate time between spikes in data.
%
% interspike_interval(data)
%
% Calculates the interspike interval in DATA.
%
% Input:
% "data": 1xN numerical vector of indices of spike occurrences.
%
% Output:
% "intervals": 1x(N - 1) numerical vector containing intervals between spike
% occurrences.
%
% Example:
% interspike_interval([5 10 44 62]) returns [5 34 18]

intervals = zeros(1, length(data) - 1);

for i = 1:length(intervals)
    intervals(i) = data(i + 1) - data(i);
end
