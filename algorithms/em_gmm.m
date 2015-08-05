function class = em_gmm(data, k)
% EM_GMM Expectation Maximization with Gaussian Mixture Model algorithm
%
% CLASS = EM_GMM(DATA, K)
%
% Wrapper for Michael Chen's EMGM function for use with sorter program.
% 
% INPUT:
% DATA      NxM matrix of spikes. Rows are spikes
% K         integer of number of clusters to partition DATA into
%
% OUTPUT:
% CLASS     Nx1 vector of integer class labels.
%
% Source:
% Michael Chen (sth4nth@gmail.com)
%
% See also EMGM
    
    [class, ~, ~] = emgm(data.', k);
    
    class = class.';

end

