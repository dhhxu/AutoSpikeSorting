function [idx] = tdt_detect(channel, strm_struct, snip_struct)
% TDT_DETECT Locates indices of spikes in stream data from snippet data.
%
% IDX = TDT_DETECT(STRM_STRUCT, SNIP_STRUCT)
%
% Given timestamps in SNIP_STRUCT for a given channel CHANNEL, locate the
% corresponding indices in the stream data located in STRM_STRUCT.
%
% INPUT:
% CHANNEL       positive integer of the channel to get indices from
% STRM_STRUCT   struct of stream data
% SNIP_STRUCT   struct containing snippet timestamps as detected by TDT system
%
% OUTPUT:
% IDX           1xN integer vector containing indices into the stream data
%               corresponding to the timestamps in the snippet data

    if channel < 1
        error('Invalid channel: %d', channel);
    elseif isempty(strm_struct)
        error('Empty stream struct.');
    elseif isempty(snip_struct)
        error('Empty snippet struct.');
    end

    ts = snip_struct.ts(snip_struct.chan == channel);
    idx = floor(ts * strm_struct.fs);

end
