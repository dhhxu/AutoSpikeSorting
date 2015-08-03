function [superblocks, rfs, mrf] = build_rfblock(path, save_dir, rfs_user)
% BUILD_RFBLOCKS Joins receptive field blocks into one superblock for all RFs in
% a tank.
%
% [SUPERBLOCKS, RFS, MRF] = BUILD_RFBLOCK(PATH, SAVE_DIR)
%                           Join blocks containing same receptive fields into
%                           superblocks. RF blocks are detected automatically.
%                           User will be asked to confirm the detected blocks.
%
% [SUPERBLOCKS, RFS, MRF] = BUILD_RFBLOCK(PATH, SAVE_DIR, RFS_USER)
%                           Override automatic RF detection with user-supplied
%                           RF block indices.
%           
% For an input tank, determine receptive field sections and for each section
% identified, merge it with succeeding non-receptive field blocks until another
% receptive field section is found. Repeat this process for all receptive field
% sections. Note this means this function can handle two cases: a) the simple
% case where each block has at most one RF, and b) the harder case where some
% blocks have more than one RF. Be aware that the harder case requires more time
% to run.
%
% Artifacts, if present, will be removed.
%
% The tank is located at absolute path PATH. Finally, the result is
% saved to the SAVE_DIR directory. The result is saved to a .mat file:
%
%   <TANK_NAME>_superblocks.mat
%
% Note that if this function is invoked on the same tank again, it will load the
% saved .mat file, if that file is in SAVE_DIR. Also, the saved file by
% construction has a 'rfs' field that contains correct RF information.
%
% SUPERBLOCKS is a one dimensional cell array. Each element contains
% a "superblock" table created from a receptive field section and its ensuing
% non-receptive field sections. See the OUTPUT section below for more details.
%
% When this script is called, the user will be asked if he/she wants RFs to be
% detected automatically. This will only happen if the RFS parameter is not
% included or is an empty array. Otherwise, the user has supplied an input to
% the RFS parameter. If it is invalid, the function will terminate and the
% output SUPERBLOCKS will be an empty cell.
%
% INPUT:
% PATH          String of the absolute path to the tank
% ROOT          String of the absolute path of the project root. Generally will
%               be the value of 'pwd'
% RFS_USER      (optional) 1xN cell structure. Each element is an 1xK vector in
%               the following format:
%                   [Block number, part A, ...]
%               If a block is a single RF, use [Block number, 1]
%               If a block has multiple RFs, use [Block number, part A, part
%               B...]. The part numbers must be unique, positive, and increasing
%               order.
%               N is the number of blocks in the tank.
%               If a block is not a RF, use [Block number] (scalar)
%
% OUTPUT:
% SUPERBLOCKS   1 dimensional cell. Each element is a superblock table with the
%               following fields:
%                   block   Nx1 vector of block numbers
%                   chan    Nx1 vector of channel numbers
%                   ts      Nx1 vector of waveform timestamps
%                   sortc   Nx1 vector of unit assignments (initially all zeros)
%                   waves   Nx30 vector of snippet waveforms
%                   part    Nx1 vector of part numbers
% RFS           1xN cell that is the output of either FIND_RFS or the same
%               as the user override, if valid.
% MRF           boolean. True if RFS has blocks that have multiple RFs.
%
% See also FIND_RFS, REMOVE_EAMP_ARTIFACT, TDT2MAT.

    if ~exist(save_dir, 'dir')
        error('Invalid save directory');
    elseif ~exist(path, 'dir')
        error('Tank not found: %s', path);
    end

    SetDefaultValue(3, 'rfs_user', cell(0));
    SetDefaultValue(4, 'suppress', false);
    
    [superblocks, rfs, mrf] = get_superblock(path, save_dir, rfs_user);
    
end

function [superblocks, rfs, mrf] = get_superblock(path, save_dir, rfs_user)
% Helper function. If saved superblock .mat file for the tank does not exist,
% creates one normally. Otherwise, it exists at directory whose path is
% SAVE_DIR.

    [~, tank_name, ~] = fileparts(path);
    mat_name = sprintf('%s_superblocks.mat', tank_name);
    mat_path = fullfile(save_dir, mat_name);
    
    % this function was previously called on tank
    if exist(mat_path, 'file')
        fprintf('superblock file found for tank %s\n', tank_name);
        fprintf('Loading it...\n');
        
        tmp = load(mat_path);
        superblocks = tmp.superblocks;
        rfs = tmp.rfs;
        mrf = has_multiple_rfs(rfs);
        clear tmp;
        
        return;

    end
       
    fprintf('superblock file not found for tank %s\n', tank_name);

    superblocks = cell(0);
    rfs = cell(0);

    if isempty(rfs_user)
        if ~user_confirm_auto()
            fprintf('User declined automatic RF detection. Exiting.\n');
            return
        end

        fprintf('Automatically detecting receptive fields...\n');
        rfs = find_rfs(path);

    else
        nBlocks = block_count(path);
        
        if ~isValidRFcell(rfs_user, nBlocks)
            fprintf('Invalid user specified RF cell.\n');
            return
        end

        fprintf('Using user specified RF\n');    
        rfs = rfs_user;

    end
    
    fprintf('Detected RFs: %s\n', printRFindex(rfs));
    
    mrf = has_multiple_rfs(rfs);
    
    if mrf
        fprintf('Detected multiple RFs per block.\n');
        superblocks = handle_multi_rf(path, rfs);
    else
        fprintf('Detected at most one RF per block.\n');
        superblocks = handle_single_rf(path, rfs);
    end
    
    % save superblock to file
    save(mat_path, 'superblocks', 'rfs');
    fprintf('Superblock saved to %s\n', mat_path);

