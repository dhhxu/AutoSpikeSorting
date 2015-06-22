function [aligned] = align_spikes(spikes, shift, thr, interp, factor)
% ALIGN_SPIKES Aligns waveforms for better cluster separation
%
% ALIGN_SPIKES(spikes, shift, thr, interp, factor)
%
% This function is a wrapper for Quiroga's Wave_clus alignment code
% (spike_alignment.m). Given a matrix of spikes SPIKES, aligns them up to SHIFT
% samples based on a condition THR. There is an interpolation option INTERP,
% with factor FACTOR.
%
% INPUT:
% SPIKES    MxN numeric matrix where each row corresponds to a spike waveform.
% SHIFT     Positive integer for the maximum number of samples to shift a
%           waveform for alignment.
% THR       Alignment option string. The options are:
%               'pos'   align on global maxima
%               'neg'   align on global minima
% INTERP    Interpolation option. If 'y', use cubic spline interpolation.
%           Otherwise, 'n.'
% FACTOR    Positive integer for interpolation factor.
%
% OUTPUT:
% ALIGNED   Matrix with same dimensions as SPIKES, with aligned waveforms.
%
% Source: Quiroga 2004

if shift <= 0
    error('Shift cannot be negative');
elseif ~strcmp(thr, 'pos') && ~strcmp(thr, 'neg')
    error('Unknown alignment option: %s', thr);
elseif ~strcmp(interp, 'y') && ~strcmp(interp, 'n')
    error('Unknown interpolation option: %s', interp);
elseif factor <= 0
    error('Invalid interpolation factor: %d', factor);
end

points = size(spikes, 2);
w_pre = floor(points / 2);
w_post = w_pre;

if mod(points, 2)
    w_post = w_post + 1;
end

sr = 0;

% populate struct
handles.par.w_pre = w_pre;
handles.par.w_post = w_post;
handles.par.sr = sr;
handles.par.detection = thr;
handles.par.alignment_window = shift;
handles.par.interpolation = interp;
handles.par.int_factor = factor;

aligned = spike_alignment(spikes, handles);
