%% Main file to process Walch et al. (2019) data and data from Takeda 

% Shelby Stowe
% September 2026
% Colorado School of Mines

% Code outline: 
    % Calls .m function to process the Walch data, stores relevant measurements 
    % Calls .m function to process the Takeda data, stores relevant measurements
    % Plots bar graphs of measurements from both data sets 

%% Set up 

clear all
close all
clc 

%% Call .m function to process Walch et al. data 
% .txt files as downloaded from sleepdata.org are saved in Walch_data_files
% n = 32, but 7 were removed due to having <7hrs of recording time 
% n = 25 are processed here 

% Read in the .txt files (downloaded from sleepdata.org)
    % Each file is brought into a cell array, 'dataCell'
    % Each cell contains the contents of one file

% === CONFIGURATION ===
folderPath = 'Walch_data_files';

% Get list of all .txt files in the folder
fileList = dir(fullfile(folderPath, '*.txt'));

% Check if any files found
if isempty(fileList)
    error('No .txt files found in the selected folder.');
end

% Preallocate cell array to store data
dataCell = cell(numel(fileList), 1);

% Loop through each file and load it
for k = 1:numel(fileList)
    filePath = fullfile(folderPath, fileList(k).name);
    try
        % Try reading as numeric data first
        numericData = readmatrix(filePath);
        
        % If file contains only text or mixed data, use readtable
        if all(isnan(numericData), 'all')
            dataCell{k} = readtable(filePath, 'FileType', 'text');
        else
            dataCell{k} = numericData;
        end
        
        %fprintf('Loaded file: %s\n', fileList(k).name);
    catch ME
        warning('Could not read file "%s": %s', fileList(k).name, ME.message);
        dataCell{k} = [];
    end
end

% Call the function Process_SleepAccel_Data and pass it the dataCell of .txt files 
W = Process_SleepAccel_Data(dataCell); 



%% Call .m function to process the Takeda data
% 


%% Print to command window 

% REM Onset Latency 
fprintf('SleepAccel Data Mean REM onset latency: %.2f ± %.2f minutes\n', W.REM_onset_mean, W.REM_onset_sd);
fprintf('SleepAccel Data Range of REM onset latency: %.2f minutes\n', W.REM_onset_range);

% Long WASOs
fprintf('SleepAccel Data Mean Number of Long WASOs: %.2f ± %.2f minutes\n', W.Long_WASO_mean, W.Long_WASO_sd);
fprintf('SleepAccel Data Range of Long WASOs: %.2f minutes\n', W.Long_WASO_range);

%% Plot bar graphs of measurements from both data sets 

figure()
% REM
subplot(1,3,1)
% Create bars
b = bar(W.Q_REM_means, 'FaceColor', [0.65 0.65 0.65]); % grey bars
hold on;
% Add error bars
numGroups = 4;
x = 1:numGroups; % x positions for bars
errorbar(x, W.Q_REM_means, W.Q_REM_sds, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);
title('REM')

% NREM
subplot(1,3,2)
% Create bars 
b = bar(W.Q_NREM_means, 'FaceColor', [0.65 0.65 0.65]); % grey bars
hold on;
% Add error bars
numGroups = 4;
x = 1:numGroups; % x positions for bars
errorbar(x, W.Q_NREM_means, W.Q_NREM_sds, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);
title('NREM')

% WAKE
subplot(1,3,3)
% Create bars
b = bar(W.Q_WAKE_means, 'FaceColor', [0.65 0.65 0.65]); % grey bars
hold on;
% Add error bars
numGroups = 4;
x = 1:numGroups; % x positions for bars
errorbar(x, W.Q_WAKE_means, W.Q_WAKE_sds, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);
title('WAKE')

