function [results] = compare_procedure(procedures, info, channel, iter)
% COMPARE_PROCEDURE run different clustering procedures and obtain clustering
% results and/or quality statistics for spikes in a given channel.
%
% RESULTS = COMPARE_PROCEDURE(PROCEDURES, INFO)
%           Prompt user for channel to use.
%
% RESULTS = COMPARE_PROCEDURE(PROCEDURES, INFO, CHANNEL)
%           Uses the channel CHANNEL. If it is larger than max number of
%           channels, raises error.
%
% RESULTS = COMPARE_PROCEDURE(PROCEDURES, INFO, CHANNEL, ITER)
%           Maximum number of times to run each procedure for consistent
%           results (Default: 21).
%
% This function provides a platform to run clustering procedures and
% obtain their results. Also obtains cluster quality statistics if applicable.
% The procedures are run on data from a channel CHANNEL (provided as an argument
% or interactively) and are stored as function handles in the 1D cell array
% PROCEDURES.
%
% COMPARE_PROCEDURE will run each procedure in PROCEDURES for ITER iterations
% and return the median result. For best results, each procedure should not be
% deterministic (e.g. ramdom initialization).
%
% This function will prompt the user to enter the number of clusters.
% 
% All procedures will have the following signature:
%
%   CLASS = ANY_PROCEDURE(DATA, INFO)
%
%   where CLASS is the classification vector for the spike data contained in
%   INFO. DATA is the matrix of aligned raw data spikes (no feature extraction).
%
% The results of the cluster quality evaluation for a procedure will be stored
% in a struct. All results will be returned in a 1D cell array RESULTS.
%
% Usage:
% The function performs the following tasks:
%   - Get channel from user if not specified
%   - Get alignment options from user
%
% Limitations:
%   No way to set ITER but not CHANNEL.
%
% INPUT:
% PROCEDURES    1-D cell array of procedure function handles
% INFO          Struct containing spike data and metadata
% CHANNEL       integer of channel to sort on. If not specified, prompt user.
% ITER          integer of max. number of times to run each procedure (Default:
%               21).
%
% OUTPUT:
% RESULTS       1-D cell array of the statistics results. 
%
% See also INITIALIZE

    if ~valid_info(info)
        error('Info struct missing fields.');
    end
    
    SetDefaultValue(3, 'channel', 0);
    SetDefaultValue(4, 'iter', 21);

    if isempty(procedures)
        error('Empty procedure cell array');
    end
    
    if ~channel % no channel argument
        channel = get_channel(info.strm);
        
        if ~channel % case of cancel
            error('No channel selected');
        end
    else
        max = size(info.strm.data, 1);
        if channel > max
            error('Channel number too large (max channel is %d): %d', ...
                  max, channel);
        elseif channel < 1
            error('Channel number too low');
        end
    end
    
    if iter < 1
        error('Invalid iteration value');
    end
    
%% Prepare
    % aligned spikes
    spikes = prepare_spikes(info, channel);
    
    if isempty(spikes)
        error('Align: A problem occured with user input');
    end


%% Clustering
    % Start parallel pool?
    
    nProcedures = length(procedures);
    for i = 1:nProcedures
        h = procedures{i};  % function handle
        
        if ~exist(func2str(h), 'file')
            warning('Procedure not found: %s', func2str(h));
            continue
        end
        
        for j = 1:iter
            class = h(spikes, info);
        end
        
    end
    
    % shutdown parallel pool?

end


function channel = get_channel(strm)
% If 'cancel' is selected, returns 0.

    nChannels = size(strm.data, 1);
    channel = prompt_channel(nChannels);

end

function ok = valid_info(info)
% Returns true if INFO is valid struct
    ok = true;
    try
        strm = info.strm;
        snip = info.snip;
        tank = info.tank;
        blocknum = info.blocknum;
    catch
        ok = false;
    end
end

