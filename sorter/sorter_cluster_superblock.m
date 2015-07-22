function [class] = sorter_cluster_superblock(superblocks, procedure, ...
                                             tank_info, sst_path)
% SORTER_CLUSTER_SUPERBLOCK cluster receptive field blocks and construct
% superspiketrain objects for future analysis.
%
% CLASS = SORTER_CLUSTER_SUPERBLOCK(SUPERBLOCKS, PROCEDURE, TANK_INFO, SST_PATH)
%
% Given a one dimensional cell array SUPERBLOCKS containing superblock tables,
% perform clustering on individual channels for each superblock. These
% superblocks come from the tank described by the TANK_INFO struct. See INPUT
% for information on the struct.
% 
% Afterwards, construct superspiketrain objects for each unit found on each
% channel. These objects are saved to the directory located at SST_PATH.
%
% Note that artifacts are filtered out before the clustering step.
%
% The format of the saved SST object name is:
%   SST_RF<RF block number>_Ch<channel number>_Un<unit number>.mat
%
% This function is interactive. The user must provide spike alignment options 
% and the number of clusters.
%
% INPUT:
% SUPERBLOCKS   1 dimensional cell array of superblock tables. Refer to 
%               BUILD_RFBLOCK for table structure details.
% PROCEDURE     Function handle of the clustering procedure function.
% TANK_INFO     Struct containing tank information:
%                   tank    string of tank name
%                   path    string of path to tank directory
% SST_PATH      String of the path to the directory where SST objects are saved
%
% OUTPUT:
% CLASS         ??? todo
% 
% See also BUILD_RFBLOCK, SUPERSPIKETRAIN_DX, SORTER_REMOVE_ARTIFACT.

    try
        tank_name = tank_info.tank;
        tank_path = tank_info.path;
    catch
        error('Invalid tank_info struct');
    end

    nSuperblocks = length(superblocks);

    for i = 1:nSuperblocks
        sb = superblocks{i};

        % artifact filtering
        spike_rows = sorter_remove_artifact(sb.waves);

        valid_sb = sb(spike_rows, :);
        clear sb;

        nChannels = length(unique(valid_sb.chan));

        blocks = sort(unique(valid_sb.block));  % first element is RF block.

        for ch = 1:nChannels
            rows = valid_sb.chan == ch;

            chan_tbl = valid_sb(rows, :);

            % User alignment
            [option, shift] = prompt_snip_align(chan_tbl.waves);
            aligned = align_snip(chan_tbl.waves, shift, option);

            % User K
            K = preview_pca_clusters(aligned, 3);

            class = procedure(aligned, K);

            chan_tbl.sortc = class;

            clear aligned;

            % sst stuff
            sst = superspiketrain_dx(tank_path, blocks, ch, 0, ...
                                     'timestamps', 'sortcode', 'CSPK');
            for unit = 1:K
                sst_copy = sst;
                sst_copy.Unit = unit;

                % remove spikes that are different units and different channel
                unit_idx = chan_tbl.sortc == unit;
                unit_ts = chan_tbl.ts(unit_idx);
                sst_ts = sst_copy.TS;
                sst_copy.Spikes(~ismember(sst_ts, unit_ts), :) = [];

                sst_copy.SortCodeType = 'DanielX';

                % save object to sst directory
                rf = blocks(1);
                sst_varname = sprintf('SST_RF%d_Ch%d_Un%d', rf, ch, unit);
                sst_filename = sprintf('%s.mat', sst_varname);

                var_cmd = sprintf('%s = sst_copy;', sst_varname);
                eval(var_cmd);

                sst_copy_path = fullfile(sst_path, sst_filename);
                save(sst_copy_path, sst_varname);

                clear sst_copy sst_varname;

            end % save SST object loop

            clear chan_tbl sst;

        end % channel loop

        clear valid_sb;

    end % superblock loop

end

