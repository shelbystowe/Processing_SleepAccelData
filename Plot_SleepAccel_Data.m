%% Plotting the Sleep Accel Data 

% Shelby Stowe
% August 2026
% Colorado School of Mines

% Plot values calculated from 24 particpants with >7hr PSG recordings

%% Total Sleep Time (TST, minutes)
TST_mean = 435.77;
TST_SD = 27.13;
TST_max = 474;
TST_min = 370;

% Calculate error bar lengths
TST_lowerErr = TST_mean - TST_min;      % Distance from mean to min
TST_upperErr = TST_max - TST_mean;      % Distance from mean to max

%% Wake After Sleep Onset (WASO, minutes)
WASO_mean = 41.06; 
WASO_SD = 23.83; 
WASO_max = 102.5;
WASO_min = 5;

% Calculate error bar lengths
WASO_lowerErr = WASO_mean - WASO_min;      % Distance from mean to min
WASO_upperErr = WASO_max - WASO_mean;      % Distance from mean to max

%% Time in REM (minutes)
REM_mean = 109.04; 
REM_SD = 28.40; 
REM_max = 154.5; 
REM_min = 44;

% Calculate error bar lengths
REM_lowerErr = REM_mean - REM_min;      % Distance from mean to min
REM_upperErr = REM_max - REM_mean;      % Distance from mean to max

%% Time in NREM (minutes)
NREM_mean = 326.73;
NREM_SD = 37.11; 
NREM_max = 393;
NREM_min = 229;

% Calculate error bar lengths
NREM_lowerErr = NREM_mean - NREM_min;      % Distance from mean to min
NREM_upperErr = NREM_max - NREM_mean;      % Distance from mean to max


%% Create figure
figure(1);

% Total Sleep Time
subplot(1, 4, 1); % 1 rows, 4 column, plot 1
% Data
% Add error bars for range
errorbar(1, TST_mean, TST_lowerErr, TST_upperErr, ...
    'b', 'LineStyle', 'none', 'LineWidth', 1.5,'CapSize', 10);
hold on
% Add error bars for standard deviation
errorbar(TST_mean, TST_SD, ...
    'k', ...                % Black error bars
    'LineStyle', 'none', ...% No connecting line
    'LineWidth', 1.5, ...
    'CapSize', 10);         % Size of error bar caps
hold on;
% mean
plot(1, TST_mean,'.','Markersize',25);
hold on;
% Model output - Total Sleep
% Add error bars for range
errorbar(2, 417.52, 417.52-357, 471-417.52, ...
    'm', 'LineStyle', 'none', 'LineWidth', 1.5,'CapSize', 10);
hold on
% Add error bars for standard deviation
errorbar(2, 417.52, 36.95, ...
    'k', ...                % Black error bars
    'LineStyle', 'none', ...% No connecting line
    'LineWidth', 1.5, ...
    'CapSize', 10);         % Size of error bar caps
hold on;
% mean
plot(2, 417.52,'.','Markersize',25);
ylabel('minutes')
xlim([0, 3]);
xticks([0, 1, 2, 3]);
xticklabels({'', 'Data','Model',''});
title('Total Sleep Time')
ax=gca;
ax.FontSize = 15;


% Wake After Sleep Onset
subplot(1, 4, 2); % 1 rows, 4 column, plot 2
% Data
% Add error bars for range
errorbar(1, WASO_mean, WASO_lowerErr, WASO_upperErr, ...
    'b', 'LineStyle', 'none', 'LineWidth', 1.5,'CapSize', 10);
hold on
% Add error bars for standard deviation
errorbar(WASO_mean, WASO_SD, ...
    'k', ...                % Black error bars
    'LineStyle', 'none', ...% No connecting line
    'LineWidth', 1.5, ...
    'CapSize', 10);         % Size of error bar caps
hold on;
% mean
plot(1, WASO_mean,'.','Markersize',25);
hold on;
% Model output - Total WASO
% Add error bars for range
errorbar(2, 22.06, 22.06-3, 82-22.06, ...
    'm', 'LineStyle', 'none', 'LineWidth', 1.5,'CapSize', 10);
hold on
% Add error bars for standard deviation
errorbar(2, 22.06, 19.07, ...
    'k', ...                % Black error bars
    'LineStyle', 'none', ...% No connecting line
    'LineWidth', 1.5, ...
    'CapSize', 10);         % Size of error bar caps
hold on;
% mean
plot(2, 22.06,'.','Markersize',25);
xlim([0, 3]);
xticks([0, 1, 2, 3]);
xticklabels({'', 'Data','Model',''});
title('WASO')
ax=gca;
ax.FontSize = 15;


% Time in REM
subplot(1, 4, 3); % 1 rows, 4 column, plot 3
% Data
% Add error bars for range
errorbar(1, REM_mean, REM_lowerErr, REM_upperErr, ...
    'b', 'LineStyle', 'none', 'LineWidth', 1.5,'CapSize', 10);
hold on
% Add error bars for standard deviation
errorbar(REM_mean, REM_SD, ...
    'k', ...                % Black error bars
    'LineStyle', 'none', ...% No connecting line
    'LineWidth', 1.5, ...
    'CapSize', 10);         % Size of error bar caps
hold on;
% mean
plot(1, REM_mean,'.','Markersize',25);
hold on;
% Model output - Total REM
% Add error bars for range
errorbar(2, 104.22, 104.22-44.5, 146-104.22, ...
    'm', 'LineStyle', 'none', 'LineWidth', 1.5,'CapSize', 10);
hold on
% Add error bars for standard deviation
errorbar(2, 104.22, 23.33, ...
    'k', ...                % Black error bars
    'LineStyle', 'none', ...% No connecting line
    'LineWidth', 1.5, ...
    'CapSize', 10);         % Size of error bar caps
hold on;
% mean
plot(2, 104.22,'.','Markersize',25);
xlim([0, 3]);
xticks([0, 1, 2, 3]);
xticklabels({'', 'Data','Model',''});
title('Time in REM')
ax=gca;
ax.FontSize = 15;


% Time in NREM
subplot(1, 4, 4); % 1 rows, 4 column, plot 4
% Data
% Add error bars for range
errorbar(1, NREM_mean, NREM_lowerErr, NREM_upperErr, ...
    'b', 'LineStyle', 'none', 'LineWidth', 1.5,'CapSize', 10);
hold on
% Add error bars for standard deviation
errorbar(NREM_mean, NREM_SD, ...
    'k', ...                % Black error bars
    'LineStyle', 'none', ...% No connecting line
    'LineWidth', 1.5, ...
    'CapSize', 10);         % Size of error bar caps
hold on;
% mean
plot(1, NREM_mean,'.','Markersize',25);
hold on;
% Model output - Total NREM 
% Add error bars for range
errorbar(2, 313.3, 313.3-266, 348-313.3, ...
    'm', 'LineStyle', 'none', 'LineWidth', 1.5,'CapSize', 10);
hold on
% Add error bars for standard deviation
errorbar(2, 313.3, 21.56, ...
    'k', ...                % Black error bars
    'LineStyle', 'none', ...% No connecting line
    'LineWidth', 1.5, ...
    'CapSize', 10);         % Size of error bar caps
hold on;
% mean
plot(2, 313.3,'.','Markersize',25);
xlim([0, 3]);
xticks([0, 1, 2, 3]);
xticklabels({'', 'Data','Model'});
title('Time in NREM')
ax=gca;
ax.FontSize = 15;

legend('Range', 'SD', 'Mean', 'Range','Location','best')

