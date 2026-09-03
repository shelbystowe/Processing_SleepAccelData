%% SleepAccel Dataset Processing

% Shelby Stowe
% August 2026
% Colorado School of Mines 

% Read in the .txt files (downloaded from sleepdata.org)

% Loop over each data file to: 
    % Optional: plot hypnogram 
    % Calculate: 
        % total WAKE
        % total REM
        % total NREM
        % total sleep 
        % Output mean, SD, and range
    % Determine:
        % REM onset latency (how long until REM is entered?)
        % How many long WASOs (>6mins)?


% Quarter of the night analysis
    % Calculate the duration of the sleep episode (should always >7hrs)
    % Divide that duration by 4
    % Calculate the following measurements for each quarter:
        % Proportion of quarter that is REM
        % Proportion of quarter that is NREM
        % Proportion of quarter that is WAKE



%% Set up 

clear all
close all
clc

%% Read in the .txt files (downloaded from sleepdata.org)
% This script reads each file into a cell array 'dataCell'
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



%% Loop over each data file to calculate and determine items of interest
    % total WAKE
    % total REM
    % total NREM
    % total sleep
    % REM onset latency (how long until REM is entered?)
    % How many long WASOs (>6mins)?

% Initialize arrays to store totals for each state for each participant
total_wake = []; % mins
total_REM = []; % mins
total_NREM = []; % mins
total_sleep = []; % mins
REM_onset_latency = []; % mins
Long_WASOs = []; % number
length_of_night = [];

% Loop over each participant 
for i = 1:length(dataCell)

    data = cell2mat(dataCell(i));
    scored_sleep = data(:,2); % This is a column vector of scored data

    % Remove initial wake bout and/or error 
    if scored_sleep(1) == 0 || scored_sleep(1) == -1
        while scored_sleep(1) == 0 || scored_sleep(1) == -1
            scored_sleep(1) = [];
        end 
    end 

    % Remove wake bout and/or error if there is any before recording ends
    if scored_sleep(length(scored_sleep)) == 0 || scored_sleep(length(scored_sleep)) == -1
        while scored_sleep(length(scored_sleep)) == 0 || scored_sleep(length(scored_sleep)) == -1
            scored_sleep(length(scored_sleep)) = [];
        end 
    end 

    % Rename N1-N3 to just be NREM
    % From the data:
    % 0 = WAKE
    % 1 = NREM 1
    % 2 = NREM 2
    % 3 = NREM 3
    % 4 = NREM 4 (?)
    % 5 = REM
    % -1 = Error (?)

    % We will rename as:
    % 0 = WAKE
    % 1 = NREM
    % 2 = REM
    % 3 = Error

    map = containers.Map({-1, 0, 1, 2, 3, 4, 5}, [3, 0, 1, 1, 1, 1, 2]);

    % This is a column vector of 0s, 1s, 2s, and 3s
    labeled_states = arrayfun(@(x) map(x), scored_sleep);

    % OPTIONAL: Plot each hypnogram
