function [option, shift, window] = prompt_align(spikes)
% PROMPT_ALIGN prompt user for spike alignment options.
%
% [OPTION, SHIFT, WINDOW] = PROMPT_ALIGN(SPIKES)
%
% First plots the spikes in matrix SPIKES on top of each other. Then
% prompt the user to select spike alignment according to spike maximum or
% minimum ('max' or 'min'), the shift amount (default: 10 units), and number of
% samples in a spike (default: 32). If an invalid option is entered, keeps
% prompting user unless 'cancel' occurs.
%
% If a 'cancel' occurs then the outputs will be empty, and the caller
% script/function will need to handle the erroneous output.
%
% INPUT:
% SPIKES    NxM matrix where rows are spikes
%
% OUTPUT:
% OPTION    Spike alignment option. Either 'max' or 'min'
% SHIFT     Positive integer of maximum units to shift spikes for alignment
% WINDOW    Positive integer of number of samples in a spike waveform. Ideally
%           an even number. Even better if it's a power of 2.
    
    figurename = 'Alignment';
    plotspikes(spikes, figurename);

    d = defaults();

    option_prompt = sprintf('Alignment option (''max'', ''min'')');
    shift_prompt = sprintf('Shift amount (default: %d)', d.SHIFT);
    win_prompt = sprintf('Number of samples in a spike (default: %d)', ...
                         d.WINDOW);
    prompt = {option_prompt, shift_prompt, win_prompt};
    
    numlines = 1;
    def = {'', num2str(d.SHIFT), num2str(d.WINDOW)};
    title = 'Alignment Options';
    
    while true
        answer = inputdlg(prompt, title, numlines, def);
    
        if isempty(answer)
            warning( ...
                'No options entered. Option, Shift, Window values left empty');
            option = '';
            shift = 0;
            window = 0;
            return;
        end
        
        try
            raw_option = answer{1};
            raw_shift = answer{2};
            raw_win = answer{3};
        catch
            warning('Insufficient fields entered. Please try again.');
            continue;
        end
        
        if ~strcmp(raw_option, 'max') && ~strcmp(raw_option, 'min')
            warning('Invalid alignment option: %s', raw_option);
            continue;
        end
        option = raw_option;
        
        shift = str2double(raw_shift);
        if isnan(shift) || shift < 1 
            warning('Invalid shift option entered. Please try again.');
            def = {option, num2str(d.SHIFT), num2str(d.WINDOW)};
            continue;
        end
        
        window = str2double(raw_win);
        if isnan(window) || window < 1
            warning('Invalid window option entered. Please try again.');
            def = {option, shift, num2str(d.WINDOW)};
            continue;
        else
            close(figurename);
            return;
        end
    end

end