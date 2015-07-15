function [spike_matrix] = tdt_spikes(filtered, strm, snip, channel, window)
% TDT_SPIKES extract spikes with custom window using timestamps.
%
% SPIKE_MATRIX = TDT_SPIKES(FILTERED, STRM, SNIP, CHANNEL, WINDOW)
%                Symmetric window extraction
% 
% SPIKE_MATRIX = TDT_SPIKES(FILTERED, STRM, SNIP, CHANNEL, [PRE POST])
%                Extract PRE - 1 spikes before occurrence and POST spikes after
%                occurrence. Window size is PRE + POST samples.
%
% This function is a wrapper encapsulating the spike detection and recovery
% steps. It takes advantage of the work done by the TDT system to make
% shortcuts in spike extraction. For a given channel CHANNEL, this function
% extracts spikes of size WINDOW samples from the filtered data FILTERED.
%
% The spikes are returned in matrix SPIKE_MATRIX, with rows corresponding to
% spikes.
%
% INPUT:
% FILTERED      Matrix of filtered spikes.
% STRM          Stream struct
% SNIP          Snippet struct
% CHANNEL       Channel number
% WINDOW        Number of sample points in a spike waveform. Symmetric option
% PRE           Number of samples before spike occurrence. Includes the
%               occurrence itself (i.e. actually PRE - 1)
% POST          Number of samples after spike occurrence.
%
% OUTPUT:
% SPIKE_MATRIX  NxWINDOW (or Nx(PRE+POST)) matrix of spike waveforms

    if ~isvector(window)
        error('Invalid window parameter');
    end
    
    pre = 0;
    post = 0;
    if length(window) == 2
        pre = window(1);
        post = window(2);
        if ~checkPrePost(pre, post)
            error('Invalid pre or post value');
        end
    end
    
    idx = tdt_detect(channel, strm, snip);
    
    if pre && post
        spike_matrix = get_spikes_custom(filtered, idx, pre, post);
    else
        spike_matrix = get_spikes(filtered, idx, window);
    end
    
end

function ok = checkPrePost(pre, post)
% Checks if PRE and POST values are valid.
    ok = false;
    if pre < 1 || post < 1
        return
    end
    ok = true;
end