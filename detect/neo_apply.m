function [energy] = neo_apply(data, indices)
% NEO_APPLY Calculate energy in data using NEO
%
% ENERGY = NEO_APPLY(DATA, INDICES)
%
% Applies the Non-linear Energy Operator on spike data DATA. Only the INDICES of
% DATA will have their energy calculated by NEO.
%
% INPUT:
% DATA      1xN numeric vector of spike voltage data
% INDICES   1xM integer vector, where 1 <= M <= N, of the indices of points to
%           apply NEO
%
% OUTPUT:
% ENERGY    1xM numeric vector of the energy of the data

    if isempty(data)
        error('Empty data vector');
    elseif isempty(indices)
        error('Empty indices');
    end

    if sum(indices < 1) > 0
        error('Indices must be positive');
    end
    
    energy = zeros(1, length(indices));
    for i = 1:length(indices)
        index = indices(i);
        energy(i) = calc_neo(data, index);
    end
end

function [energy] = calc_neo(data, index)
% Calculate energy for DATA at index INDEX. If INDEX falls out of bounds,
% assumes that the value of DATA(INDEX) is zero.
    energy = data(index) * data(index);
    if index == 1 || index == length(data)
        return;
    else
        energy = energy - data(index - 1) * data(index + 1);
    end
end
