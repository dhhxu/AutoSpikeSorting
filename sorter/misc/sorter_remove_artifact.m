function [real_idx] = sorter_remove_artifact(spikes, threshold)
% SORTER_REMOVE_ARTIFACT removes artifacts using threshold scheme.
%
% REAL_IDX = SORTER_REMOVE_ARTIFACT(SPIKES, THRESHOLD)
%
% Uses threshold scheme to detect and remove electrical artifacts in spike data
% SPIKES. The threshold is set by THRESHOLD (default: 9). Returns the indices of
% non-artifact spikes.
%
% INPUT:
% SPIKES        MxN matrix of spike waveforms. Rows are spikes
% THRESHOLD     (optional) positive integer of the amplitude threshold to detect
%               artifacts. Default: 9
%
% OUTPUT:
% REAL_IDX      Mx1 logical vector, where 1's signifies non-artifact spikes
%
% Source:
% matlab_sorter_technique.m (author: David Martel)

    SetDefaultValue(2, 'threshold', 9);

    if isempty(spikes)
        error('Empty spike matrix');
    elseif threshold < 0
        error('Threshold must be positive: %f', threshold);
    end

    real_idx = filter_artifacts(spikes, threshold);

end

function [real_idx] = filter_artifacts(spikes, threshold)
% Helper function for sorter_remove_artifact

    [~, score, ~, ~, ~] = pca(zscore(spikes), 'NumComponents', 8, ...
                              'Centered', false);

    nSpikes = size(spikes, 1);

    scoremag = zeros(nSpikes, 1);

    for i = 1:8
        scoremag = scoremag + score(:, i).^2;
    end

    scoremag = sqrt(scoremag);

    kept_idx2 = scoremag <= threshold;

    wave_max_min = max(spikes, [], 2) - min(spikes, [], 2);

    outliers = kmeans(log10(wave_max_min), 2);

    if sum(outliers == 1) > sum(outliers == 2)
        outliers(outliers == 2) = 0;
    else
        outliers(outliers == 1) = 0;
        outliers(outliers == 2) = 1;
    end

    real_idx = outliers & kept_idx2;

    artifact_count = sum(~real_idx);
    fprintf('Detected %d artifacts out of %d spikes\n', artifact_count, ...
            nSpikes);
        
    real_idx = logical(real_idx);

end
