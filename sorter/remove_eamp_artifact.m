function [real_idx] = remove_eamp_artifact(snip, epoc)
% REMOVE_EAMP_ARTIFACT removes artifacts by inspecting epoch data
%
% REAL_IDX = REMOVE_EAMP_ARTIFACT
%
% Given snippet and epoch structs SNIP and EPOC respectively, detect electrical
% artifacts using EAmp data located in EPOC. Returns a one dimensional logical
% vector where ones represent rows in the snippet data that are real spikes.
%
% INPUT:
% SNIP      Struct containing SNIP data
% EPOC      Struct containing EPOC data
%
% OUTPUT:
% REAL_IDX  Mx1 logical vector, where 1's signifies non-artifact spikes. M is the
%           number of spikes in the snippet data.
%
% See also TDT2mat

    eamp = epoc.EAmp.data;
    
    ts = snip.ts;
    
    spikes = snip.data;
    
    nSpikes = size(spikes, 1);
    
    real_idx = ones(nSpikes, 1);
    
    % no artifacts
    if sum(eamp) == 0
        return
    end
    
    ee_idx = find(eamp ~= 0);
    
    ee_first = ee_idx(1);
    
    for i = 1:3
        ee_last = ee_first + 100 - 1;
        
        ee_start = epoc.EAmp.onset(ee_first);
        ee_end = epoc.EAmp.offset(ee_last);
        real_idx(ts >= ee_start & ts <= ee_end) = 0;
        
        ee_first = ee_first + 100;

    end
    
    real_idx = logical(real_idx);

end