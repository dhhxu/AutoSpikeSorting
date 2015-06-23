function [spikes] = get_spikes_custom(data, idx, pre, post)
% GET_SPIKES_CUSTOM Recovers spikes from detected occurrences.
%
% spikes = GET_SPIKES_CUSTOM(data, idx, pre, post)
%
% Given a vector IDX of indices in vector DATA where spikes were detected,
% extract a window of PRE samples before the occurrence and POST samples after
% the occurrence. Note that if the window contains an index of another
% detected spike, that index is ignored and is assumed to be part of the
% same spike.
%
% The window will span PRE + POST + 1 samples. Generally, windows span some
% time between 2 to 3 ms of data time. The appropriate value should be
% calculated beforehand by the user.
%
% INPUT:
% DATA      a 1xN numeric vector of spike voltage data.
% IDX       1xM numeric vector (M < N) of indices where spikes occurred in DATA.
% PRE       positive integer of number of samples to take before the spike
%           occurrence.
% POST      postive integer of number of samples to take after the spike
%           occurrence.
%
% OUTPUT:
% SPIKES    a MxN matrix where each row corresponds to a detected spike,
%           and each spike contains N samples, where N = PRE + POST + 1

spikes = [];

first_interval = true;
old_interval = [];

for i = 1:length(idx)
    interval = (idx(i) - pre):(idx(i) + post);
    
    if first_interval
        old_interval = interval;
        first_interval = false;
        
    elseif interval(1) <= old_interval(end)
        continue;
    end

    if interval(1) >= 1 && interval(end) <= length(data)
        spikes = vertcat(spikes, data(interval)); %#ok<AGROW>
    else
        warning('Ending loop early due to illegal interval access.');
        break;
    end
end