%         figure()
%         plot(1:length(labeled_states), labeled_states)
%         set(gca, 'YDir','reverse'); % Reverse so Wake is at top
%         xlabel('Time');
%         ylabel('Sleep Stage');
%         title('Hypnogram', 'Interpreter', 'none');
%         ylim([-0.5, 3.5]);
%         yticks([0, 1, 2, 3]);
%         yticklabels({'WAKE', 'NREM', 'REM', 'Error'});
%         grid on;

    % Initialize arrays to store durations for each state
    nrem_durations = [];
    rem_durations = [];
    wake_durations = [];

    % Calculate total time in each state
    state = labeled_states(1);  % Starting state
    duration = 1;               % Duration counter

    % Loop through hypnogram to find episode durations
    for j = 2:length(labeled_states)
        if labeled_states(j) == state
            % Continue current episode of the same state
            duration = duration + 1;
        else
            % Episode ended, store the duration based on state
            if state == 1  % NREM
                nrem_durations = [nrem_durations, duration];
            elseif state == 2  % REM
                rem_durations = [rem_durations, duration];
            elseif state == 0  % WAKE
                wake_durations = [wake_durations, duration];
            end

            % Reset for new state
            state = labeled_states(j);
            duration = 1;  % Reset duration counter for the new state
        end
    end

    % PSG ended, store the last duration based on state
    if state == 1  % NREM
        nrem_durations = [nrem_durations, duration];
    elseif state == 2  % REM
        rem_durations = [rem_durations, duration];
    elseif state == 0  % WAKE
        wake_durations = [wake_durations, duration];
    end

    %NOTE: convert units from epochs (30s) to minutes, multiply by 30 & divide by 60
    nrem_durations = nrem_durations./2; 
    rem_durations = rem_durations./2;
    wake_durations = wake_durations./2;

    % Compute total wake and sleep duration
    total_wake(i) = sum(wake_durations);
    total_REM(i) = sum(rem_durations);
    total_NREM(i) = sum(nrem_durations);
    total_sleep(i) = sum(nrem_durations) + sum(rem_durations);
    percent_REM(i) = total_REM/total_sleep;

    % Determine REM onset latency
    % Find the first occurrence '2'
    REM_onset_latency_index = find(labeled_states == 2, 1);  % '1' ensures only the first match is returned
    REM_onset_latency(i) = REM_onset_latency_index*30/60; % Convert to minutes

    % Determine how many WASO bouts are long (>6mins)
    Long_WASOs(i) = sum(wake_durations > 6);

    % Quarter of the night analysis
    length_of_night(i) = length(labeled_states);
    dur_of_quarters = floor(length(labeled_states)/4); 

    % First quarter (Q1) 
    Q1_index = 1:dur_of_quarters;

    % Second quarter (Q2) 
    Q2_index = dur_of_quarters+1:dur_of_quarters*2;

    % Third quarter (Q3) 
    Q3_index = dur_of_quarters*2+1:dur_of_quarters*3;

    % Fourth quarter (Q4) 
    Q4_index = dur_of_quarters*3+1:length(labeled_states);

    % Calculate measures for Q1
    Q1_REM = sum(labeled_states(Q1_index) == 2);
    Q1_REM_proportion(i) = Q1_REM/dur_of_quarters;

    Q1_NREM = sum(labeled_states(Q1_index) == 1);
    Q1_NREM_proportion(i) = Q1_NREM/dur_of_quarters;

    Q1_WAKE = sum(labeled_states(Q1_index) == 0);
    Q1_WAKE_proportion(i) = Q1_WAKE/dur_of_quarters;

%     % Check
%     if (Q1_REM_proportion+Q1_NREM_proportion+Q1_WAKE_proportion) ~= 1
%         disp('Something is wrong')
%     else 
%         disp('Q1 adds to 1, yay!')
%     end 

    % Calculate measures for Q2
    Q2_REM = sum(labeled_states(Q2_index) == 2);
    Q2_REM_proportion(i) = Q2_REM/dur_of_quarters;

    Q2_NREM = sum(labeled_states(Q2_index) == 1);
    Q2_NREM_proportion(i) = Q2_NREM/dur_of_quarters;

    Q2_WAKE = sum(labeled_states(Q2_index) == 0);
    Q2_WAKE_proportion(i) = Q2_WAKE/dur_of_quarters;

    % Check
%     if (Q2_REM_proportion+Q2_NREM_proportion+Q2_WAKE_proportion) ~= 1
%         disp('Something is wrong')
%     else 
%         disp('Q2 adds to 1, yay!')
%     end 

    % Calculate measures for Q3
    Q3_REM = sum(labeled_states(Q3_index) == 2);
    Q3_REM_proportion(i) = Q3_REM/dur_of_quarters;

    Q3_NREM = sum(labeled_states(Q3_index) == 1);
    Q3_NREM_proportion(i) = Q3_NREM/dur_of_quarters;

    Q3_WAKE = sum(labeled_states(Q3_index) == 0);
    Q3_WAKE_proportion(i) = Q3_WAKE/dur_of_quarters;

%     % Check
%     if (Q3_REM_proportion+Q3_NREM_proportion+Q3_WAKE_proportion) ~= 1
%         disp('Something is wrong')
%     else 
%         disp('Q3 adds to 1, yay!')
%     end 

    % Calculate measures for Q4
    Q4_REM = sum(labeled_states(Q4_index) == 2);
    Q4_REM_proportion(i) = Q4_REM/dur_of_quarters;

    Q4_NREM = sum(labeled_states(Q4_index) == 1);
    Q4_NREM_proportion(i) = Q4_NREM/dur_of_quarters;

    Q4_WAKE = sum(labeled_states(Q4_index) == 0);
    Q4_WAKE_proportion(i) = Q4_WAKE/dur_of_quarters;

%     % Check
%     if (Q4_REM_proportion+Q4_NREM_proportion+Q4_WAKE_proportion) ~= 1
%         disp('Something is wrong')
%     else 
%         disp('Q4 adds to 1, yay!')
%     end 

