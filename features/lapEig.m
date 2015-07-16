function lemap = lapEig(spikes, n)
%
%
% Source:
% DrToolbox
    SetDefaultValue(2, 'n', 12);
    lemap = compute_mapping(spikes, 'Laplacian', 3, n);
    
end