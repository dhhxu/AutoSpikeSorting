function [] = sorter_cluster_superblock(superblocks, feature, algo, mrf, ...
                                             tank_info, data_dir)
% SORTER_CLUSTER_SUPERBLOCK cluster receptive field superblocks and construct
% superspiketrain objects and cluster figures for future analysis.
%
% SORTER_CLUSTER_SUPERBLOCK(SUPERBLOCKS, FEATURE, ALGO, MRF, TANK_INFO, DATA_DIR)
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
%   <Figure type>_ch<channel number>.fig
%
%   Where Figure type is one of the following:
%       <2D>    2D feature space plot 
%       <3D>    3D feature space plot 
%       <pie>   Pie chart of unit proportions 
%       <units> Side-by-side comparision of different units
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
% MRF           boolean that is true if the blocks in the tank have multiple
%               RFs
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
    
    if ~ishandle(feature)
        error('Invalid feature handle');
    elseif ~ishandle(algo)
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
    
    % create metadata file.
    metadata.feature = feature;
    metadata.algo = algo;
    metadata.iter = iter_count; %#ok<STRNU>
    save(fullfile(fig_dir, 'metadata.mat'), 'metadata');

    nSuperblocks = length(superblocks);
    nChannels = length(unique(superblocks{1}.chan));
    
    chBuffer = zeros(nChannels, 1);
    
    % set random seed
    seed = rng(12281990, 'twister');

    for i = 1:nSuperblocks
        sst_sb_dir = fullfile(sst_dir, sprintf('superblock-%d', i));
        fig_sb_dir = fullfile(fig_dir, sprintf('superblock-%d', i));
        
        if ~exist(sst_sb_dir, 'dir')
            % old files already moved; for safety.
            mkdir(sst_sb_dir);
            mkdir(fig_sb_dir);
        end
        
        rng(seed);

        sb = superblocks{i};

        % artifact filtering
        spike_rows = sorter_remove_artifact(sb.waves);

        
        valid_sb = sb(spike_rows, :);
        
        blocks = unique(valid_sb.block);
        
        clear sb;

        for ch = 1:nChannels
            rows = valid_sb.chan == ch;

            chan_tbl = valid_sb(rows, :);


            % User alignment
            [option, shift] = prompt_snip_align(chan_tbl.waves);
            aligned = align_snip(chan_tbl.waves, shift, option);

            % User K
            K = preview_clusters(aligned, feature, 3, chBuffer(ch));
            
            chBuffer(ch) = K;

            class = algo(aligned, K);

            chan_tbl.sortc = class;

            clear aligned class;
            
            % outlier handling: assign sortc of 0 to outliers
            
            
            
            % figures
            
            % 2d feature plot
            make_2d(chan_tbl, feature, fig_sb_dir, iter_count);
            
            % 3d feature plot
            make_3d(chan_tbl, feature, fig_sb_dir, iter_count);
            
            % pie chart
            make_pie(chan_tbl, fig_sb_dir, iter_count);

            % sst stuff
            sst = superspiketrain_dx(tank_path, blocks, ch, 0, ...
                                     'timestamps', 'sortcode', 'CSPK');

            for unit = 1:K
                sst_copy = sst;
                sst_copy.Unit = unit;

                % remove spikes that are different units and different channel
                
                unit_idx = chan_tbl.sortc == unit;
                unit_ts = chan_tbl.ts(unit_idx);
                unit_part = chan_tbl.part(unit_idx);
                
                sst_ts = sst_copy.Spikes.TS;
                sst_copy.Spikes(~ismember(sst_ts, unit_ts), :) = [];
                
                % Add FInd field.
                sst_copy.Spikes.FInd = unit_part(ismember(unit_ts, sst_ts));
                
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

            clear chan_tbl sst;

        end % channel loop

        clear valid_sb;

    end % superblock loop

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
        iteration = meta.iter + 1;
        clear meta
    end
    
end

function [] = move_old_files(fig_dir, sst_dir, iter_count)
% Moves old files in Figures and SST_obj directories to 'old' directory in both.
    
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
    
    if iter_count > 0
        meta_new_name = sprintf('metadata_%d.mat', iter_count);
        movefile(meta_loc, fullfile(old_fig, meta_new_name));
    else
        movefile(meta_loc, old_fig);
    end

end

