function [] = plotPca3d(score)
% PLOTPCA3D Scatter plot the first two principal components
%
% PLOTPCA3D(score)
%
% Given the PCA score matrix SCORE, scatter plot the first three principal
% components.
%
% INPUT:
% SCORE     MxN numeric score matrix. N must be at least 3
%
% OUTPUT:
% NONE

    if isempty(score)
        error('Empty score matrix');
    end

    nCols = size(score, 2);
    if nCols < 3
        error('Number of columns must be at least 3: %d', nCols);
    end
    
    pc1 = score(:, 1);
    pc2 = score(:, 2);
    pc3 = score(:, 3);
    
    opengl software;
    figure('Name', 'PCA 3D');
    scatter3(pc1, pc2, pc3, 0.9);
    
end