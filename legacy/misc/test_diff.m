% Checks time difference between TDT timestamps and plx aligned timestamps
%
% Assumes plx and snippet data loaded in a and snip variables, respectively.
%
% output variables:
%   ts_orig
%   ts_plx
%   d_ts
%   d_fit
%
% plots:
% plot(d_ts)
% hist(d_ts - d_fit)

close all;
clear d_ts d_fit ts_orig ts_plx

BLK = 9;
CH = 4;
PLX_PATH = 'U:\Calvin\Analysis\PLX Sort files\CW39\CW39_Block-9_CSPK__1.plx';
MOD_PLX = 'U:\Calvin\Analysis\PLX Sort files\CW39\CW39_Block-9_CSPK__1-01.plx';
% TRY_PLX = 'U:\DanielX\CW39_Block-9_CSPK__2.plx';


% [nSpk, plx_orig_ts] = plx_ts(PLX_PATH, CH, 0);
% [~, plx_mod_ts] = plx_ts(MOD_PLX, CH, 0);
% [~, try_ts] = plx_ts(TRY_PLX, CH, 0);

[a, ~, ~] = convert_sorted_plx(PLX_PATH);

[snip, epoc] = sorter_load_snip_block(tank_info.path, BLK, DATA_PATH);

%%
ts_orig = snip.ts(snip.chan == CH);

fprintf('Analyzing channel %d\n', CH);

% get original ts

fprintf('%d timestamps found\n', length(ts_orig));

% get plx ts

all_ts = a(:, CH);

ts_plx = [];

for i = 1:length(all_ts)
    if isempty(all_ts{i})
        break
    end
    
    ts_plx = [ts_plx; all_ts{i}];
end

ts_plx = sort(ts_plx);

d_ts = abs(ts_plx - ts_orig);

fprintf('Maximum difference: %f ms\n', max(d_ts * 1000));
fprintf('Minimum difference: %f us\n', min(d_ts * 1000000));

% line fitting

p = polyfit(1:length(d_ts), d_ts.', 1);

d_fit = polyval(p, 1:length(d_ts));
d_fit = d_fit.';

% plots
%%

figure('Name', 'difference');
plot(d_ts, 'LineWidth', 5)
% figure('Name', 'residuals');
% hist(d_ts - d_fit);

%%
clear p all_ts i
