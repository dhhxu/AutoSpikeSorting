function [idx] = chen_neo(data)
% CHEN_NEO Uses Yang 2009 NEO threshold scheme to detect spikes
%
% IDX = CHEN_NEO(DATA)
%
% Applies NEO on DATA and detects spikes based on threshold in CHEN 2011. The
% threshold is set to 1.2 times the standard deviation of DATA.
%
% INPUT:
% DATA      1xN numeric vector of data that has had NEO applied on it
%
% OUTPUT:
% IDX       1xM integer vector (M < N) where indices indicate a spike occurrence

    neo_data = neo_apply(data, 1:length(data));
    threshold = 1.2 * std(neo_data);
    idx = threshold_simple(neo_data, threshold);

end