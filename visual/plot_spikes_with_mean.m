function [] = plot_spikes_with_mean(cluster, title, varargin)
% PLOT_SPIKES_WITH_MEAN Plot spikes in a cluster together along with their mean.
%
% PLOT_SPIKES_WITH_MEAN(CLUSTER, TITLE, ...)
%
% Plots spikes in a CLUSTER on the same graph. Also plots the mean with a black
% line as well as two standard deviations above and below the mean spike in 
% black dashed lines. Additional arguments may be passed into the
% function, which will affect the spikes but not the mean spike. See plot() for
% information on these arguments.
% 
% The resulting figure will have name TITLE, for ease in keeping track of
% multiple figures.
%
% INPUT:
% CLUSTER   MxN numeric matrix where each row represents a spike waveform.
% TITLE     String for the figure name. 
% ...       Additional arguments to plotting function. See plot() for
%           information.
%
% OUTPUT:
% NONE

    if isempty(title)
        error('Empty figure title string');
    end

    opengl software;

    figure('Name', title);
    hold on;
    for i = 1:size(cluster, 1);
        plot(cluster(i, :), varargin{1:end});
    end
    
    mean_spike = get_mean_spike(cluster);
    sd = std(cluster, 0, 1);
    
    plot(mean_spike, 'k', 'LineWidth', 2);
    plot(mean_spike + 2 * sd, 'k--', 'LineWidth', 1);
    plot(mean_spike - 2 * sd, 'k--', 'LineWidth', 1);
    
    hold off;
    
end