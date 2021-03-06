function aligned = align_snip(snips, shift, thr, fft)
% ALIGN_SNIP align snippet data using normal and FFT alignment methods.
%
% ALIGNED = ALIGN_SNIP(SNIPS, SHIFT, THR)
%           Amplitude alignment on maximum. THR option determines max or
%           min. Maximum time step shift is SHIFT.
%
% ALIGNED = ALIGN_SNIP(SNIPS, SHIFT, THR, FFT)
%           Applies DFT on waveforms after amplitude alignment.
%
% Align snippet data from TDT on maximum and using default alignment parameters.
% Window is symmetric. If FFT is provided and set to True, applies DFT to each
% spike waveform. The result will be complex.
%
% INPUT:
% SNIPS     Matrix of snippet data, rows are waveforms
% SHIFT     Maximum timesteps to shift spikes for alignment.
% THR       Option to align on maximum or miniumum. Options are:
%               'max'
%               'min'
% FFT       (Optional) boolean. If True, apply DFT after amplitude alignment
%           (Default: False)
%
% OUTPUT:
% ALIGNED   Matrix of aligned snippet spikes. Same dimensions as SNIPS. If FFT
%           flag is set to True, this matrix is complex-valued.

    SetDefaultValue(4, 'fft', false);

    D = defaults();
    width = size(snips, 2);
    
    % this function checks if THR is valid.
    aligned = align_custom(snips, shift, thr, width / 2, width / 2);
    
    if fft
        aligned = align_fft(snips);
    end
    
end