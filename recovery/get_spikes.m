function [spikes] = get_spikes(data, idx, samples)
% GET_SPIKES Recovers spikes from detected occurrences.
%
% GET_SPIKES(data, idx, samples)
%
% Given a vector IDX of indices in vector DATA where spikes were detected,
% extract window of size SAMPLES points symmetrically about the spike's location.
%
% Generally SAMPLES will span between 2 to 3 ms of data time. The appropriate
% value should be calculated beforehand by the user.
%
% INPUT:
% DATA: a 1xN numeric vector of spike voltage data.
% IDX: a 1xM numeric vector (M < N) of indices where spikes occurred in DATA.
% SAMPLES: an integer value denoting how many samples to extract from a spike
% occurrence.
%
% OUTPUT:
% SPIKES: a MxSAMPLES matrix where each row corresponds to a detected spike,
% represented by a window of SAMPLES point.

spikes = [];

window_half = 0; %#ok<NASGU>
odd = true;

if mod(samples, 2)
    window_half = floor(samples / 2);
else
    window_half = samples / 2;
    odd = false;
end

first_interval = true;
old_interval = [];

for i = 1:length(idx)
    interval = []; %#ok<NASGU>
    if odd
        interval = (idx(i) - window_half):(idx(i) + window_half);
    else
        interval = (idx(i) - window_half):(idx(i) + window_half - 1);
    end
    
    if first_interval
        old_interval = interval;
        first_interval = false;
    else
        if interval(1) <= old_interval(end)
            continue;
        end
    end

    if interval(1) >= 1 && interval(end) <= length(data)
        spikes = vertcat(spikes, data(interval)); %#ok<AGROW>
    else
        warning('Ending loop early due to illegal interval access.');
        break;
    end
end