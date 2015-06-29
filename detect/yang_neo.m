function [idx] = yang_neo(data)
% YANG_NEO Uses Yang 2009 NEO threshold scheme to detect spikes
%
% IDX = YANG_NEO(DATA)
%
% Applies NEO on DATA and detects spikes based on threshold in Yang 2009. The
% threshold is set to 3 times the average energy of DATA.
%
% INPUT:
% DATA      1xN numeric vector of data that has had NEO applied on it
%
% OUTPUT:
% IDX       1xM integer vector (M < N) where indices indicate a spike occurrence

    neo_data = neo_apply(data, 1:length(data));
    threshold = 3 * mean(neo_data);
    idx = threshold_simple(neo_data, threshold);

end