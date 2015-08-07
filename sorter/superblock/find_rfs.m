function [rf_blocks, nParts] = find_rfs(varargin)
% FIND_RFS Find the receptive field blocks in a tank.
%
% [RF_BLOCKS, NPARTS] = FIND_RFS() Opens a dialog prompting user to select the
%                       tank directory of interest.
%
% [RF_BLOCKS, NPARTS] = FIND_RFS(TANK_PATH) Finds the receptive field blocks in
%                       the tank located at absolute path TANK_PATH.
%
% The main idea is to automatically determine which blocks in a tank are
% receptive field blocks. The method is as follows: in a given block, there are
% frequency, level, and file index vectors, which all are same length. For each
% unique file index, if there are enough unique corresponding frequencies and
% levels to that index, then that index is considered with high probability to
% have a receptive field. This means that a block may have more than one
% receptive field.
%
% Currently, the cutoff is set to eight (8).
%
% Requires TDT2mat.m
%
% INPUT:
% TANK_PATH     String of absolute path to a tank directory
%
% OUTPUT:
% RF_BLOCKS     1xN cell, where N is number of blocks. Each element is an 1xK
%               integer vector of the parts within the corresponding block that
%               contain receptive fields. The structure of the vector is as
%               follows:
%                   [Block Number, part A, ...]
%               If the vector has only two elements, the entire block is a RF.
%               If the vector has more than two elements, the rest are parts of
%               the block that have a RF.
%               If an error occurs or if the block is not a RF, the vector will
%               have only one element: the block number.
% NPARTS        1xN integer array of the number of parts for each block

    rf_blocks = cell(0);

    if ~exist('TDT2mat', 'file')
        error('TDT2mat required');
    end
    
    CUTOFF = 8;     %  minimum number of unique values to be considered RF.

    if nargin > 1
        error('Too many arguments');
    elseif nargin == 1
        path = varargin{1};
        if ~exist(path, 'dir')
            error('Tank not found: %s', path);
        end
    else
        path = uigetdir('U:/');
        if ~path
            error('No tank selected');
        end
    end
    
    n = block_count(path);
    rf_blocks = cell(1, n);
    nParts = zeros(1, n);
  
    for i = 1:n
        rf_blocks{i} = i;
        [frq, lvl, fInd] = open_block(path, i);

        if isempty(frq) || isempty(lvl) || isempty(fInd)
            rf_blocks{i} = i;
            warning('Skipping block %d', i);
            continue
        end

        rf_blocks{i} = [i, find_rfs_in_block(frq, lvl, fInd, CUTOFF)];
        nParts(i) = length(unique(fInd));
    end

end

function [frq, lvl, fInd] = open_block(path, block_num)
% Opens block BLOCK_NUM in tank located at PATH. Returns the frequency
% vector FRQ, level vector LVL, and file index vector FIND.
% If an error occurs, frq, lvl, and fInd are empty vectors.

    try
        block_str = sprintf('Block-%d', block_num);
        data = TDT2mat(path, block_str, 'Type', 2, 'Verbose', false);
        
        frq = data.epocs.Frq1.data;
        lvl = data.epocs.Lev1.data;
        fInd = data.epocs.FInd.data;
        
        if length(frq) ~= length(fInd) || length(frq) ~= length(lvl) ...
           || length(lvl) ~= length(fInd)
       
            warning('Frq/Lvl/fInd vectors not same length in block %d', ...
                    block_num);
                
            frq = [];
            lvl = [];
            fInd = [];            
        end

    catch
        warning('Problem in opening block %d', block_num);
        frq = [];
        lvl = [];
        fInd = [];
    end
end

function [rf_parts] = find_rfs_in_block(frq, lvl, fInd, cutoff)
% Returns a vector containing the indices of the parts within a given block that
% contain receptive fields. Uses the simple metric.
% If a block does not have any RFs, returns empty vector.

    parts = unique(fInd);
    rf_parts = zeros(1, length(parts));
    for i = 1:length(parts)
       partNum = parts(i);
       partIndices = (fInd == partNum);
       matchFrq = frq(partIndices);
       matchLvl = lvl(partIndices);
       
       if isRFsimple(matchFrq, matchLvl, cutoff)
           rf_parts(i) = i;
       end
    end
    
    rf_parts(rf_parts == 0) = [];
    
    if isempty(rf_parts)
        rf_parts = [];
    end
end

function [boolean] = isRFsimple(frq, lvl, cutoff)
% Simple test. If a block has at least CUTOFF unique FRQ and LVL values, it is
% considered to contain a receptive field.

    uniqF = unique(frq);
    uniqL = unique(lvl);
    boolean = false;
    if length(uniqF) >= cutoff && length(uniqL) >= cutoff
        boolean = true;
    end

end