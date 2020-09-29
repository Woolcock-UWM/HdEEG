%% HD4a_getNREM_cycle_ind.m 

%%% FIRST you need to set path for RunLength_2017_04_08
% http://www.n-simon.de/mex/#RunLength.mexw64

% DESCRIPTION: Plots a hypnogram for an individual subject under one
% condition, and uses a set of rules to identify NREM sleep cycles
% (indicated by coloured lines on the hypnogram). For PSG data only.

% INPUTS: 
% - .mat file ouput from HD2_mat2EEGlab_topo_ind_PSG.mat (one subject's PSG
% data, for one condition)
% - can input parameters for wake/NREM/REM stage threshholds

% OUTPUTS: 
% - .mat file containing the NREM sleep cycle data
% - a hypnogram for the subject under one condition, with coloured lines to
% indicate the identified sleep cycle

clear
close all
clc

tic


fprintf('Select the PSG .mat file from the "HD2 Output Files" folder.\n (e.g. 04KS-ConditionPSG MCI-all_channels.mat) \n');
[mat_file, mat_folder] = uigetfile('*.mat'); 
S = load(fullfile(mat_folder,mat_file));
clc

toc

% Ask user where to save the sleep cycle data and what to name it
fprintf("Select the folder in which you want to create the 'SleepCycle Output files' folder, \n e.g. a folder named with the subject ID \n");
folder = uigetdir;
save_folder = fullfile(folder);
clc

cd (save_folder)
if exist ('SleepCycle Output files', 'dir')  ~= 7
    mkdir('SleepCycle Output files');
    
end
save_folder = [save_folder, filesep, 'SleepCycle Output files'];

prompt = {'Name for sleep cycle data file:'};
dlg_title = 'Enter a filename';
num_lines = 1;
defaultans = {sprintf('%s_SleepCycle_data', S.EEG.subject)};
name = inputdlg(prompt,dlg_title,num_lines,defaultans);
save_name = char(name(1));

%% define the cycle of sleep stage
%%% Rule of sleep cycle

% count wake stage < 1 min as NREM 
% stage 1, 2,3 continuous 15 min (sum = 30 epochs) label = 1 ,2, 3
% first REM >=1 epoch label=5
% second REM > 10 epoches

% wakeDur_thresh = 3;
% NREMDur_thresh = 30; 
% REMDur_thresh = 10; 

prompt = {'Wake Stage Duration Threshhold (epochs)', 'NREM Stage Duration Threshhold (epochs)', 'REM Stage Duration Threshhold (epochs)'};
dlg_title = 'Define the sleep stages';
num_lines = 1;
defaultans = {'3','30', '10'};
definitions = inputdlg(prompt,dlg_title,num_lines,defaultans);
wakeDur_thresh = str2double(char(definitions(1)));
NREMDur_thresh = str2double(char(definitions(2)));
REMDur_thresh = str2double(char(definitions(3)));

S_sleepcyc = struct();


[NREM_cyc, REM_cyc] = cal_plot_SleepCycle(S.EEG, S.EEG.sscore, wakeDur_thresh, NREMDur_thresh,REMDur_thresh, save_folder);

S_sleepcyc.subject = S.EEG.subject;
S_sleepcyc.condition = S.EEG.condition;
S_sleepcyc.sleepcyc_NREM = NREM_cyc;
S_sleepcyc.sleepcyc_REM = REM_cyc;
    
savepath = fullfile(save_folder,save_name); 
save(savepath, 'S_sleepcyc');   