function [] = make_units(tbl, loc, iter)
% MAKE_UNITS side-by-side comparision of identified spike units and their
% mean cluster spike.
%
% MAKE_UNITS(TBL, LOC, ITER)
%
% Plots all the identified units (i.e. those with non-zero sort code)
% contained in table TBL into side-by-side plots of their respective
% clusters. This function assumes that the number of identified units is no
% greater than 6, for convenience of plotting. If there are more than 6
% units, only the first 6 will be plotted.
%
% Note that TBL should only represent the units on a single channel only.
% All the spikes should have non-zero unit class labels.
%
% The figure is saved to "LOC/ch<channel number>_units_<iter>.fig". If ITER is
% zero the <iter> suffix is dropped.
%
% INPUT:
% TBL       Table containing superblock data
% LOC       String path to directory to save the figure file
% ITER      Integer of number of times the superblock has been previously sorted
%
% OUTPUT:
% NONE

    h = figure('Visible', 'off');

    set(h, 'CreateFcn', 'set(gcf, ''Visible'', ''on'')');
    
    units = unique(tbl.sortc);
    
    nUnits = length(units);
    
    rows = 0;
    cols = 0;
    
    switch nUnits
        case 1
            rows = 1; cols = 1;
        case 2
            rows = 1; cols = 2;
        case 3
            rows = 1; cols = 3;
        case 4
            rows = 2; cols = 2;
        otherwise % nUnits >= 5
            rows = 2; cols = 3;
    end
    
    % colormap
    if nUnits <= 6
        cm = parula(nUnits);
    else
        cm = parula(6);
    end
    
    for i = 1:nUnits
        subplot(rows, cols, i);
        draw_unit_cluster(tbl, i, cm(i, :));
    end
    
    allaxes = findall(gcf, 'type', 'axes');
    linkaxes(allaxes);
    spike_width = size(tbl.waves, 2);
    xlim([0 (spike_width + 1)]);
    
    chan = tbl.chan(1);
    
    fname = sprintf('ch%d_units', chan);
    
    if iter > 0
        fname = sprintf('%s_%d', fname, iter);
    end
    
    fname = sprintf('%s.fig', fname);
    
    savefig(h, fullfile(loc, fname));
    close(h);

end

function [] = draw_unit_cluster(table, unit, color)
% Draw the spikes belonging to unit UNIT on the same figure. Assumes that
% subplot is called before this is called. Also plots the mean spike in a
% thick black line and 95% confidence as dashed black lines.

    unit_spikes = table(table.sortc == unit, :);
    
    nSpikes = length(unit_spikes.sortc);
    
    hold on;
    
    for i = 1:nSpikes
        plot(unit_spikes.waves(i, :), 'Color', color, 'LineWidth', 0.25);
    end
    
%     [mean_spike, ~, bounds, ~] = normfit(unit_spikes.waves);
    mean_spike = get_mean_spike(unit_spikes.waves);
    plot(mean_spike, 'Color', 'k', 'LineWidth', 1);
    
    sd = std(unit_spikes.waves, 0, 2);
    plot(mean_spike + 2 * sd, 'Color', 'r', 'LineWidth', 1, 'LineStyle', '--');
    plot(mean_spike - 2 * sd, 'Color', 'r', 'LineWidth', 1, 'LineStyle', '--');
    
%     plot(bounds(1, :), 'Color', 'k', 'LineWidth', 0.75, 'LineStyle', '--');
%     plot(bounds(2, :), 'Color', 'k', 'LineWidth', 0.75, 'LineStyle', '--');

    hold off;

end
