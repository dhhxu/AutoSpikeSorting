function DEFAULTS = defaults()
% DEFAULTS returns a struct containing default values.
%
% DEFAULTS = defaults
%
% Constants function returning a struct containing default values for several
% spike sorting processing functions.
%
% Fields in the struct:
%   WINDOW      Number of samples to extract froms spike. (Default: 32)
%   LO          Left cutoff frequency in Hz. (Default: 300)
%   HI          Right cutoff frequency in Hz. (Default: 3000)
%   SHIFT       Maximum timesteps to shift spike for alignment. (Default: 10)
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