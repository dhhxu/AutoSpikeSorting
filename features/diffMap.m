function [dm] = diffMap(spikes)
% DIFFMAP calculate diffusion map feature for spike waveforms.
%
%   DM = DIFFMAP(SPIKES)
%
%   Calculate diffusion maps for spike matrix SPIKES using default diffusion
%   map settings (t = 1.0, sigma = 1.0). The resulting map is embedded in 3D
%   space.
%
%   Note that the computation is very slow if the number of spikes is greater
%   than 3000. So for large datasets, use of this feature is strongly
%   discouraged.
%
% INPUT:
% SPIKES    NxM matrix of spike waveform data. Rows correspond to spikes.
%
% OUTPUT:
% DM        Nx3 matrix of the diffusion map.
%
% Source:
% DrToolbox
%
% See also COMPUTE_MAPPING

    dm = compute_mapping(spikes, 'DiffusionMaps', 3);

end