end

function [rfindex] = rfblocks2index(rf_blocks)
% Convert RF_BLOCKS cell array to regular array of RF block indices.
% ONLY for tanks with at most 1 RF per block

    nBlocks = length(rf_blocks);
    rfindex = zeros(nBlocks, 1);
    
    for i = 1:nBlocks
        if length(rf_blocks{i}) > 1
            rfindex(i) = i;
        end
    end
    
    rfindex(rfindex == 0) = [];
end

function [ok] = isValidRFcell(rf_block, nBlocks)
% Returns True if RF_BLOCK is valid user-specified RF block indices.
%
% Requirements:
% 1 Must have an entry for each block.
% 2 Block entries must be in order.
% 3 If a block has 1 RF, its entry must be [block, 1]
% 4 If a block has multiple RFs, its entry must be [block, part a, part b, ...].
%   Also, the following parts must be in order and positive integers.
% 5 If a block has no RFs, its entry must be [block]

    ok = false;
    
    if length(rf_block) ~= nBlocks
        return
    end
    
    for i = 1:nBlocks
        elem = rf_block{i};
        
        if isempty(elem) || elem(1) ~= i
            return
        elseif length(elem) == 1
            continue
        end
        
        parts = elem(2:end);
        
        if length(parts) == 1
            if parts(1) ~= 1
                return
            end
        else
            if length(unique(parts)) ~= length(parts) || ...
                ~all(parts > 0) || ...
                ~all(diff(parts) > 0)
                
                return
  
            end
        end
    end
    
    ok = true;

end

function [status] = user_confirm_auto()
% Ask user if automatic RF detection is desired. If yes, status is True.
% Otherwise, status is False.
% Use only when the RFS input to BUILD_RFBLOCK is empty, since if it is
% non-empty, it is assumed that the user is manually providing RF information.

    prompt = {'Perform automatic RF detection?'};
    name = 'RF detection';
        
    answer = inputdlg(prompt, name, 0);
    
    if isempty(answer)
        status = false;
    else
        status = true;
    end
    
end

function [s] = printRFindex(rfs)
% Return formatted string of RF indices.

    s = '';
    
    for i = 1:length(rfs)
        elem = rfs{i};
        
        if length(elem) == 1
            continue
        end
        
        block_num = elem(1);
        parts = elem(2:end);
        
        if length(parts) == 1
            s = sprintf('%s%d, ', s, block_num);
        else
            str = sprintf('%d(', i);

            for j = 1:(length(parts) - 1)
                str = sprintf('%s%d, ', str, parts(j));
            end
            
            str = sprintf('%s%d)', str, parts(end));
            
            s = sprintf('%s%s, ', s, str);
        end
    end
    
    s((end - 1):end) = '';

end

function [superblocks] = handle_multi_rf(path, rfs)
% Special case handling for tanks whose blocks have multiple RFs. RFS is the
% same cell array that either was automatically detected or user-supplied.

    % takes a while
    agg = agglomerate_blocks(path);

    superblocks = partition_rfs(agg, rfs);

end

function [superblocks] = handle_single_rf(path, rfs)
% Handle simple case where each block has at most one RF.

    rfs_array = rfblocks2index(rfs);

    nSuperblocks = length(rfs_array);
    superblocks = cell(nSuperblocks, 1);
    
    nBlocks = block_count(path);
        
    tmp = [rfs_array; (nBlocks + 1)];
    width = diff(tmp);  % account for last rf block
    
    for i = 1:nSuperblocks
        block = [];
        chan = [];
        ts = [];
        sortc = [];
        waves = [];
        part = [];
        
        superblockwidth = width(i);
        ind = rfs_array(i);
        
        for j = ind:(ind + superblockwidth - 1)
            block_str = sprintf('Block-%d', j);
            
            try
                data = TDT2mat(path, block_str, 'Type', [2, 3], ...
                               'Verbose', false);
            catch
                warning('Problem opening block: %d', j);
                continue;
            end
            
            snip = data.snips.CSPK;
            epoc = data.epocs;
            
            idx = remove_eamp_artifact(snip, epoc);

            snip.data = snip.data(idx, :);
            snip.chan = snip.chan(idx);
            snip.sortcode = snip.sortcode(idx);
            snip.ts = snip.ts(idx);

            N = length(snip.chan);
            
            block = [block; j.*ones(N, 1)]; %#ok<*AGROW>
            chan = [chan; snip.chan];
            ts = [ts; snip.ts];
            sortc = [sortc; zeros(N, 1)];
            waves = [waves; snip.data];
            
            all_parts = epoc.FInd.data;
            part_list = unique(all_parts);
            nParts = length(part_list);
            parts = zeros(N, 1);
            
            for k = 1:nParts
                part_num = part_list(k);
                part_idx = find(all_parts == part_num);

                start_ts = epoc.FInd.onset(part_idx(1));
                end_ts = epoc.FInd.offset(part_idx(end));

                parts(snip.ts >= start_ts & snip.ts <= end_ts) = part_num;
            end

            part = [part; parts];

        end % blocks in rf loop
        
        % remove zero parts
        tmp = table(block, chan, ts, sortc, waves, part);
        tmp(tmp.part == 0, :) = [];
        superblocks{i} = tmp;
        
        clear tmp

    end % rf super block loop

end

function [status] = has_multiple_rfs(rfs)
% Return True if RFS has a block with multiple RFs.
% RFS is a 1-D cell of block RF information.
    
    status = false;
    
    for i = 1:length(rfs)
        elem = rfs{i};
        
        if length(elem) > 2
            status = true;
            return
        end
    end

end