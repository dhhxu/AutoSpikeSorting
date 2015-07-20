function [superblocks, rfblocks] = build_rfblock(path, rfindex)
% BUILD_RFBLOCKS Joins receptive field blocks into one superblock for all RFs in
% a tank.
%
% [SUPERBLOCKS, RFBLOCKS] = BUILD_RFBLOCK(PATH, RFINDEX)
%           
% For an input tank, determine receptive field blocks and for each block
% identified, merge it with succeeding non-receptive field blocks until another
% receptive field block is found. Repeat this process for all receptive field
% blocks. The tank is located at absolute path PATH.
%
% SUPERBLOCKS is a one dimensional cell array. Each element contains
% a "superblock" table created from a receptive field block and its ensuing
% non-receptive field blocks. See the OUTPUT section below for more details.
%
% RFBLOCKS is a one dimensional cell array of the receptive field blocks
% automatically determined by the FIND_RFS function.
%
% The user will be asked to confirm the receptive field blocks that were
% detected via a dialog. If the receptive field blocks are incorrect (i.e. user
% selects 'cancel'), this function will terminate. The user can override the
% automatic detection by entering an array RFINDEX of the indices corresponding
% to receptive field blocks.
%
% Limitations: this function assumes that a block will have at most one
% receptive field. Support for multiple receptive fields in one block is not
% implemented yet.
%
% INPUT:
% PATH          String of the absolute path to the tank
% RFINDEX       (optional) array of user-defined receptive field block indices.
%               If not specified, function automatically determines receptive
%               fields.
%
% OUTPUT:
% SUPERBLOCKS   1 dimensional cell. Each element is a superblock table with the
%               following fields:
%                   block   Nx1 vector of block numbers
%                   chan    Nx1 vector of channel numbers
%                   ts      Nx1 vector of waveform timestamps
%                   sortc   Nx1 vector of unit assignments (initially all zeros)
%                   waves   Nx30 vector of snippet waveforms.
%
% See also FIND_RFS, TDT2MAT.

    SetDefaultValue(2, 'rfindex', []);
    
    superblocks = cell();
    rfblocks = [];
    
    if ~exist(path, 'dir')
        error('Tank not found: %s', path);
    end
    
    nBlocks = block_count(path);
    
    if isempty(rfindex)
        rf_blocks = find_rfs(path);
        rfindex = rfblocks2index(rf_blocks);
        
        % user confirm
        if ~user_confirm(rfindex)
            warning('User cancelled function operation');
            return;
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
    
    width = diff([rfindex (nBlocks + 1)]);  % account for last rf block
    
    for i = 1:nSuperblocks
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
                data = TDT2mat(path, block_str, 'Type', 2, 'Verbose', false);
            catch
                warning('Problem opening block: %d', j);
            end

            N = length(data.snips.CSPK.chan);
            
            block = [block; j.*ones(N, 1)]; %#ok<*AGROW>
            chan = [chan; data.snips.CSPK.chan];
            ts = [ts; data.snips.CSPK.ts];
            sortc = [sortc; zeros(N, 1)];
            waves = [waves; data.snips.CSPK.data];

        end % blocks in rf loop
        
        superblocks{i} = table(block, chan, ts, sortc, waves);
        
    end % rf super block loop
    
end

function [rfindex] = rfblocks2index(rf_blocks)
% Convert rf_blocks cell array to regular array of RF block indices. Assumes
% that at most one RF per block.

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
% Returns True if RFINDEX is valid user specified RF block indices.

    ok = false;
    
    over = rfindex > nBlocks;
    if ~sum(over)
        ok = true;
    end

end

function status = user_confirm(rfindex)
% Prompt user to confirm if auto-determined RFINDEX is correct. Returns True if
% user approves, False otherwise.

    prompt = {printRFindex(rfindex)};
    name = 'Confirm RF indices';
        
    answer = inputdlg(prompt, name);
    
    if isempty(answer)
        status = false;
    else
        status = true;
    end
    
end

function s = printRFindex(rfindex)
% Return formatted string of RF indices.

    s = '';
    
    for i = 1:length(rfindex)
        s = sprintf('%s%d, ', s, rfindex(i));
    end
    
end