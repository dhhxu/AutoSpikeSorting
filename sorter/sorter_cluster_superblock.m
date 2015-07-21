function [class] = sorter_cluster_superblock(superblocks, procedure, sst_path)
% SORTER_CLUSTER_SUPERBLOCK cluster receptive field blocks and construct
% superspiketrain objects for future analysis.
%
% CLASS = SORTER_CLUSTER_SUPERBLOCK(SUPERBLOCKS, PROCEDURE, SST_PATH)
%
% Given a one dimensional cell array SUPERBLOCKS containing superblock tables,
% perform clustering on individual channels for each superblock. Afterwards,
% construct superspiketrain objects for each unit found on each channel. These
% objects are saved to the directory located at SST_PATH.
%
% This function is interactive. The user must provide spike alignment options 
% and the number of clusters.
%
% INPUT:
% SUPERBLOCKS   1 dimensional cell array of superblock tables. Refer to 
%               BUILD_RFBLOCK for table structure details.
% PROCEDURE     Function handle of the clustering procedure function.
% SST_PATH      String of the path to the directory where SST objects are saved
%
% OUTPUT:
% CLASS         ??? todo
% 
% See also BUILD_RFBLOCK, SUPERSPIKETRAIN_DX.

    nSuperblocks = length(superblocks);

    for i = 1:nSuperblocks

        sb = superblocks{i};

        nChannels = length(unique(sb.chan));

        for j = 1:nChannels
            rows = sb.chan == j;

            spikes = sb.waves(rows);

            % User alignment
            [option, shift] = prompt_snip_align(spikes);
            aligned = align_snip(spikes, shift, option);
            
            clear spikes;

            % User K
            K = preview_pca_clusters(aligned, 3);

            class = procedure(aligned, K);

            clear aligned;

            sub_sb = sb(rows, :);
            sub_sb.sortc = class;

            % sst stuff

            for unit = 1:K

                
            end

        end

    end

end

