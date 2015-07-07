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
% receptive field blocks. This is achieved by inspecting the frequency and level
% data vectors in a block. If both of them are varying in values, then that
% block is a receptive field. The criteria is eight unique values for a high
% probabilty the block is a receptive field. Note that some blocks may be
% erroneously not considered receptive fields due to this criteria.
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
        if ~exists(path, 'dir')
            error('Missing tank: %s', path);
        end
    else
        path = uigetdir();
    end
    
    n = block_count(path);
    rfs = zeros(1, n);
    for i = 1:n
        [frq, lvl] = open_block(path, i);
        if length(unique(frq)) >= CUTOFF && length(unique(lvl)) >= CUTOFF
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

function [frq, lvl] = open_block(path, block_num)
% Opens block BLOCK_NUM in tank located at PATH. Returns the frequency
% vector FRQ and level vector LVL.

    try
        block_str = sprintf('Block-%d', block_num);
        data = TDT2mat(path, block_str, 'Type', 2, 'Verbose', false);
        
        frq = data.epocs.Frq1.data;
        lvl = data.epocs.Lev1.data;
    catch
        warning('Problem in opening block %d', block_num);
    end
end