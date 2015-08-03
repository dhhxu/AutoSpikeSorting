function [agg] = agglomerate_blocks(path)
% AGGLOMERATE_BLOCKS Join a tank's blocks into one giant table structure.
%
% AGG = AGGLOMERATE_BLOCKS(PATH)
%
% Given a tank located at path PATH, join the block information together into
% one giant table AGG. Also removes artifacts, if present.
%
% Note: the output AGG is a very large table and is not saved to file, as it is
% intended to be an intermediate variable. Most likely PARTITION_RFS will
% save its output to a file.
%
% INPUT:
% PATH  String of absolute path to tank
%
% OUTPUT:
% AGG   Table of joined block data with the following fields:
%           block   integer, block number
%           chan    integer, channel number
%           ts      double, timestamp
%           sortc   integer, sort code (intially all 0 meaning unsorted)
%           waves   1x30 double vector, describes a waveform
%           part    integer, file index
%
% See also PARTITION_RFS, REMOVE_EAMP_ARTIFACT.

    if ~exist(path, 'dir')
        error('Tank not found: %s', path);
    end
    tic;
    agg = agg_core(path);
    toc;
end

function [agg] = agg_core(path)

    nBlocks = block_count(path);
    
    block = [];
    chan = [];
    ts = [];
    sortc = [];
    waves = [];
    part = [];
    
    for i = 1:nBlocks
        try
            block_str = sprintf('Block-%d', i);
            data = TDT2mat(path, block_str, 'Type', [2, 3], 'Verbose', false);
        catch
            warning('Problem in opening block %d\n', i);
            continue
        end

        snip = data.snips.CSPK;
        epoc = data.epocs;
        
        % remove artifacts
        idx = remove_eamp_artifact(snip, epoc);

        snip.data = snip.data(idx, :);
        snip.chan = snip.chan(idx);
        snip.sortcode = snip.sortcode(idx);
        snip.ts = snip.ts(idx);
        
        all_parts = epoc.FInd.data;
        part_list = unique(all_parts);
        
        nParts = length(part_list);
        
        nPoints = length(snip.chan);
        parts = zeros(nPoints, 1);
                 
        for j = 1:nParts
            part_num = part_list(j);

            part_idx = find(all_parts == part_num);

            start_ts = epoc.FInd.onset(part_idx(1));
            end_ts = epoc.FInd.offset(part_idx(end));

            parts(snip.ts >= start_ts & snip.ts <= end_ts) = part_num;

        end % part loop

        block = [block; i.*ones(nPoints, 1)];
        chan = [chan; snip.chan];
        ts = [ts; snip.ts];
        sortc = [sortc; zeros(nPoints, 1)];
        waves = [waves; snip.data];
        part = [part; parts];
        
    end % block loop
    
    agg = table(block, chan, ts, sortc, waves, part);

    % remove zero part spikes
    agg(agg.part == 0, :) = [];

end