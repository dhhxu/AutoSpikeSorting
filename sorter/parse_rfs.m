function [rfs] = parse_rfs(rfs_string, tank_path)
% PARSE_RFS parse user input receptive fields.
%
% RFS = PARSE_RFS(RFS_STRING, TANK_PATH)
%
% Receives a string of RF block/part from the user in the following format:
% RF Block A, RF Block B, ...
% or
% RF Block A(Part a Part b ...), RF Block B ....
%
% Note that the parts must be separated by a space. Also block numbers that are
% skipped are not considered to be RF blocks: e.g. 1, 3, 7 -- 2, 4-6 are not RF
% blocks.
%
% Then parses the string and returns a one dimensional cell array of receptive
% field status for each block. Specifically:
%
% Block A                           (scalar) Not RF block
% [Block A, 1]                      (vector) Block A is an entire RF block
% [Block A, Part a, Part b, ...]    (vector) Parts a, b, ... are RFs within
%                                   Block A
%
% This function only checks that block numbers are not greater than the number
% of blocks in the tank directory located at path TANK_PATH.
%
% INPUT:
% RFS_STRING    String of user described RF fields.
% TANK_PATH     String of path to tank directory that RFS_STRING describes
%
% OUTPUT:
% RFS           1 dimensional cell array describing the RF status for each block
%               in the tank.

    arr = strsplit(rfs_string, ',');

    nBlocks = block_count(tank_path);
    
    rfs = cell(1, nBlocks); 
    
    for i = 1:nBlocks
        rfs{i} = i;
    end
    
    for i = 1:length(arr)
        res = str2double(arr{i});
        
        if ~isnan(res)
            if res > nBlocks
                error('Invalid RF block number');
            end
            
            rfs{res} = [res, 1];

        else
            % we have X(A,B,...)
            res = strsplit(arr{i}, {'(', ')'});
            
            block = str2double(res{1});
            
            if block > nBlocks || isnan(block)
                error('Invalid RF block number');
            end
            
            parts = str2num(res{2});
            rfs{block} = [block, parts];

        end
    end

end