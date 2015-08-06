function [] = make_allspikes(tbl, loc, iter)
% MAKE_ALLSPIKES plots all the outlier waves in the superblock table in a single
% plot.
%
% MAKE_ALLSPIKES(TBL, LOC, ITER)
%
% Plots all the outlier spikes in table TBL in a single plot. TBL should
% represent all outliers for a single channel only.
%
% The figure is saved to "LOC/ch<channel number>_out_<iter>.fig". If ITER is
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
    
    nSpikes = length(tbl.sortc);
    
    hold on;
    
    for i = 1:nSpikes
        plot(tbl.waves(i, :), 'Color', [0.5 0.5 0.5]);
    end
    
    hold off;
    
    chan = tbl.chan(1);
    
    fname = sprintf('ch%d_out', chan);
    
    if iter > 0
        fname = sprintf('%s_%d', fname, iter);
    end
    
    fname = sprintf('%s.fig', fname);
    
    savefig(h, fullfile(loc, fname));
    close(h);

end
