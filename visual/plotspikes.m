function [] = plotspikes(spikes, title, varargin)
% PLOTSPIKES Plots spikes on top of each other in the same plot.
%
% PLOTSPIKES(SPIKES, TITLE, ...)
%
% Plots the spikes in the SPIKES matrix on the same plot. This is to help
% visualize the waveform shapes. Additional arguments may be passed into the
% function. The figure will have title TITLE to help distinguish between several
% figures.
%
% See also PLOT
%
% INPUT:
% SPIKES    MxN numeric matrix where each row represents a spike waveform.
% TITLE     String for the figure title. (Default: 'Figure')
% ...       Additional arguments to plotting function. See plot() for
%           information.
%
% OUTPUT:
% NONE

    SetDefaultValue(2, 'title', 'Figure');

    opengl software;

    figure('Name', title);
    hold on;
    for i = 1:size(spikes, 1);
        plot(spikes(i, :), varargin{1:end});
    end
    hold off;
    
end