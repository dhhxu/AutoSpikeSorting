function [spike_matrix] = tdt_spikes(filtered, strm, snip, channel, window)
% TDT_SPIKES extract spikes with symmetric window using timestamps.
%
% SPIKE_MATRIX = TDT_SPIKES(FILTERED, STRM, SNIP, CHANNEL, WINDOW)
%
% This function is a wrapper encapsulating the spike detection and recovery
% steps. It takes advantage of the work done by the TDT system to make
% shortcuts in spike extraction. For a given channel CHANNEL, this function
% extracts spikes of size WINDOW samples symmetric about the spike occurrence
% from the filtered data FILTERED. Timestamps are obtained from the SNIP and
% STRM structs. The spikes are returned in matrix SPIKE_MATRIX, with rows
% corresponding to spikes.
%
% Please note the simplification made in the symmetric window.
%
% INPUT:
% FILTERED      Matrix of filtered spikes.
% STRM          Stream struct
% SNIP          Snippet struct
% CHANNEL       Channel number
% WINDOW        Number of sample points in a spike waveform
%
% OUTPUT:
% SPIKE_MATRIX  NxWINDOW matrix of spike waveforms

    idx = tdt_detect(channel, strm, snip);
    spike_matrix = get_spikes(filtered, idx, window);
    
end