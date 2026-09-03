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
        
        fprintf('Loaded file: %s\n', fileList(k).name);
    catch ME
        warning('Could not read file "%s": %s', fileList(k).name, ME.message);
        dataCell{k} = [];
    end
end


W_data = Process_SleepAccel_Data_function(dataCell); 



%% Call .m function to process the Takeda data
% 


%% Plot bar graphs of measurements from both data sets 


