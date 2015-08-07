function [channel] = prompt_channel(nChannels)
% PROMPT_CHANNEL prompt user to input a channel number.
%
% CHANNEL = PROMPT_CHANNEL(NCHANNELS)
%
% Prompt the user to enter an integer between 1 and NCHANNELS. If the input is
% invalid, this function will keep prompting the user.
%
% Note that while 'cancel' is supported, this function will return 0, an
% erroneous result. So the best way to use this function is to enclose it in its
% own section and re-run it to get a non-erroneous channel number if the
% function was previously terminated.
%
% INPUT:
% NCHANNELS     Maximum channel number
%
% OUTPUT:
% CHANNEL       User chosen channel. Must be an integer between 1 and NCHANNELS

    if nChannels < 1
        error('Invalid number of channels');
    end
    
    prompt = {sprintf('Enter the Channel Number (1 - %d)', nChannels)};
    numlines = 1;
    name = 'Channel Number';
    
    while true
        raw_channel = inputdlg(prompt, name, numlines);
        if isempty(raw_channel)
            warning('No channel selected. Aborting with a channel of 0');
            channel = 0;
            return;
        end
        
        [channel, status] = str2num(raw_channel{1});
        if ~status || channel < 1 || channel > nChannels
            warning('Invalid channel entered. Channel must be an integer.');
            continue;
        else
            return;
        end
    end
    
end