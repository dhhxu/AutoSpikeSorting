function spikes = prepare_spikes(info, channel, align)
% PREPARE_SPIKES extraction and supervised alignment of spikes from a channel.
%
% SPIKES = PREPARE_SPIKES(INFO, CHANNEL, ALIGN)
%
% Given raw spike data in the INFO struct, extract spikes from a particular
% channel CHANNEL and align them. The user will be prompted to enter alignment
% options. Returns a matrix SPIKES of aligned spike waveforms. If an error
% occurs, SPIKES will be empty.
%
% The ALIGN option is boolean. If it is set to True, aligns spikes. If False,
% does not align spikes. Default is True.
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

    SetDefaultValue(3, 'align', true);
    
%% Prepare spike matrix
    dfts = defaults();
    filt = bpf(info.strm.data(channel, :), dfts.LO, dfts.HI, info.strm.fs);
    s = tdt_spikes(filt, info.strm, info.snip, channel, [dfts.PRE, dfts.POST]);

    if align
        spikes = align_fft(s);
%         spikes = handle_align(s);
        spikes = default_align(spikes);
    else
        spikes = s;
    end
end

function aligned = default_align(s)
    d = defaults();
    aligned = align_custom(s, d.SHIFT, 'max', d.PRE, d.POST);
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