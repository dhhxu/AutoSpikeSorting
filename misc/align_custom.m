function [aligned] = align_custom(spikes, shift, thr, pre, post)
% ALIGN_CUSTOM Aligns waveforms for better cluster separation
%
% ALIGN_CUSTOM(spikes, shift, thr, pre, post)
%
% This function aligns extracted spike waveforms described by matrix
% SPIKES. It shifts spikes by a maximum of SHIFT time steps in either left
% or right direction. The THR option controls alignment on global maximum
% or minimum. PRE and POST describe the number of samples that occur before
% and after the spike event and do not include the actual spike event. In
% other words, PRE + POST equal the number of samples in a waveform, which
% differs from the convention used in `get_spikes_custom.m`
%
% INPUT:
% SPIKES    MxN numeric matrix where each row corresponds to a spike waveform.
% SHIFT     Positive integer for the maximum number of samples to shift a
%           waveform for alignment.
% THR       Alignment option string. The options are:
%               'max'   align on global maxima
%               'min'   align on global minima
% PRE       Positive integer of number of samples before the spike event.
% POST      Positive integer of number of samples after the spike event.
%
% OUTPUT:
% ALIGNED   Matrix with same dimensions as SPIKES, with aligned waveforms.
%
% The code is adapted from Quiroga's `spike_alignment.m` script in the
% WaveClus program. It has been modified for clarity and simplified for
% ease of use.
%
% Source: Quiroga 2004

if isempty(spikes)
    error('Spikes matrix cannot be empty');
elseif shift <= 0
    error('Shift cannot be negative');
elseif ~strcmp(thr, 'max') && ~strcmp(thr, 'min')
    error('Unknown alignment option: %s', thr);
elseif pre < 0 || post < 0
    error('pre and/or post values must be positive');
end

aligned = align_custom_core(spikes, shift, thr, pre, post);

end

function [aligned] = align_custom_core(spikes, shift, thr, pre, post)

width = pre + post;
numSpikes = size(spikes, 1);
spikeWidth = size(spikes, 2);

% Introduces first alignment
spikes1 = zeros(numSpikes, width + 2 * shift + 4);

if spikeWidth < width + shift + 2
    diff_size = width + shift + 2 - spikeWidth;
    spikes1(:, 1:(shift + 2)) = -spikes(:, (shift + 2):-1:1);
    spikes1(:, (1 + shift):(shift + spikeWidth)) = spikes;
    spikes1(:, (1 + shift + spikeWidth + 2):end) = ...
        -spikes(:, end:-1:(end - diff_size + 1));
else
    spikes1(:, 1:(shift + 2)) = -spikes(:, shift:-1:1);
    spikes1(:, (1 + shift):(2 * shift + width)) = spikes(1:(shift + width));
end

spikes2 = zeros(numSpikes, width + 4);

for i = 1:numSpikes
    str = sprintf('%s(spikes1(i, (pre + 2):(pre + 2 * shift + 1)));', thr);
    [~, iaux] = eval(str);
    if iaux > 1
        spikes2(i, :) = spikes1(i, (iaux - 1):(iaux + width + 2));
    else
        spikes2(i, :) = spikes1(i, iaux:(iaux + width + 3));
    end
end

aligned = spikes2;
aligned(:, 1:2) = [];
aligned(:, (end - 1):end) = [];

end
