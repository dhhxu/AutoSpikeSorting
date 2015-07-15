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
%   PRE         Number of samples (minus one) to extract before spike
%               occurrence. (Default: 10)
%   POST        Number of samples to extract after spike occurrence.
%               (Default: 22)
%   LO          Left cutoff frequency in Hz. (Default: 300)
%   HI          Right cutoff frequency in Hz. (Default: 3000)
%   SHIFT       Maximum timesteps to shift spike for alignment. (Default: 10)
%
% Generally either WINDOW or PRE & POST will be used at a time.
%
% INPUT:
% NONE
% 
% OUTPUT:
% DEFAULTS  struct whose fields are default values.

    % Number of samples each spike waveform has. Used with symmetric windows.
    DEFAULTS.WINDOW = 32;
    
    % Number of samples minus one before the waveform occurrence.
    DEFAULTS.PRE = 10;
    
    % Number of samples after the waveform occurrence.
    DEFAULTS.POST = 22;
    
    % Left edge of bandpass filter in Hz.
    DEFAULTS.LO = 300;
    
    % Right edge of bandpass filter in Hz.
    DEFAULTS.HI = 3000;
    
    % Maximum spike shift during alignment.
    DEFAULTS.SHIFT = 5;
    
end