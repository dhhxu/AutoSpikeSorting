function [num_blocks] = block_count(path)
% BLOCK_COUNT Returns the number of blocks in a tank.
% 
% NUM_BLOCKS = BLOCK_COUNT(PATH)
%
% Return the number of blocks in a tank located at absolute path PATH.
%
% INPUT:
% PATH          String of absolute path to tank.
%
% OUTPUT:
% NUM_BLOCKS    Integer of the number of blocks in the tank.

    wildcard = fullfile(path, 'Block*');
    matches = dir(wildcard);
    num_blocks = length(matches);
end