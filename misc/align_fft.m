function aligned = align_fft(spikes)
% ALIGN_FFT Align spike waveforms using FFT.
%
% ALIGNED = ALIGN_FFT(SPIKES)
%
% Converts spikes in matrix SPIKES to frequency domain via FFT, as described in
% Jung et al. 2006. This has the effect of spike alignment.
%
% INPUT:
% SPIKES    matrix of spikes. Rows are spikes.
%
% OUTPUT:
% ALIGNED   matrix of spikes with Discrete FFT applied to the waveforms.
%
% Source:
% Jung, H. K., Choi, J. H., & Kim, T. (2006). Solving alignment problems in
% neural spike sorting using frequency domain PCA. Neurocomputing, 69(7),
% 975-978.

    aligned = fft(spikes, [], 2);

end