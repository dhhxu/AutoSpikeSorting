function sst = testsst(path, blocks, chan)
    
    if isempty(path)
        path = uigetdir('U:/');
        if isempty(path)
            error('No Tank chosen');
        end
    end
    
    sst = superspiketrain_dx(path, blocks, chan, 0, 1, 'timestamps', 'sortcode', 'CSPK');
                                         
end