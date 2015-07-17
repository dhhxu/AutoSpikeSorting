function sst = testsst(path, blocknum, chan)
    
    if isempty(path)
        path = uigetdir('U:/');
        if isempty(path)
            error('No Tank chosen');
        end
    end
    
    if blocknum < 1
        error('Block number must be positive: %d', blocknum);
    end

    
    sst = superspiketrain_dx(path, blocknum, chan, [], 'timestamps', 'waveforms');
                                         
end