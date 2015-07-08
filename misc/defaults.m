function DEFAULTS = defaults
% DEFAULTS returns a struct containing default values.
%
% DEFAULTS = defaults
%
% Constants function returning a struct containing default values for several
% spike sorting processing functions.
%
% Fields in the struct:
%   WINDOW
%   LO
%   HI
%   SHIFT
%
% INPUT:
% NONE
% 
% OUTPUT:
% DEFAULTS  struct whose fields are default values.

    % Number of samples each spike waveform has. Used with symmetric windows.
    DEFAULTS.WINDOW = 32;
    
    % Left edge of bandpass filter in Hz.
    DEFAULTS.LO = 300;
    
    % Right edge of bandpass filter in Hz.
    DEFAULTS.HI = 3000;
    
    % Maximum spike shift during alignment.
    DEFAULTS.SHIFT = 10;
    
end