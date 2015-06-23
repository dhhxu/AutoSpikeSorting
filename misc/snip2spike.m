function [spikes] = snip2spike(channel, strm_struct, snip_struct, pre, post)
% SNIP2SPIKE Recovers raw spike waveform data from TDT snippet data timestamps
%            within a single channel.
%
% Given the timestamps of snippet data in struct SNIP_STRUCT for a given
% CHANNEL, locates the corresponding occurrences in the raw stream data in
% struct STRM_STRUCT. Once located, extracts the samples of the raw stream data
% around each occurrence.
%
%   spikes = snip2SPIKE(strm_struct, snip_struct, window)
%
%       Extract WINDOW samples centered at each occurrence.
%
%   spikes = SNIP2SPIKE(strm_struct, snip_struct, pre, post)
%
%       Extract PRE samples before each occurrence and POST samples after each
%       occurrence. Note the window will span PRE + POST + 1 samples.
%
% INPUT:
% CHANNEL       Positive integer of the channel to focus on.
% STRM_STRUCT   TDT struct containing raw stream data. See TDT documentation for
%               more information.
% SNIP_STRUCT   TDT struct containing snippet data. Refer to above for more
%               information.
% WINDOW        Positive integer of the number of samples to take for each spike
%               occurrence. The window will be centered at each occurrence.
% PRE           Positive integer of the number of samples before each occurrence
%               to take.
% POST          Positive integer of the number of samples after each occurrence
%               to take.
%
% OUTPUT:
% SPIKES        MxN numeric matrix where each row is a TDT-detected spike and
%               each column is the number of samples for each spike.
%               If WINDOW is used, N = WINDOW.
%               IF PRE and POST are used, N = PRE + POST + 1


% code for checking valid channel