function W = Process_SleepAccel_Data(dataCell)

% Processes .txt files of EEG data from SleepAccel data set (sleepdata.org)

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

    % Calculate measures for Q4 (need to account for extra time points here, use length(Q4_index))
    Q4_REM = sum(labeled_states(Q4_index) == 2);
    Q4_REM_proportion(i) = Q4_REM/length(Q4_index);

    Q4_NREM = sum(labeled_states(Q4_index) == 1);
    Q4_NREM_proportion(i) = Q4_NREM/length(Q4_index);

    Q4_WAKE = sum(labeled_states(Q4_index) == 0);
    Q4_WAKE_proportion(i) = Q4_WAKE/length(Q4_index);

%     % Check
%     if (Q4_REM_proportion+Q4_NREM_proportion+Q4_WAKE_proportion) ~= 1
%         disp('Something is wrong')
%     else 
%         disp('Q4 adds to 1, yay!')
%     end 

end

% Compute results (mean, sd, and range) of measurements across participants
% Save these results to W

% Compute the mean, SD, range of REM onset latency  
W.REM_onset_mean = mean(REM_onset_latency, 2);  % mean along row
W.REM_onset_sd   = std(REM_onset_latency, 0, 2); % standard deviation along row
W.REM_onset_range = [min(REM_onset_latency), max(REM_onset_latency)];

% Compute the mean, SD, range of long WASO (>6mins)
W.Long_WASO_mean = mean(Long_WASOs, 2);  % mean along row
W.Long_WASO_sd   = std(Long_WASOs, 0, 2); % standard deviation along row
W.Long_WASO_range = [min(Long_WASOs), max(Long_WASOs)];

% Quarter of night analysis
% REM
Q_REM = [Q1_REM_proportion;
    Q2_REM_proportion;
    Q3_REM_proportion;
    Q4_REM_proportion];

W.Q_REM_means = mean(Q_REM, 2);  % mean along rows
W.Q_REM_sds   = std(Q_REM, 0, 2); % standard deviation along rows

% NREM
Q_NREM = [Q1_NREM_proportion;
    Q2_NREM_proportion;
    Q3_NREM_proportion;
    Q4_NREM_proportion];

W.Q_NREM_means = mean(Q_NREM, 2);  % mean along rows
W.Q_NREM_sds   = std(Q_NREM, 0, 2); % standard deviation along rows

% WAKE
Q_WAKE = [Q1_WAKE_proportion;
    Q2_WAKE_proportion;
    Q3_WAKE_proportion;
    Q4_WAKE_proportion];

W.Q_WAKE_means = mean(Q_WAKE, 2);  % mean along rows
W.Q_WAKE_sds   = std(Q_WAKE, 0, 2); % standard deviation along rows

end 