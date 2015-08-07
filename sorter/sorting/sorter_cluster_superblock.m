function [] = sorter_cluster_superblock(superblocks, feature, algo, ...
                                             tank_info, data_dir)
% SORTER_CLUSTER_SUPERBLOCK cluster receptive field superblocks and construct
% superspiketrain objects and cluster figures for future analysis.
%
% SORTER_CLUSTER_SUPERBLOCK(SUPERBLOCKS, FEATURE, ALGO, RFS, TANK_INFO, DATA_DIR)
%
% Given a one dimensional cell array SUPERBLOCKS containing superblock tables,
% perform clustering on individual channels for each superblock. These
% superblocks come from the tank described by the TANK_INFO struct.
% 
% Afterwards, construct superspiketrain objects for each unit found on each
% channel. Also constructs figures and statistics of sorting results for later
% analysis and/or evaluation.
%
% DATA_DIR is the path to where the output files will be stored. The files will
% be stored in the following manner:
% 
% A directory with the same name as the tank name will be created (if it doesn't
% exist). Within that directory, directories for each superblock will be created
% (if they don't already exist).
%
% These superblock directories will be named superblock-X, where X is the
% superblock index. Within a superblock directory two directories will be
% created: SST_obj and Figures. Superspiketrain objects and figures/metadata
% will be stored in those two directories, respectively.
%
% In the hopefully rare case that this function is run again on the same
% superblock data, the new data will have the same name as the old data with a 
% '_(X)' appended, where X is the number of repeat runs. The old data will be
% moved into a separate folder in SST_obj and Figures called 'old.'
%
% Note that artifacts are filtered out before the clustering step.
%
% The format of the saved SST object name is:
%   SST_ch<channel number>_un<unit number>.mat
%
% The format of the saved figure name is:
%   ch<channel number>_<Figure type>.fig
%
%   Where Figure type is one of the following:
%       <2D>    2D feature space plot 
%       <3D>    3D feature space plot 
%       <pie>   Pie chart of unit proportions 
%       <units> Side-by-side comparision of different units
%       <out>   Plot of all outlier spikes in original form
%       <2D_outliers> Same as <2D>, except with outlier spikes
%       <3D_outliers> Same as <3D>, except with outlier spikes
%
% The metadata file will be stored as metadata.mat and will be located in the
% Figures directory. On a repeat sort, only old files will be renamed based on
% naming conventions. This means that the newest file will still be called
% metadata.mat. It is only on a repeat sort that this previously newest file
% will be renamed as per convention.
% The fields of the struct are:
%   feature     handle of the feature function
%   algo        handle of the algorithm function
%   iter        run count
%   nFeature    NxM matrix of feature dimension size. Rows correspond to
%               channels, columns correspond to superblock number.
%
% This function is interactive. The user must provide spike alignment options 
% and the number of clusters.
%
% INPUT:
% SUPERBLOCKS   1 dimensional cell array of superblock tables. Refer to 
%               BUILD_RFBLOCK for table structure details.
% FEATURE       function handle that transforms the original data to the feature
%               space. It accepts a matrix of spikes and returns a matrix of the
%               spikes in the feature space.
% ALGO          function handle of the clustering algorithm. It should take in
%               two parameters: the transformed spikes and the number of units,
%               which is user-determined.
% TANK_INFO     Struct containing tank information:
%                   tank    string of tank name
%                   path    string of path to tank directory
% DATA_DIR      String of the path to the directory to where the directory
%               storing output data from the clustering is to be located.
%
% OUTPUT:
% NONE
% 
% See also BUILD_RFBLOCK, SUPERSPIKETRAIN_DX, SORTER_REMOVE_ARTIFACT.

    try
        tank_name = tank_info.tank;
        tank_path = tank_info.path;
    catch
        error('Invalid tank_info struct');
    end
    
    if ~isa(feature, 'function_handle')
        error('Invalid feature handle');
    elseif ~isa(algo, 'function_handle')
        error('Invalid algorithm handle');
    end
    
    tank_dir = fullfile(data_dir, tank_name);
    sst_dir = fullfile(tank_dir, 'SST_obj');
    fig_dir = fullfile(tank_dir, 'Figures');
    
    if ~exist(tank_dir, 'dir')
        mkdir(tank_dir);
    end
    
    if ~exist(sst_dir, 'dir')
        mkdir(sst_dir);
    end
    
    if ~exist(fig_dir, 'dir')
        mkdir(fig_dir);
    end

    iter_count = run_count(fig_dir);
    
    if iter_count > 0
        % After this, we assume that Figures and SST_obj directories will be
        % empty and that metadata.mat doesn't exist in Figures.
        move_old_files(fig_dir, sst_dir, iter_count);
    end
    
    nSuperblocks = length(superblocks);
    nChannels = length(unique(superblocks{1}.chan));
    
    
    nFeatures = zeros(nChannels, nSuperblocks);
    
    % channels should have roughly same number of units across superblocks.
    % Assumes that each superblock has same number of channels.
    chBuffer = zeros(nChannels, 1);
    
    % set random seed
    seed = rng(12281990, 'twister');

    for i = 1:nSuperblocks
        sst_sb_dir = fullfile(sst_dir, sprintf('superblock-%d', i));
        fig_sb_dir = fullfile(fig_dir, sprintf('superblock-%d', i));
        
        if ~exist(sst_sb_dir, 'dir')
            % old files already moved; superblock directories shouldn't exist.
            mkdir(sst_sb_dir);
            mkdir(fig_sb_dir);
        end
        
        rng(seed);

        sb = superblocks{i};
        
        blocks = unique(sb.block);
        
%         for ch = 1:nChannels
        for ch = 1:1
            rows = sb.chan == ch;
            chan_tbl = sb(rows, :);

            % User alignment
            [option, shift] = prompt_snip_align(chan_tbl.waves);
            aligned = align_snip(chan_tbl.waves, shift, option);

            % User K
            warning('off', 'all');
            K = preview_clusters(aligned, feature, 3, chBuffer(ch));
            warning('on', 'all');

            chBuffer(ch) = K;
            
            fspace = feature(aligned);
            
            nFeatures(ch, i) = size(fspace, 2);

            class = algo(fspace, K);
            
            clear aligned
            
            warning('off', 'all');

            % outlier handling: assign sortc of 0 to outliers
            chan_tbl.sortc = find_outliers(feature(chan_tbl.waves), class);
            
            clear class
            
            % figures
            
            % zero unit is for outliers
            outliers = chan_tbl(chan_tbl.sortc == 0, :);
            real = chan_tbl(chan_tbl.sortc ~= 0, :);
            
            % 2d feature plot
            make_2d(real, feature, fig_sb_dir, iter_count, false);
            make_2d(outliers, feature, fig_sb_dir, iter_count, true);
            
            % 3d feature plot
            make_3d(real, feature, fig_sb_dir, iter_count, false);
            make_3d(outliers, feature, fig_sb_dir, iter_count, true);
            
            warning('on', 'all');

            % pie chart (real only)
            make_pie(real, fig_sb_dir, iter_count);
            
            % spike plot (outliers only)
            make_allspikes(outliers, fig_sb_dir, iter_count);
            
            % side by side plot (real only)
            make_units(real, fig_sb_dir, iter_count);

            % sst stuff
            sst = superspiketrain_dx(tank_path, blocks, ch, 0, i, ...
                                     'timestamps', 'sortcode', 'CSPK');
                
            % prune parts that don't match
            for bIdx = 1:length(blocks)
                block_num = blocks(bIdx);
                block_rows = chan_tbl.block == block_num;
                block_tbl = chan_tbl(block_rows, :);
                
                parts = unique(block_tbl.part);
                
                if length(parts) == 1    % block is entire RF; keep all parts.
                    continue
                end
                
                epoc_blk_idx = sst.Epocs.Values.Block == block_num;
                
                val_blk = sst.Epocs.Values(epoc_blk_idx, :);
                
                % indices of matching parts -- inverse are rows to remove
                part_match_idx = ismember(val_blk.find, parts);
                
                % get indices of rows corresponding to current block.
                row_idx = find(epoc_blk_idx);

                non_part_idx = row_idx(~part_match_idx);
                
                sst.Epocs.Values(non_part_idx, :) = [];
                sst.Epocs.TSOn(non_part_idx, :) = [];
                sst.Epocs.TSOff(non_part_idx, :) = [];
                
                clear val_blk epoc_blk_idx
                clear block_rows block_tbl
            end

            for unit = 0:K
                sst_copy = sst;
                sst_copy.Unit = unit;

                % remove spikes that are different units
                
                unit_idx = chan_tbl.sortc == unit;
                unit_ts = chan_tbl.ts(unit_idx);
                unit_part = chan_tbl.part(unit_idx);
                
                sst_ts = sst_copy.Spikes.TS;
                sst_copy.Spikes(~ismember(sst_ts, unit_ts), :) = [];
                
                % Add FInd field.
                warning('off', 'all');
                sst_copy.Spikes.FInd = unit_part(ismember(unit_ts, sst_ts));
                warning('on', 'all');
                sst_copy.SortCodeType = 'DanielX';
                

                % save object to sst directory
                sst_varname = sprintf('SST_ch%d_un%d', ch, unit);
                
                if iter_count > 0
                    sst_varname = sprintf('%s_%d', sst_varname, iter_count);
                end
                
                var_cmd = sprintf('%s = sst_copy;', sst_varname);
                eval(var_cmd);
                
                sst_filename = sprintf('%s.mat', sst_varname);
                sst_copy_path = fullfile(sst_sb_dir, sst_filename);
                save(sst_copy_path, sst_varname);

                clear sst_copy sst_varname;
                
            end % save SST object loop

            clear chan_tbl sst real outliers;

        end % channel loop

        clear sb;

    end % superblock loop

    % create metadata file.
    metadata.feature = feature;
    metadata.algo = algo;
    metadata.iter = iter_count;
    metadata.nFeatures = nFeatures;  %#ok<STRNU>
    save(fullfile(fig_dir, 'metadata.mat'), 'metadata');

end

function [iteration] = run_count(fig_dir)
% Returns the number of times the tank's superblocks have been sorted. If this
% is the first time the tank has been sorted, returns 0. Otherwise, returns a
% positive integer.
    
    iteration = 0;

    meta_loc = fullfile(fig_dir, 'metadata.mat');
    if ~exist(meta_loc, 'file')
        return
    else
        meta = load(meta_loc);
        metadata = meta.metadata;
        iteration = metadata.iter + 1;
        clear meta
    end
    
end

function [] = move_old_files(fig_dir, sst_dir, iter_count)
% Moves old files in Figures and SST_obj directories to 'old' directory in both.
% ITER_COUNT is the number of times the sort has been called on the same
% data.
%
% Note the first time this function is called, ITER_COUNT is one (1).
    
    old_fig = fullfile(fig_dir, 'old');
    old_sst = fullfile(sst_dir, 'old');
    
    if ~exist(old_fig, 'dir')
        mkdir(old_fig);
    end
    
    if ~exist(old_sst, 'dir')
        mkdir(old_sst);
    end
    
    fig_sb = fullfile(fig_dir, 'superblock-*');
    sst_sb = fullfile(sst_dir, 'superblock-*');
    
    % move superblock directories
    movefile(fig_sb, old_fig);
    movefile(sst_sb, old_sst);
    
    % move metadata file

    meta_loc = fullfile(fig_dir, 'metadata.mat');
    
    if iter_count - 1 > 0
        meta_new_name = sprintf('metadata_%d.mat', iter_count - 1);
        movefile(meta_loc, fullfile(old_fig, meta_new_name));
    else
        movefile(meta_loc, old_fig);
    end

end

