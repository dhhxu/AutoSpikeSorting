function [agg] = agglomerate_blocks(path)

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
        
        all_parts = epoc.FInd.data;
        part_list = unique(all_parts);
        
        nParts = length(part_list);
        
        nPoints = length(snip.chan);
        parts = zeros(nPoints, 1);
        
        if nParts == 1
            parts(1:end) = part_list;
        else            
            for j = 1:nParts
                part_num = part_list(j);
                
                part_idx = find(all_parts == part_num);
                
                start_ts = epoc.FInd.onset(part_idx(1));
                end_ts = epoc.FInd.offset(part_idx(end));
                
                parts(snip.ts >= start_ts & snip.ts <= end_ts) = part_num;
                
            end % part loop
            
        end
        
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