function [] = make_3d(tbl, feature, loc, iter, outlier)
% MAKE_3D make 3d feature space plot.
%
% MAKE_3D(TBL, FEATURE, LOC, ITER, OUTLIER)
%
% Plots the feature representation of the spikes on a superblock channel in 3D
% space. The spikes are colored by unit assignment.
%
% The figure is saved to "LOC/3D_ch<channel number>_<iter>.fig". If ITER is zero
% the <iter> suffix is dropped.
%
% If OUTLIER is true, the figure name will instead be:
%   "LOC/3D_ch<channel number>_outlier_<iter>.fig
%
% INPUT:
% TBL       Table containing superblock data
% FEATURE   Handle to the feature transform function
% LOC       String path to directory to save the figure file
% ITER      Integer of number of times the superblock has been previously sorted
% OUTLIER   Boolean. If true, the spikes are outlier spikes and the figure name
%           will be saved with outlier in its name.
%
% OUTPUT:
% NONE
%
% SEE ALSO BUILD_RFBLOCK

    h = figure('Visible', 'off');

    set(h, 'CreateFcn', 'set(gcf, ''Visible'', ''on'')');

    good_idx = tbl.sortc > 0;
    
    fspace = feature(tbl.waves(good_idx, :));
    scatter3(fspace(:, 1), fspace(:, 2), fspace(:, 3), 0.9, tbl.sortc(good_idx));
    
    chan = tbl.chan(1);
    
    fname = sprintf('3D_ch%d', chan);
    
    if outlier
        fname = sprintf('%s_outlier', fname);
    end
    
    if iter > 0
        fname = sprintf('%s_%d', fname, iter);
    end
    
    fname = sprintf('%s.fig', fname);
    
    savefig(h, fullfile(loc, fname));
    close(h);

end
