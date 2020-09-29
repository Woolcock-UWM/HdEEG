% % topography plot for individual subject
% % for sleep cycle analysis
% % SleepCycle_data was generated from 'getNREM_cycle.m'
% % by tancy 20/Dec/2019

%% cycle spectral topography plot

clear
close all
clc

fprintf('Select the PSG .mat file with 256 channels data to be analysed, from the "HD2 Output Files" folder \n (e.g. 04KS-ConditionPSG MCI-all_channels.mat) \n');
[mat_file, mat_folder] = uigetfile('*.mat'); 
S = load(fullfile(mat_folder,mat_file));
clc


% load sleep_cycle data
fprintf('Select sleep cycle .mat file from "SleepCycle Output files" \n This should be an output from the HD4a_getNREM_cycle_ind script. \n (e.g. 04KS_SleepCycle_data.mat) \n');
[sleepcycFile, sleepcycFolder] = uigetfile('*.mat');
load(fullfile(sleepcycFolder, sleepcycFile));
clc

% Ask user where to save the sleep cycle data and what to name it
fprintf("Select the folder in which you want to save \n (e.g. 'SleepCycle Output files' folder\n");
folder = uigetdir;
save_folder = fullfile(folder);
clc


% self definded parameters
prompt = {'Study:','Normalisation Setting (raw or norm):','NREM Cycle Label:'};
dlg_title = 'Input parameters';
num_lines = 1;
defaultans = {'CFS','raw','SleepCycle NREM_'};
parameters = inputdlg(prompt,dlg_title,num_lines,defaultans);
cur_cond = char(parameters(1));
norm_type = char(parameters(2));
ncyclelable= char(parameters(3));

%%
% main plot section
    
for jcycle = 1:length(S_sleepcyc.sleepcyc_NREM)

    goodchans_BS = S.EEG.data;
    channels_label = 'all_channels';

    % % get sleep cycle              
    BS_NREM_cyc  = cell2mat(S_sleepcyc.sleepcyc_NREM(jcycle));           
    BS_idx_stage = find(S.EEG.sscore==2);           
    BS_curStage = intersect(BS_NREM_cyc, BS_idx_stage);            
    BS_selDat = goodchans_BS(:, :, BS_curStage);
    cur_Dat = squeeze(nanmean(BS_selDat,3));

    EEG.chanlocs = S.EEG.chanlocs;
    EEG.subject = S.EEG.subject;
    EEG.condition = S.EEG.condition;
    EEG.Hzbins = S.EEG.Hzbins;
    EEG.stage_name = [cur_cond,' ', ncyclelable, num2str(jcycle)];
    plot_sleepcycle_topo_ind(cur_Dat, EEG, norm_type, save_folder,channels_label)    

end
