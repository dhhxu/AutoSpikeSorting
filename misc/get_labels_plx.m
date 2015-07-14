function [plxlabel] = get_labels_plx(varargin)
% GET_LABELS_PLX retrieve human labels for spike waveform data from a plx file.
%
% PLXLABEL = GET_LABELS_PLX()
%             Interactive, file-open dialog for the user to select the .plx
%             file.
%
% PLXLABEL = GET_LABELS_PLX(PATH)
%             User specifies the absolute path string to the .plx file.
%
% This function reads a plx file whose path is specified by the user, either via
% a input dialog or a string in the command line, and extracts labels created
% from manual human sorting of spike waveforms. The labels are returned in the
% vector PLXLABEL and are arranged in increasing time order. This vector has the
% same number of dimensions as the rows in the spike matrix.
%
% In case of error, PLXLABEL will be the empty vector.
%
% INPUT:
% PATH      string of the absolute path to the plx file
%
% OUTPUT:
% PLXLABEL  Cell with number of columns equal to number of channels in the
%           block. Each element is a vector of manual labels arranged in
%           increasing time order.
%
% Note: requires the Plexon Offline MATLAB SDK and TDT2mat.
%
% See also TDT2mat

    plxlabel = cell();

    [manual_sorted, tank, blocknum] = convert_sorted_plx(varargin{1:end});
    
    if isempty(tank) || ~blocknum
        return;
    end
    
    fprintf('Please find Tank %s, Block %d when prompted.', tank, blocknum);
    pause(2);
    
    [strm, snip, name, num] = prompt_data();
    
    % check if the user selected right tank/block combo
    if ~strcmp(tank, name) || ~strcmp(blocknum, num)
        error('Selected tank/block does not match.\nExpected: Tank %s, Block %d\nActual: Tank %s, Block %d',...
              tank, blocknum, name, num);
    end
    
    allts = snip.ts;
    
    nChannels = size(manual_sorted, 2);
    plxlabel = cell(1, nChannels);
    
    for chan = 1:nChannels
        slice = manual_sorted(:, chan);     % m x 1 cell
        
        chan_ts = allts(snip.chan == chan); % n x 1 vector
        
        labels = zeros(length(chan_ts), 1);
        
        clusternum = 0;   % start with unsorted cluster
        
        for s = 1:length(slice)
            if isempty(slice{s})
                break;
            end

            slice_ts = slice{s};

            for t = 1:length(slice_ts)
                ts = slice_ts(t);

                idx = find(chan_ts == ts);
                labels(idx) = clusternum;
                
            end     % individual cluster loop
            
            clusternum = clusternum + 1;
            
        end     % slice loop
        
        plxlabel{chan} = labels;
        
    end     % channel loop

end