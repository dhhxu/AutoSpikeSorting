function [rf_blocks] = find_rfs(varargin)
% FIND_RFS Find the receptive field blocks in a tank.
%
% RF_BLOCKS = FIND_RFS() Opens a dialog prompting user to select the tank
%             directory of interest.
%
% RF_BLOCKS = FIND_RFS(TANK_PATH) Finds the receptive field blocks in the tank
%             located at absolute path TANK_PATH.
%
% The main idea is to automatically determine which blocks in a tank are
% receptive field blocks. The method is as follows: in a given block, there are
% frequency, level, and file index vectors, which all are same length. For each
% unique file index, if there are enough unique corresponding frequencies and
% levels to that index, then the block is considered with high probability to
% have a receptive field. Currently the cutoff is set to eight (8).
%
% Requires TDT2mat.m
%
% INPUT:
% TANK_PATH     String of absolute path to a tank directory
%
% OUTPUT:
% RF_BLOCKS     1xN vector of receptive field block numbers

    if ~exist('TDT2mat', 'file')
        error('TDT2mat required');
    end
    
    CUTOFF = 8;     %  minimum number of unique values to be considered RF.

    path = '';
    if nargin > 1
        error('Too many arguments');
    elseif nargin == 1
        path = varargin{1};
        if ~exist(path, 'dir')
            error('Tank not found: %s', path);
        end
    else
        path = uigetdir();
    end
    
    n = block_count(path);
    rfs = zeros(1, n);
    for i = 1:n
        [frq, lvl, fInd] = open_block(path, i);
        if isRF(frq, lvl, fInd, CUTOFF)
            rfs(i) = i;
        end
    end
    
    rfs(rfs == 0) = [];
    rf_blocks = rfs;
end

function [num_blocks] = block_count(path)
% Returns the number of blocks in the tank located at PATH.
    wildcard = fullfile(path, 'Block*');
    matches = dir(wildcard);
    num_blocks = length(matches);
end

function [frq, lvl, fInd] = open_block(path, block_num)
% Opens block BLOCK_NUM in tank located at PATH. Returns the frequency
% vector FRQ, level vector LVL, and file index vector FIND.

    try
        block_str = sprintf('Block-%d', block_num);
        data = TDT2mat(path, block_str, 'Type', 2, 'Verbose', false);
        
        frq = data.epocs.Frq1.data;
        lvl = data.epocs.Lev1.data;
        fInd = data.epocs.FInd.data;
    catch
        warning('Problem in opening block %d', block_num);
    end
end

function [boolean] = isRF(frq, lvl, fInd, cutoff)
% Returns true if the current block has a RF given information on FRQ, LVL, and
% FIND. The CUTOFF is the minimum number of unique frequencies and level within
% each FIND index.

    boolean = true;
    uniqF = unique(fInd);
    for i = 1:length(uniqF)
        index = uniqF(i);
        matchFrq = frq(fInd == index);
        matchLvl = lvl(fInd == index);
        
        if length(unique(matchFrq)) < cutoff || ...
           length(unique(matchLvl)) < cutoff
            boolean = false;
            return;
        end
    end
end