function [opt, shift]= prompt_snip_align(snips, max_wav)
% PROMPT_SNIP_ALIGN prompt user for snippet alignment options
%
% [OPT, SHIFT] = PROMPT_SNIP_ALIGN(SNIPS)
%                Prompt user for what feature to align waveforms on.
%
% [OPT, SHIFT] = PROMPT_SNIP_ALIGN(SNIPS, MAX_WAV)
%                Display only MAX_WAV waveforms in the preview. Useful when
%                there are a large number of waveforms. (Default: 6000)
%                The MAX_WAV waveforms are sampled randomly from all waveforms.
%
% Supervised alignment of snippet data. The data is from TDT and waveforms
% are assumed to be 30 samples wide. The user supervises the alignment by
% entering the feature to align snippet spikes on based on a preview of the
% principal components of the data as well as the maximum shift. The
% options chosen by the user are returned by this function.
%
% If an erroneous value is entered, OPT is empty string and/or SHIFT is zero.
% The caller function is responsible for handling this case.
%
% This assumes that the window (30 samples) is symmetric.
%
% MAX_WAV is an optional argument that caps how many spikes are displayed
% in the preview. The spikes are sampled randomly MAX_WAV times without
% replacement from all waveforms. Lower values increase rendering performance,
% at a cost of potential misjudgment of alignment options due to fewer spikes.
%
% INPUT:
% SNIPS     Nx30 matrix of snippet spikes. Rows are spikes
% MAX_WAV   (optional) maximum number of spikes to display in preview.
%           Default(6000)
%
% OUTPUT:
% OPT       Alignment feature. Either 'max' or 'min'
% SHIFT     Positive integer of maximum time steps to shift spikes for
%           alignment.

    SetDefaultValue(2, 'max_wav', 6000);
    
    if max_wav < 1
        error('max_wav must be positive');
    end
    
    FIGNAME = 'Snip Align';
    
    nSpikes = size(snips, 1);
    if nSpikes > max_wav
        chosen = randsample(nSpikes, max_wav);
        plotspikes(snips(chosen, :), FIGNAME);
    else
        plotspikes(snips, FIGNAME);
    end
    
    d = defaults();
    
    opt_prompt = 'Alignment option (''max'', ''min'')';
    shift_prompt = sprintf('Shift amount (default: %d)', d.SHIFT);
    prompt = {opt_prompt, shift_prompt};
    
    % Don't lock focus on dialog.
    options.WindowStyle = 'normal';
    
    numlines = 1;
    def = {'', num2str(d.SHIFT)};
    title = FIGNAME;
    
    answer = inputdlg(prompt, title, numlines, def, options);
    
    [opt, shift] = parse_input(answer, FIGNAME);

end

function [opt, shift] = parse_input(answer, name)
% Parse user input for option and shift. If invalid, either OPT and/or
% SHIFT will be empty and zero, respectively.
% Closes the figure named NAME before returning to caller.

    opt = '';
    shift = 0;
    if isempty(answer)
        close(name);
        return;
    end
    
    try
        raw_opt = answer{1};
        raw_shift = answer{2};
    catch
        close(name);
        return;
    end
    
    if ~strcmp(raw_opt, 'max') && ~strcmp(raw_option, 'min')
        warning('Invalid alignment option: %s', raw_opt);
        return;
    else
        opt = raw_option;
    end
    
    shift = str2double(raw_shift);
    if isnan(shift) || shift < 1
        warning('Invalid shift option');
        shift = 0;
        close(name);
        return;
    end
    
    close(name);
    
end