function [] = make_pie(tbl, loc, iter)
% MAKE_PIE create pie chart showing unit assignment proportion and save it to
% file.
%
% Pie chart of identified units (non-zero class label) proportions.
%
% The figure is saved to "LOC/ch<channel number>_pie_<iter>.fig". If ITER is
% zero the <iter> suffix is dropped.
%
% INPUT:
% TBL   Table containing superblock data. May contain outliers, which will be
%       ignored.
% LOC   String path to directory to save the figure file
% ITER  Integer of number of times the superblock has been previously sorted
%
% OUTPUT: 
% NONE

    h = figure('Visible', 'off');
    set(h, 'CreateFcn', 'set(gcf, ''Visible'', ''on'')');

    good_idx = tbl.sortc > 0;
    
    K = length(unique(tbl.sortc(good_idx)));
    
    proports = zeros(1, K);
    
    for i = 1:K
        class_idx = tbl.sortc == i;
        proports(i) = sum(class_idx);
    end
    
%     labels = strtrim(cellstr(num2str((1:K)'))');
%     pie(proports, labels);
    pie(proports);
    
    chan = tbl.chan(1);

    fname = sprintf('ch%d_pie', chan);

    if iter > 0
        fname = sprintf('%s_%d', fname, iter);
    end
    
    fname = sprintf('%s.fig', fname);
    
    savefig(h, fullfile(loc, fname));
    close(h);

end