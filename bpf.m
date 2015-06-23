function [filtered] = bpf(data, lo, hi, fs)
% BPF Bandpass filter raw waveform data
%
% filtered = BPF(data, lo, hi, sr)
%
% Bandpass filter raw data DATA using elliptic passband between lo Hz and hi Hz.
% The raw data is sampled at fs Hz.
% The code is adapted from Quiroga's `amp_detect.m` script from the
% WaveClus program.
%
% Requires the Signal Processing Toolbox.
%
% INPUT:
% DATA      Numeric 1xN vector of raw data
% LO        Positive integer of the left end of the passband in Hz
% HI        Positive integer of the right end of the passband in Hz
% FS        Positive integer of the sampling rate in Hz
%
% OUTPUT:
% FILTERED  Numeric 1xN vector of bandpass filtered data

if ~exist('ellip', 'file')
    error('Signal Processing Toolbox not found.');
end

[B, A] = ellip(2, 0.1, 40, [lo hi] * 2 / fs);
filtered = filtfilt(B, A, data);

