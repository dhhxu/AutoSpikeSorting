function [superblocks, rfblocks] = build_rfblock(path, root, rfs, suppress)
% BUILD_RFBLOCKS Joins receptive field blocks into one superblock for all RFs in
% a tank.
%
% [SUPERBLOCKS, RFBLOCKS] = BUILD_RFBLOCK(PATH, ROOT)
%                           Join blocks containing same receptive fields into
%                           superblocks. RF blocks are detected automatically.
%                           User will be asked to confirm the detected blocks.
%
% [SUPERBLOCKS, RFBLOCKS] = BUILD_RFBLOCK(PATH, ROOT, RFS)
%                           Override automatic RF detection with user-supplied
%                           RF block indices.
%
% [SUPERBLOCKS, RFBLOCKS] = BUILD_RFBLOCK(PATH, ROOT, RFS, SUPPRESS)
%                           Suppress user confirmation dialog. RFINDEX is
%                           ignored.
%           
% For an input tank, determine receptive field blocks and for each block
% identified, merge it with succeeding non-receptive field blocks until another
% receptive field block is found. Repeat this process for all receptive field
% blocks. The tank is located at absolute path PATH. Finally, the result is
% saved to the parent directory of ROOT, which should be the root directory of
% the project. The result is saved to a .mat file:
%   <TANK_NAME>_superblocks.mat
%
% Note that if this function is invoked on the same tank again, it will load the
% saved .mat file. Also, the saved file by construction is assumed to have
% correct RF indices determined.
%
% SUPERBLOCKS is a one dimensional cell array. Each element contains
% a "superblock" table created from a receptive field block and its ensuing
% non-receptive field blocks. See the OUTPUT section below for more details.
%
% RFBLOCKS is a N by 1 cell of the indices of receptive field blocks that are
% automatically determined by the FIND_RFS function.
%
% The user will be asked to confirm the receptive field blocks that were
% automatically detected via a dialog. If the receptive field blocks are
% incorrect (i.e. user selects 'cancel'), this function will terminate.
% The user can override the automatic detection by entering a cell array RFS of
% the indices corresponding to receptive field blocks.
%
% On the other hand, the confirmation dialog can be suppressed by passing True
% to the optional SUPPRESS option. Default is False. RFS will be ignored if
% SUPPRESS is set.
%
% TODO: implement multiple RF/block
%
% INPUT:
% PATH          String of the absolute path to the tank
% ROOT          String of the absolute path of the project root. Generally will
%               be the value of 'pwd'
% RFS           (optional) 1xN cell structure. Each element is an 1xK vector in
%               the following format:
%                   [Block number, part A, ...]
%               If a block is a single RF, use [Block number, 1]
%               If a block has multiple RFs, use [Block number, part A, part
%               B...]. The part numbers must be unique, positive, and increasing
%               order.
%               If a block is not a RF, use [Block number] (scalar)
% SUPPRESS      (optional) boolean. If true, don't prompt for confirmation of 
%               automatic RF detection results. (Default: False)
%
% OUTPUT:
% SUPERBLOCKS   1 dimensional cell. Each element is a superblock table with the
%               following fields:
%                   block   Nx1 vector of block numbers
%                   chan    Nx1 vector of channel numbers
%                   ts      Nx1 vector of waveform timestamps
%                   sortc   Nx1 vector of unit assignments (initially all zeros)
%                   waves   Nx30 vector of snippet waveforms.
% RFBLOCKS      1xN cell that is the output of either FIND_RFS or the same
%               as the user override, if valid.
%
% See also FIND_RFS, TDT2MAT.

    if ~exist(root, 'dir')
        error('Invalid project root directory');
    elseif ~exist(path, 'dir')
        error('Tank not found: %s', path);
    end
    
    parent = fileparts(root);

    SetDefaultValue(3, 'rfs', cell(0));
    SetDefaultValue(4, 'suppress', false);
    
    [superblocks, rfblocks] = get_superblock(path, parent, rfs, suppress);
    
end

function [superblocks, rfblocks] = get_superblock(path, loc, rfs, suppress)
% Helper function. If saved superblock .mat file for the tank does not exist,
% creates one normally. Otherwise, it exists at directory whose path is LOC.

    [~, tank_name, ~] = fileparts(path);
    mat_name = sprintf('%s_superblocks.mat', tank_name);
    mat_path = fullfile(loc, mat_name);
    
    % this function was previously called on tank
    if exist(mat_path, 'file')
        fprintf('superblock file found for tank %s\n', tank_name);
        fprintf('Loading it...\n');
        
        tmp = load(mat_path);
        superblocks = tmp.superblocks;
        rfblocks = tmp.rfblocks;
        clear tmp;
        
        return;

    end
    
    fprintf('superblock file not found for tank %s\n', tank_name);
    fprintf('Creating one...\n');
    
    superblocks = cell(0);
    rfblocks = cell(0);
    
    nBlocks = block_count(path);
    
    if isempty(rfs)
        fprintf('Automatically detecting receptive fields...\n');

        rf_blocks = find_rfs(path);
        
        if ~suppress
            % user confirm
            fprintf('Waiting for user confirmation\n');

            if ~user_confirm(rf_blocks)
                warning('User cancelled function operation');
                return;
            end
        end
        
        rfs_array = rfblocks2index(rf_blocks);
        rfblocks = rf_blocks;

    else
        if ~isValidRFcell(rfs, nBlocks)
            error('Invalid user specified RF cell');
        end
        fprintf('Using user specified RF\n');
        
        rfs_array = rfblocks2index(rfs);
        rfblocks = rfs;
    end
    
    nSuperblocks = length(rfs_array);
    superblocks = cell(nSuperblocks, 1);
        
    tmp = [rfs_array; (nBlocks + 1)];
    width = diff(tmp);  % account for last rf block
    
    for i = 1:nSuperblocks
        block = [];
        chan = [];
        ts = [];
        sortc = [];
        waves = [];
        
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

            N = length(snip.chan);
            
            block = [block; j.*ones(N, 1)]; %#ok<*AGROW>
            chan = [chan; snip.chan];
            ts = [ts; snip.ts];
            sortc = [sortc; zeros(N, 1)];
            waves = [waves; snip.data];

        end % blocks in rf loop
        
        superblocks{i} = table(block, chan, ts, sortc, waves);
        
    end % rf super block loop
    
    % save superblock to file
    save(mat_path, 'superblocks', 'rfblocks');
    
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

    ok = true;
    
    if length(rf_block) > nBlocks
        ok = false;
    end
    
    for i = 1:length(rf_block)
        elem = rf_block{i};
        
        if isempty(elem) || elem(1) ~= i
            ok = false;
        elseif length(elem) == 1
            continue
        end
        
        parts = elem(2:end);
        
        if length(parts) == 1
            if parts(1) ~= 1
                ok = false;
            end
        else
            if length(unique(parts)) ~= length(parts)
                ok = false;
            elseif ~all(parts > 0)
                ok = false;
            elseif ~all(diff(parts) > 0)
                ok = false;
            end
        end
    end

end

function [status] = user_confirm(rfs)
% Prompt user to confirm if auto-determined RFS is correct. Returns True if
% user approves, False otherwise.

    prompt = {printRFindex(rfs)};
    name = 'Confirm RF indices';
        
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
                str = sprintf('%s%d, ', str, j);
            end
            
            str = sprintf('%s%d)', str, parts(end));
            
            s = sprintf('%s%s, ', s, str);
        end
    end
    
    s((end - 1):end) = '';

end