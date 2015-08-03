function lemap = lapEig(spikes, n)
% LAPEIG Laplacian eigenmap feature.
%
% LEMAP = LAPEIG(SPIKES)
%         Compute Laplacian eigenmap assuming at most 12 neighbors.
%
% LEMAP = LAPEIG(SPIKES, N)
%         Compute Laplacian eigenmap where nodes have at most N neighbors.
%
% Given a matrix of waveform data SPIKES, compute the Laplacian eigenmap
% constrained to three dimensions. The optional argument N indicates the number
% of neighbors each node has in the graph (default: 12).
%
% INPUT:
% SPIKES    NxM matrix of waveforms. Rows are spikes.
% N         (optional) Positive integer denoting number of neighbors each node
%           has in the map.
%
% OUTPUT:
% LEMAP     Nx3 matrix representing the Laplacian eigenmap embedded in 3D space.
%
% Source:
% DrToolbox

    SetDefaultValue(2, 'n', 12);
    lemap = compute_mapping(spikes, 'Laplacian', 3, n);

end