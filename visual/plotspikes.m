function [] = plotspikes(spikes, varargin)
% PLOT_SPIKES Plots spikes on top of each other in the same plot.
%
% PLOT_SPIKES(SPIKES, ...)
%
% Plots the spikes in the SPIKES matrix on the same plot. This is to help
% visualize the waveform shapes. Additional arguments may be passed into the
% function.
%
% See also PLOT
%
% INPUT:
% SPIKES    MxN numeric matrix where each row represents a spike waveform.
% ...       Additional arguments to plotting function. See plot() for
%           information.
%
% OUTPUT:
% NONE

    opengl software;

    figure('Name', 'plotspikes');
    hold on;
    for i = 1:size(spikes, 1);
        plot(spikes(i, :), varargin{1:end});
    end
    hold off;
    
end