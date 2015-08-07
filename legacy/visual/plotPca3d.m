function [] = plotPca3d(score, varargin)
% PLOTPCA3D Scatter plot the first three principal components
%
% PLOTPCA3D(SCORE) plots the first three PCs in 3D space. The rows of SCORE are
% the PCA representation of spike waveforms, and the columns correspond to
% principal components, of which the first three are used to plot points.
%
% PLOTPCA3D(SCORE, CLASS) colors the points based on the CLASS vector assigning
% each point to some class number. This creates cluster coloring.
%
% INPUT:
% SCORE     MxN numeric score matrix. N must be at least 3
% CLASS     Mx1 integer vector. The integers represent classes, and each
%           observation is assigned one.
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
    pc3 = score(:, 3);
    
    opengl software;
    figure('Name', 'PCA 3D');
    
    if isempty(varargin)
        scatter3(pc1, pc2, pc3, 0.9);
    else
        scatter3(pc1, pc2, pc3, 0.9, varargin{1});
    end
    
end