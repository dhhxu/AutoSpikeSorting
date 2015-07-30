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
% The format of the metadata struct is:
%   metadata.mat
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

    nSuperblocks = length(superblocks);
    nChannels = length(unique(superblocks{1}.chan));
    
    chBuffer = zeros(nChannels, 1);
    
    % set random seed
    seed = rng(12281990, 'twister');

    for i = 1:nSuperblocks
        rng(seed);

        sb = superblocks{i};

        % artifact filtering
        spike_rows = sorter_remove_artifact(sb.waves);

        valid_sb = sb(spike_rows, :);
        clear sb;

        blocks = unique(valid_sb.block);  % first element is RF block.
        
        sb_sst_dir = fullfile(sst_dir, sprintf('superblock-%d', i));
        sb_fig_dir = fullfile(fig_dir, sprintf('superblock-%d', i));
        
        
        if ~exist(sb_sst_dir, 'dir')
            version = 0;
            mkdir(sb_sst_dir);
            mkdir(sb_fig_dir);  % implied
        else
            % get list of old sst files
            % get version count by splitting a file name on underscore
            
        end

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

            % sst stuff
            if mrf
                % handle find filtering
            else
                sst = superspiketrain_dx(tank_path, blocks, ch, 0, ...
                                         'timestamps', 'sortcode', 'CSPK');
            end

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
                sst_varname = sprintf('SST_ch%d_un%d', ch, unit);
                sst_filename = sprintf('%s.mat', sst_varname);

                var_cmd = sprintf('%s = sst_copy;', sst_varname);
                eval(var_cmd);
                
                

                sst_copy_path = fullfile(data_dir, sst_filename);
                save(sst_copy_path, sst_varname);

                clear sst_copy sst_varname;

            end % save SST object loop

            clear chan_tbl sst;

        end % channel loop

        clear valid_sb;

    end % superblock loop

end
