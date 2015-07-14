function spikes = prepare_spikes(info, channel)
% PREPARE_SPIKES extraction and supervised alignment of spikes from a channel.
%
% SPIKES = PREPARE_SPIKES(INFO, CHANNEL)
%
% Given raw spike data in the INFO struct, extract spikes from a particular
% channel CHANNEL and align them. The user will be prompted to enter alignment
% options.
%
%
% See also INITIALIZE, PROMPT_DATA.

    if isempty()
        error('Empty procedure cell array');
    elseif isempty(info)
        error('Empty info struct');
    end
    
    
    
%% Prepare spike matrix
    channel = get_channel(strm);
    
    deflts = defaults();
    filt = bpf(strm.data(channel, :), deflts.LO, deflts.HI, strm.fs);
    spikes = tdt_spikes(filt, strm, snip, channel, deflts.WINDOW);


end




function aligned = handle_align(spikes)
% If 'cancel' selected, return empty array.

    aligned = [];
    
    [option, shift, window] = prompt_align(spikes);

    if isempty(option) || ~shift || ~window
        return
    else
        fprintf('Aligning spikes on %s, max shift %d, window size %d\n', option, ...
               shift, window);
    end

    aligned = align_custom(spikes, shift, option, window / 2, ...
                                window / 2);   
end