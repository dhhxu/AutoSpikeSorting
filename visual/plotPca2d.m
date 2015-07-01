function [] = plotPca2d(score, varargin)
% PLOTPCA2D Scatter plot the first two principal components
%
% PLOTPCA2D(SCORE) plots the first two PCs in 2D space. The rows of SCORE are
% the PCA representation of spike waveforms, and the columns correspond to
% principal components, of which the first two are used to plot points.
%
% PLOTPCA2D(SCORE, CLASS) colors the points based on the CLASS vector assigning
% each point to some class number. This creates cluster coloring.
%
% INPUT:
% SCORE     MxN numeric score matrix. N must be at least 2
% CLASS     Mx1 integer vector. The integers represent classes, and each
%           observation is assigned one.
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
    
    if nargin > 2
        error('Too many arguments: %d', nargin);
    elseif nargin == 2
        if length(varargin{1}) ~= length(score)
            error('Classification vector has wrong dimensions: %d', ...
                length(varargin{1}));
        end
    end
    
    pc1 = score(:, 1);
    pc2 = score(:, 2);
    
    opengl software;
    figure('Name', 'PCA 2D');
    if isempty(varargin)
        scatter(pc1, pc2, 0.9);
    else
        gscatter(pc1, pc2, varargin{1});
    end
    
end