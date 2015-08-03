function [] = make_2d(tbl, feature, loc, iter)
% MAKE_2D make 2d feature space plot.
%
% MAKE_2D(TBL, FEATURE, LOC, ITER)
%
% Plots the feature representation of the spikes on a superblock channel in 2D
% space. The spikes are colored by unit assignment.
%
% The figure is saved to "LOC/2D_ch<channel number>_<iter>.fig". If ITER is zero
% the <iter> suffix is dropped.
%
% INPUT:
% TBL       Table containing superblock data for a particular channel
% FEATURE   Handle to the feature transform function
% LOC       String path to directory to save the figure file
% ITER      Integer of number of times the superblock has been previously sorted
%
% OUTPUT:
% NONE
%
% SEE ALSO BUILD_RFBLOCK

    h = figure('Visible', 'off');
    
    set(h, 'CreateFcn', 'set(gcf, ''Visible'', ''on'')');
    
    good_idx = tbl.sortc > 0;
    
    fspace = feature(tbl.waves(good_idx, :));
    scatter(fspace(:, 1), fspace(:, 2), 0.9, tbl.sortc(good_idx));
    
    chan = tbl.chan(1);
    
    fname = sprintf('2D_ch%d', chan);
    
    if iter > 0
        fname = sprintf('%s_%d', fname, iter);
    end
    
    fname = sprintf('%s.fig', fname);
    
    savefig(h, fullfile(loc, fname));
    close(h);
end