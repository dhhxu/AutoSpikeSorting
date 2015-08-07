function [] = display_clusters(data, class, name)
% DISPLAY_CLUSTERS plot identified unit clusters side by side along with
% their mean spike.
%
% DISPLAY_CLUSTERS(DATA, CLASS, NAME)
%
% INPUT:
% DATA      NxM matrix of spikes. Rows correspond to spikes.
% CLASS     Nx1 integer vector of unit labels. Spikes with labels less than
%           one are ignored.
% NAME      (optional) string for the figure name. Default: 'Figure'
%
% OUTPUT:
% NONE

    SetDefaultValue(3, 'name', 'Figure');
    
    clusters = separate_clusters(data, class);
    
    nClusters = length(clusters);
    
    m = 0;
    n = 0;
    
    switch nClusters
        case 2
            m = 1;
            n = 2;
        case 3
            m = 1;
            n = 3;
        case 4
            m = 2;
            n = 2;
        otherwise
            warning('This number of clusters not supported: %d', nClusters);
    end
    
    % name check
    figure('Name', name);
    
    for i = 1:nClusters
        subplot(m, n, i);
        draw_spikes_with_mean(clusters{i});
    end
end

function [] = draw_spikes_with_mean(cluster)
% similar to PLOT_SPIKES_WITH_MEAN, except without figure part
    hold on;
    for i = 1:size(cluster, 1);
        plot(cluster(i, :), 'b');
    end
    
    mean_spike = get_mean_spike(cluster);
    sd = std(cluster, 0, 1);
    
    plot(mean_spike, 'k', 'LineWidth', 2);
    plot(mean_spike + 2 * sd, 'k--', 'LineWidth', 1);
    plot(mean_spike - 2 * sd, 'k--', 'LineWidth', 1);
    
    hold off;

end