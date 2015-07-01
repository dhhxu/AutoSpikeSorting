function [] = plot_spikes_with_mean(cluster, varargin)
% PLOT_SPIKES_WITH_MEAN Plot spikes in a cluster together along with their mean.
%
% PLOT_SPIKES_WITH_MEAN(CLUSTER, ...)
%
% Plots spikes in a CLUSTER on the same graph. Also plots the mean with a black
% line. Additional arguments may be passed into the
% function, which will affect the spikes but not the mean spike. See plot() for
% information on these arguments.
%
% INPUT:
% SPIKES    MxN numeric matrix where each row represents a spike waveform.
% ...       Additional arguments to plotting function. See plot() for
%           information.
%
% OUTPUT:
% NONE

    opengl software;

    figure('Name', 'Spikes');
    hold on;
    for i = 1:size(cluster, 1);
        plot(cluster(i, :), varargin{1:end});
    end
    plot(get_mean_spike(cluster), 'k', 'LineWidth', 3);
    hold off;
    
end