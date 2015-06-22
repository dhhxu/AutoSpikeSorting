function [] = plot_spikes(spikes)
% PLOT_SPIKES Plots spikes on top of each other in the same plot.
%
% PLOT_SPIKES(spikes)
%
% Plots the spikes in the SPIKES matrix on the same plot. This is to help
% visualize the waveform shapes.
%
% INPUT:
% SPIKES    MxN numeric matrix where each row represents a spike waveform.
%
% OUTPUT:
% NONE

opengl software;

figure('Name', 'Spikes');
hold on;
for i = 1:length(spikes)
    plot(spikes(i, :), 'b');
end
hold off;