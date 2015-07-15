function spikes = prepare_spikes(info, channel)
% PREPARE_SPIKES extraction and supervised alignment of spikes from a channel.
%
% SPIKES = PREPARE_SPIKES(INFO, CHANNEL)
%
% Given raw spike data in the INFO struct, extract spikes from a particular
% channel CHANNEL and align them. The user will be prompted to enter alignment
% options. Returns a matrix SPIKES of aligned spike waveforms. If an error
% occurs, SPIKES will be empty.
%
% Assuming this function is called from COMPARE_PROCEDURE, INFO and CHANNEL can
% be treated as valid.
%
% Extraction is symmetric about the spike occurrence, and alignment follows this
% convention.
%
% INPUT:
% INFO      struct of spike data
% CHANNEL   integer of the channel containing the spikes to extract and align.
%
% OUTPUT:
% SPIKES    matrix of spike waveforms. Rows are spikes.
%
% See also INITIALIZE, COMPARE_PROCEDURE, PROMPT_DATA.
    
%% Prepare spike matrix
    dfts = defaults();
    filt = bpf(info.strm.data(channel, :), dfts.LO, dfts.HI, info.strm.fs);
    s = tdt_spikes(filt, info.strm, info.snip, channel, dfts.WINDOW);

    spikes = handle_align(s);

end


function aligned = handle_align(spikes)
% If 'cancel' selected, return empty array.

    aligned = [];
    
    [option, shift, window] = prompt_align(spikes);

    if isempty(option) || ~shift || ~window
        return
    end

    aligned = align_custom(spikes, shift, option, window / 2, window / 2);
    
end