end

%% Compute mean and standard deviation for each state across participants
mean_WASO = mean(total_wake);
std_WASO = std(total_wake);
range_WASO = [min(total_wake), max(total_wake)];

mean_time_in_nrem = mean(total_NREM);
std_time_in_nrem = std(total_NREM);
range_time_in_NREM = [min(total_NREM), max(total_NREM)];

mean_time_in_rem = mean(total_REM);
std_time_in_rem = std(total_REM);
range_time_in_REM = [min(total_REM), max(total_REM)];

mean_total_sleep = mean(total_sleep);
std_total_sleep = std(total_sleep);
range_TST = [min(total_sleep), max(total_sleep)];

% Display the results across participants
fprintf('Mean WASO: %.2f ± %.2f minutes\n', mean_WASO, std_WASO); 
fprintf('Range of WASO: %.2f \n', range_WASO);

fprintf('Mean time in NREM: %.2f ± %.2f minutes\n', mean_time_in_nrem, std_time_in_nrem); 
fprintf('Range of time in NREM: %.2f \n', range_time_in_NREM);

fprintf('Mean time in REM: %.2f ± %.2f minutes\n', mean_time_in_rem, std_time_in_rem);
fprintf('Range of time in REM: %.2f \n', range_time_in_REM);

fprintf('Mean TST: %.2f ± %.2f minutes\n', mean_total_sleep, std_total_sleep);
fprintf('Range of TST: %.2f \n', range_TST);


%% Compute the mean and SD of REM onset latency 
REM_onset_mean = mean(REM_onset_latency, 2);  % mean along row
REM_onset_sd   = std(REM_onset_latency, 0, 2); % standard deviation along row
REM_onset_range = [min(REM_onset_latency), max(REM_onset_latency)];

fprintf('Mean REM onset latency: %.2f ± %.2f minutes\n', REM_onset_mean, REM_onset_sd);
fprintf('Range of REM onset latency: %.2f \n', REM_onset_range);


%% Plot results of quarter of night analysis
% REM
Q_REM = [Q1_REM_proportion;
    Q2_REM_proportion;
    Q3_REM_proportion;
    Q4_REM_proportion];

Q_REM_means = mean(Q_REM, 2);  % mean along rows
Q_REM_sds   = std(Q_REM, 0, 2); % standard deviation along rows

figure()
b = bar(Q_REM_means, 'FaceColor', [0.65 0.65 0.65]); % grey bars
hold on;

% Add error bars
numGroups = 4;
x = 1:numGroups; % x positions for bars
errorbar(x, Q_REM_means, Q_REM_sds, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);

% Formatting
xlabel('Quarter of the Night');
ylabel('Proportions');
title('REM Proportion with Mean ± SD');
xticks(x);
grid on;
box on;
set(gca, 'FontSize', 12);

% NREM
Q_NREM = [Q1_NREM_proportion;
    Q2_NREM_proportion;
    Q3_NREM_proportion;
    Q4_NREM_proportion];

Q_NREM_means = mean(Q_NREM, 2);  % mean along rows
Q_NREM_sds   = std(Q_NREM, 0, 2); % standard deviation along rows

figure()
b = bar(Q_NREM_means, 'FaceColor', [0.65 0.65 0.65]); % grey bars
hold on;

% Add error bars
numGroups = 4;
x = 1:numGroups; % x positions for bars
errorbar(x, Q_NREM_means, Q_NREM_sds, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);

% Formatting
xlabel('Quarter of the Night');
ylabel('Proportions');
title('NREM Proportion with Mean ± SD');
xticks(x);
grid on;
box on;
set(gca, 'FontSize', 12);

% WAKE
Q_WAKE = [Q1_WAKE_proportion;
    Q2_WAKE_proportion;
    Q3_WAKE_proportion;
    Q4_WAKE_proportion];

Q_WAKE_means = mean(Q_WAKE, 2);  % mean along rows
Q_WAKE_sds   = std(Q_WAKE, 0, 2); % standard deviation along rows

figure()
b = bar(Q_WAKE_means, 'FaceColor', [0.65 0.65 0.65]); % grey bars
hold on;

% Add error bars
numGroups = 4;
x = 1:numGroups; % x positions for bars
errorbar(x, Q_WAKE_means, Q_WAKE_sds, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);

% Formatting
xlabel('Quarter of the Night');
ylabel('Proportions');
title('WAKE Proportion with Mean ± SD');
xticks(x);
grid on;
box on;
set(gca, 'FontSize', 12);