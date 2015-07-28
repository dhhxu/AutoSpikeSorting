function [superblocks] = partition_rfs(agglomerated, rfs)
% PARTITION_RFS partition a agglomerated block of tank data into superblocks
% containing individual receptive fields.
%
% SUPERBLOCKS = PARTITION_RFS(AGGLOMERATED, RFS)
%
% For use with AOS00x tanks or with tanks whose blocks contain more than one
% receptive field. Takes in an agglomerated table of tank block data with file
% index labels and splits it into superblocks for each receptive field
% identified in RFS.
%
% AGGLOMERATED is the output of the AGGLOMERATE_BLOCKS function. RFS is the
% output of the FIND_RFS function.
%
% Assumptions: If a block has only one RF, the part it is assigned is always 1.
%
% INPUT:
% AGGLOMERATED  Table with the following fields:
%                   block
%                   chan
%                   ts
%                   sortc
%                   waves
%                   part
% RFS           Cell array. Elements are integer arrays in the following format:
%                   [block number, part a, part b, ...]
%               If an entire block is a RF, then [block number, 1]
%               If a block is not a RF, then [block number]
%               If a block has several RFs, then [block number, part a, ...]
%
% OUTPUT:
% SUPERBLOCKS   1 dimensional cell. Each element is a superblock table with the
%               following fields:
%                   block   Nx1 vector of block numbers
%                   chan    Nx1 vector of channel numbers
%                   ts      Nx1 vector of waveform timestamps
%                   sortc   Nx1 vector of unit assignments (initially all zeros)
%                   waves   Nx30 vector of snippet waveforms.
%                   part    Nx1 vector of file indices
%
% See also AGGLOMERATE_BLOCKS, BUILD_RFBLOCK, FIND_RFS.

    rf_info = split_rfs(rfs);

    nSuperblocks = size(rf_info, 1);
    
    superblocks = cell(nSuperblocks, 1);
    
    agg = agglomerated;
    
    for i = 1:nSuperblocks
        curr_sb = table;
        next_sb = table;
        
        curr_block = rf_info(i, 1);
        curr_part = rf_info(i, 2);
        
        if i == nSuperblocks
            curr_sb = agg(agg.block == curr_block & agg.part >= curr_part, :);
            next_sb = agg(agg.block > curr_block, :);
        else
            next_block = rf_info(i + 1, 1);
            next_part = rf_info(i + 1, 2);
            
            if next_block > curr_block % join across blocks
                curr_sb = agg(agg.block == curr_block & ...
                              agg.part >= curr_part, :);
                tmp_sb = agg(agg.block > curr_block & ...
                             agg.block < next_block, :);
                
                curr_sb = vertcat(curr_sb, tmp_sb);
                clear tmp_sb
                
                if next_part > 1
                    next_sb = agg(agg.block == next_block & ...
                                  agg.part < next_part, :);                    
                end
            else    % split within block
                curr_sb = agg(agg.block == curr_block & ...
                              agg.part >= curr_part & ...
                              agg.part < next_part, :);
            end
            
        end
        
        superblocks{i} = vertcat(curr_sb, next_sb);

        clear curr_sb next_sb
    end % superblock loop

end

function [split_rfs] = split_rfs(rfs)
% Splits the elements of RFS into rows
% e.g
% {[1, 1], [2, 1, 5, 8], ...} transforms into:
%
% {1, 1
%  2, 1
%  2, 5
%  2, 8
%  ... }
%
% SPLIT_RFS is a Nx2 array. N is the number of superblocks that can be made
% from RFS. The first column is block number. The second is the part number.

    N = sb_count(rfs);
    split_rfs = zeros(N, 2);
    
    idx = 1;
    for i = 1:length(rfs)
        elem = rfs{i};
        
        nParts = length(elem) - 1;
        block_num = elem(1);
        
        if nParts == 0
            continue
        elseif nParts == 1
            split_rfs(idx, 1) = block_num;
            split_rfs(idx, 2) = elem(2);
            idx = idx + 1;
        else
            parts = elem(2:end);
            
            for j = 1:nParts
                split_rfs(idx, 1) = block_num;
                split_rfs(idx, 2) = parts(j);
                idx = idx + 1;
            end
        end
    end

end

function n = sb_count(rfs)
% Returns the number of superblocks that can be created from RFS.

    n = 0;
    
    for i = 1:length(rfs)
        elem = rfs{i};
        
        if length(elem) == 1
            continue;
        end
        
        n = n + length(elem) - 1;
    end

end

