function [superblocks, rfblocks] = build_rfblock(path, root, rfindex, suppress)
% BUILD_RFBLOCKS Joins receptive field blocks into one superblock for all RFs in
% a tank.
%
% [SUPERBLOCKS, RFBLOCKS] = BUILD_RFBLOCK(PATH, ROOT)
%                           Join blocks containing same receptive fields into
%                           superblocks. RF blocks are detected automatically.
%                           User will be asked to confirm the detected blocks.
%
% [SUPERBLOCKS, RFBLOCKS] = BUILD_RFBLOCK(PATH, ROOT, RFINDEX)
%                           Override automatic RF detection with user-supplied
%                           RF block indices.
%
% [SUPERBLOCKS, RFBLOCKS] = BUILD_RFBLOCK(PATH, ROOT, RFINDEX, SUPPRESS)
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
% RFBLOCKS is a N by 1 array of the indices of receptive field blocks that are
% automatically determined by the FIND_RFS function.
%
% The user will be asked to confirm the receptive field blocks that were
% automatically detected via a dialog. If the receptive field blocks are
% incorrect (i.e. user selects 'cancel'), this function will terminate.
% The user can override the automatic detection by entering an array RFINDEX of
% the indices corresponding to receptive field blocks.
%
% On the other hand, the confirmation dialog can be suppressed by passing True
% to the optional SUPPRESS option. Default is False. RFINDEX will be ignored if
% SUPPRESS is set.
%
% Limitations: this function assumes that a block will have at most one
% receptive field. Functionality for multiple receptive fields in one block is
% not implemented yet.
%
% INPUT:
% PATH          String of the absolute path to the tank
% ROOT          String of the absolute path of the project root. Generally will
%               be the value of 'pwd'
% RFINDEX       (optional) array of user-defined receptive field block indices.
%               If not specified, function automatically determines receptive
%               fields.
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
% RFBLOCKS      Mx1 integer array. Each element is the number of a block
%               containing a RF.
%
% See also FIND_RFS, TDT2MAT.

    if ~exist(root, 'dir')
        error('Invalid project root directory');
    elseif ~exist(path, 'dir')
        error('Tank not found: %s', path);
    end
    
    parent = fileparts(root);

    SetDefaultValue(3, 'rfindex', []);
    SetDefaultValue(4, 'suppress', false);
    
    [superblocks, rfblocks] = get_superblock(path, parent, rfindex, suppress);
    
end

function [superblocks, rfblocks] = get_superblock(path, loc, rfindex, ...
                                                  suppress)
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
    rfblocks = [];
    
    nBlocks = block_count(path);
    
    if isempty(rfindex)
        rf_blocks = find_rfs(path);
        rfindex = rfblocks2index(rf_blocks);
        
        if ~suppress
            % user confirm
            if ~user_confirm(rfindex)
                warning('User cancelled function operation');
                return;
            end
        end

    else
        rfindex = unique(sort(rfindex));
        if ~isValidRFindex(rfindex, nBlocks)
            error('Invalid user specified RF block indices');
        end
    end
    
    nSuperblocks = length(rfindex);
    superblocks = cell(nSuperblocks, 1);
    rfblocks = rfindex;
    
    tmp = zeros(length(rfindex) + 1, 1);
    tmp(1:(length(tmp) - 1)) = rfindex;
    tmp(end) = nBlocks + 1;
    width = diff(tmp);  % account for last rf block
    
    parfor i = 1:nSuperblocks
        block = [];
        chan = [];
        ts = [];
        sortc = [];
        waves = [];
        
        superblockwidth = width(i);
        ind = rfindex(i);
        
        for j = ind:(ind + superblockwidth - 1)
            block_str = sprintf('Block-%d', j);
            
            try
                data = TDT2mat(path, block_str, 'Type', 3, 'Verbose', false);
            catch
                warning('Problem opening block: %d', j);
                continue;
            end

            N = length(data.snips.CSPK.chan);
            
            block = [block; j.*ones(N, 1)]; %#ok<*AGROW>
            chan = [chan; data.snips.CSPK.chan];
            ts = [ts; data.snips.CSPK.ts];
            sortc = [sortc; zeros(N, 1)];
            waves = [waves; data.snips.CSPK.data];

        end % blocks in rf loop
        
        superblocks{i} = table(block, chan, ts, sortc, waves);
        
%         clear block chan ts sortc waves;
        
    end % rf super block loop
    
    % save superblock to file
    save(mat_path, 'superblocks', 'rfblocks');
    
end

function [rfindex] = rfblocks2index(rf_blocks)
% Convert RF_BLOCKS cell array to regular array of RF block indices. Assumes
% that there is at most one RF per block.

    nBlocks = length(rf_blocks);
    rfindex = zeros(nBlocks, 1);
    
    for i = 1:nBlocks
        if ~isempty(rf_blocks{i})
            rfindex(i) = i;
        end
    end
    
    rfindex(rfindex == 0) = [];
end

function [ok] = isValidRFindex(rfindex, nBlocks)
% Returns True if RFINDEX is valid user-specified RF block indices.

    ok = true;
    
    over = rfindex > nBlocks;

    if sum(over)
        ok = false;
    end

end

function [status] = user_confirm(rfindex)
% Prompt user to confirm if auto-determined RFINDEX is correct. Returns True if
% user approves, False otherwise.

    prompt = {printRFindex(rfindex)};
    name = 'Confirm RF indices';
        
    answer = inputdlg(prompt, name, 0);
    
    if isempty(answer)
        status = false;
    else
        status = true;
    end
    
end

function [s] = printRFindex(rfindex)
% Return formatted string of RF indices.

    s = '';
    
    for i = 1:length(rfindex)
        s = sprintf('%s%d, ', s, rfindex(i));
    end
    
end