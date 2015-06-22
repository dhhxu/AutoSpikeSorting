function [aligned] = align_simple(spikes, shift, peak)
% ALIGN_SIMPLE Basic alignment of spike waveforms
%
% ALIGN_SIMPLE(spikes, shift, peak)
%
% Aligns waveforms in SPIKES matrix by shifting them a maximum of SHIFT
% timesteps. The PEAK argument controls aligning on global maximum or minimum.
%
% INPUT:
% SPIKES    MxN numeric matrix, where each row represents a waveform
% SHIFT     Positive integer indicating maximum timesteps to shift each waveform
% PEAK      String indicating what to align on. Possible values:
%               'max': align on global maximum
%               'min': align on global minimum
%
% OUTPUT:
% ALIGNED   MxN numeric matrix of aligned waveforms.

if shift <= 0
    error('Invalid shift quantity: %d', shift);
elseif ~strcmp(peak, 'max') && ~strcmp(peak, 'min')
    error('Invalid option: %s', peak);
end

aligned = align_simple_core(spikes, shift, peak);

end

function [aligned] = align_simple_core(spikes, shift, peak)
% The core function for ALIGN_SIMPLE.

[~, idx] = eval(sprintf('%s(spikes, [], 2);', peak));

avg = mean(idx);

[~, min_idx] = min(abs(idx - avg));

center = idx(min_idx);

rows = size(spikes, 1);
cols = size(spikes, 2);

output = zeros(rows, 2 * shift + cols);

center_range = (shift + 1):(shift + cols);

for i = 1:rows
    loc = idx(i);
    diff = abs(loc - center);
    if diff > shift
        diff = shift;
    end
    
    if loc > center
        output(i, center_range - diff) = spikes(i, 1:cols);
    elseif loc < center
        output(i, center_range + diff) = spikes(i, 1:cols);
    else
        output(i, center_range) = spikes(i, 1:cols);
    end     
end

output(:, 1:shift) = [];
output(:, (end - shift + 1):end) = [];

aligned = output;

end 