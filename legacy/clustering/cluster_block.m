function [results] = cluster_block(info, procedure, kList)
% CLUSTER_BLOCK Cluster all channels in a block using the same clustering
% procedure.
%
% RESULTS = CLUSTER_BLOCK(INFO, PROCEDURE, kList)
%
% Given a block described by the struct INFO, apply the clustering
% procedure PROCEDURE on all of its channels.
%
% PROCEDURE is a function handle and has the following signature:
% 
%   CLASS = PROCEDURE(DATA, K)
% 
%   Where DATA is a matrix of spike waveforms with a spike per row and K is
%   the number of clusters. K is determined by the user beforehand, most
%   likely through some preview method.
%
% KLIST is either a scalar or a vector denoting the number of clusters. If
% a scalar, then it is applied to all channels. Otherwise, the number of
% clusters must be specified for all channels in the vector.
%
% INPUT:
% INFO          struct containing cluster information.
% PROCEDURE     function handle for the clustering procedure
% kList         scalar or vector. Number of clusters to partition each
%               channel into.
%
% OUTPUT:
% RESULTS       1xN cell array where N is the number of channels in the
%               block. Each element is an integer vector of class labels
%               for the corresponding channel.

    fprintf('\ncluster_block: begin clustering tank %s, block %d\n', ...
        info.tank, info.blocknum);
    
    start = tic;
    
    if ~ishandle(procedure)
        error('Procedure is not a handle.');
    end

    if ~isvector(kList) || isempty(kList)
        error('Invalid kList input');
    end
    
    nChannels = get_nChannels(info);
    if length(kList) > 1
        if length(kList) ~= nChannels
            error('Mismatch between kList and number of channels');
        end
    end

    nChannels = 64;
    
    results = cell(1, nChannels);
    
    for i = 1:nChannels
        chan_start = tic;
        
        if length(kList) > 1
            class = cluster_channel(chan, info, procedure, kList(i));
        else
            class = cluster_channel(chan, info, procedure, kList);
        end
        
        results{i} = class;
        chan_end = toc(chan_start);
        if isempty(class)
            warning('Invalid alignment options entered for channel: %d', i);
        else
            nSpikes = sum(info.snip.chan == i);
            fprintf('Channel %d: %d spikes, elapsed time: %d s\n', i, ...
                    nSpikes, chan_end);
        end
    end
    
    finish = toc(start);
    
    fprintf('cluster_block: finish clustering\n');
    fprintf('cluster_block: time elapsed: %d s\n', finish);

end

function [class] = cluster_channel(chan, info, procedure, k)
% Cluster data on channel CHAN with procedure handle PROCEDURE with K
% clusters. INFO contains the spike data.
%
% User supervises the data alignment. If an error occurs, CLASS is empty
% vector.

    data = get_snip_spikes(info, chan);
    
    % supervised alignment
    

    [opt, shift] = prompt_snip_align(data);
    if isempty(opt) || ~shift
        class = [];
        return;
    end
    
    aligned = align_snip(data, opt, shift);
    
    % procedure responsible for feature extraction
    
    class = procedure(aligned, k);
    
end

function nChannels = get_nChannels(info)

    chan = info.snip.chan;
    channels = unique(chan);
    nChannels = length(channels);
    
end