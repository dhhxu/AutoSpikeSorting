function snipspikes = get_snip_spikes(info, channel)
% GET_SNIP_SPIKES Get snippet spike waveforms
%
% SNIPSPIKES = GET_SNIP_SPIKES(INFO, CHANNEL)
%
% Given an info struct INFO containing snippet data, extract the spike snippets
% for channel CHANNEL. The snippets are returned in the matrix SNIPSPIKES where
% rows are waveforms.
%
% This function assumes INFO and CHANNEL are valid, which is the case if it is
% called from PREPARE_SPIKES.
%
% INPUT:
% INFO          info struct of spike data
% CHANNEL       integer channel to extract snippet data from
%
% OUTPUT:
% SNIPSPIKES    matrix of snippet spike waveforms
%
% See also INITIALIZE, PREPARE_SPIKES.

    snip = info.snip;

    match = snip.chan == channel;
    
    snipspikes = snip.data(match, :);

end