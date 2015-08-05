function [] = make_3d(tbl, feature, loc, iter, outlier)
% MAKE_3D make 3d feature space plot.
%
% MAKE_3D(TBL, FEATURE, LOC, ITER, OUTLIER)
%
% Plots the feature representation of the spikes on a superblock channel in 3D
% space. The spikes are colored by unit assignment.
%
% The figure is saved to "LOC/ch<channel number>_3D_<iter>.fig". If ITER is zero
% the <iter> suffix is dropped.
%
% If OUTLIER is true, the figure name will instead be:
%   "LOC/ch<channel number>_3D_outlier_<iter>.fig
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
    
    fspace = feature(tbl.waves);
    
    
    chan = tbl.chan(1);
    
    fname = sprintf('ch%d_3D', chan);
    
    if outlier
        fname = sprintf('%s_outlier', fname);
        scatter3(fspace(:, 1), fspace(:, 2), fspace(:, 3), 0.9, [0.5 0.5 0.5]);
    else
        scatter3(fspace(:, 1), fspace(:, 2), fspace(:, 3), 0.9, tbl.sortc);
    end
    
    if iter > 0
        fname = sprintf('%s_%d', fname, iter);
    end
    
    fname = sprintf('%s.fig', fname);
    
    savefig(h, fullfile(loc, fname));
    close(h);

end
