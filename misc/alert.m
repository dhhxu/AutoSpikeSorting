function [] = alert(message, newline)
% ALERT Print status message with caller function name.
%
% ALERT(MESSAGE)
%
% ALERT(MESSAGE, NEWLINE)
%
% Prints a message of form: <FUNCTION NAME>: MESSAGE
%
% By default, the message is \n terminated. Set the NEWLINE option to False to
% disable \n termination (default: True).
%
% INPUT:
% MESSAGE   string to print
% NEWLINE   (optional) boolean. If false, don't terminate with newline.
%           (Default: True)
%
% OUTPUT
% NONE

    SetDefaultValue(2, 'newline', true);
    
    out = sprintf('%s: %s', mfilename, message);
    
    if ~newline
        fprintf(out);
    else
        fprintf('%s\n', out);
    end

end