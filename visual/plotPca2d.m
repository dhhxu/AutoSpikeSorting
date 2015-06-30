function [] = plotPca2d(score)
% PLOTPCA2D Scatter plot the first two principal components
%
% PLOTPCA2D(SCORE)
%
% Given the PCA score matrix SCORE, scatter plot the first two principal
% components.
%
% INPUT:
% SCORE     MxN numeric score matrix. N must be at least 2
%
% OUTPUT:
% NONE

    if isempty(score)
        error('Empty score matrix');
    end

    nCols = size(score, 2);
    if nCols < 2
        error('Number of columns must be at least 2: %d', nCols);
    end
    
    pc1 = score(:, 1);
    pc2 = score(:, 2);
    
    opengl software;
    figure('Name', 'PCA 2D');
    scatter(pc1, pc2, 0.9);
    
end