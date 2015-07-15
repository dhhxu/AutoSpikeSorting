function [results] = cluster_block(info, procedure, kList)

    % start timer
    
    if ~ishandle(procedure)
        error('Procedure is not a handle.');
    end

    if ~isvector(kList) || isempty(kList)
        error('Invalid kList input');
    end
    
    nChannels = get_nChannels(info);
    if length(kList) > 1
        if length(kList) ~= nChannels
            error('Mismatch between kList and number of channels');
        end
    end
    
    results = cell(1, nChannels);
    
    for i = 1:nChannels
        % clustering stuff
        
        if length(kList) > 1
            class = cluster_channel(chan, info, procedure, kList(i));
        else
            class = cluster_channel(chan, info, procedure, kList);
        end
        
        results{i} = class;
    end
    
    % end timer

end

function [class] = cluster_channel(chan, info, procedure, k)

    data = get_snip_spikes(info, chan);
    
    % procedure responsible for feature extraction
    
    class = procedure(data, k);
    
end

function nChannels = get_nChannels(info)

    chan = info.snip.chan;
    channels = unique(chan);
    nChannels = length(channels);
    
end