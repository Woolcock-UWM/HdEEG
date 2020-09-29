%% HD7_Spectra_EEG_group_sleepcyc_analysis
% % topography plot and statistical analysis of multiple subjects
% % for sleep cycle analysis
% % SleepCycle_data was generated from 'getNREM_cycle.m'
% % PSG and KDT
% % raw signal and normalized signal
% % two-sample t-test (could use for different number of subjects in each
% condition)
% % paired-sample t-test (each subject has two conditions i.e. pre and post
% condition)
% % by tancy 20/Dec/2019

% Plots with the minimum number of sleep cycles found across all the
% selected subjects
%% Sleep cycle spectral topography analysis

clear
close all
clc

waitfor(msgbox('Make sure to select .mat files processed with ALL 256 CHANNELS, e.g. 04KS-ConditionPSG MCI-all_channels.'));

confirmation_cond1 = 'No';

% select condition 1 files until the user confirms they're correct 
while strcmp(confirmation_cond1,'No') == 1
    fprintf('Select the .mat files for Condition 1 (output files from HD2). Hold down Ctrl to select multiple files. \n e.g. The files should be in the Group Input Files folder');
    [mat1_files, set1_folder] = uigetfile('*.mat',...
        'Select Condition 1 files','MultiSelect', 'on');
    clc
    if ~iscell(mat1_files)
    mat1_files = {mat1_files};
    end
    
    fprintf('Select the sleep cycle .mat files for Condition 1 (output files from HD4a). Hold down Ctrl to select multiple files. \n e.g. The files should be in the SleepCycle Output Files folder');
    [cyc1_files, cyc1_folder] = uigetfile('*.mat',...
        'Select Condition 1 Sleep Cycle files','MultiSelect', 'on');
    clc
        if ~iscell(cyc1_files)
        cyc1_files = {cyc1_files};
        end 
        
    % Confirm Condition 1 files
    msg = sprintf('Confirm the Condition 1 .mat files are:\n%s \n \nand the Condition 1 sleep cycle files are: \n%s', strjoin(mat1_files,'\n'), strjoin(cyc1_files,'\n'));
    title = 'Confirm Selected Files';

    confirmation_cond1 = questdlg(msg,...
        title,...
        'Yes','No','Yes');
end 

% select Condition 2 files until user confirms they're correct
confirmation_cond2 = 'No';
while strcmp(confirmation_cond2,'No') == 1
fprintf('Select the .mat files for Condition 2 (output files from HD2). Hold down Ctrl to select multiple files. \n e.g. The files should be in the Group Input Files folder');
[mat2_files, set2_folder] = uigetfile('*.mat',...
    'Select Condition 2 files','MultiSelect', 'on');
clc
    if ~iscell(mat2_files)
        mat2_files = {mat2_files};
    end   
    
fprintf('Select the sleep cycle .mat files for Condition 2 (output files from HD4a). Hold down Ctrl to select multiple files. \n e.g. The files should be in the SleepCycle Output Files folder');
[cyc2_files, cyc2_folder] = uigetfile('*.mat',...
    'Select Condition 2 Sleep Cycle files','MultiSelect', 'on');
clc

    if ~iscell(cyc2_files)
        cyc2_files = {cyc2_files};
    end    
% Confirm Condition 2 files
    msg = sprintf('Confirm the Condition 2 .mat files are:\n%s \n \nand the Condition 2 sleep cycle files are: \n%s', strjoin(mat2_files,'\n'), strjoin(cyc2_files,'\n'));
    title = 'Confirm Selected Files';

    confirmation_cond2 = questdlg(msg,...
        title,...
        'Yes','No','Yes');
end 
  
% select folder to save figures
disp('Select the folder in which to save the figures - e.g. Group Output Files');
folder = uigetdir;
save_folder = fullfile(folder);
clc

% load defined brain areas
fprintf('Select .mat file for defined channels, e.g. egi_clusters');
[definedchanFile, definedchanFolder] = uigetfile('*.mat');
load(fullfile(definedchanFolder, definedchanFile));
clc

for k = 1:length(mat1_files)
%     C1(k) = load([mat1_files(k).folder, filesep, mat1_files(k).name]);
    fullname = fullfile(set1_folder,mat1_files(k));
    C1(k) = load(char(fullname));
    
end

for k = 1:length(cyc1_files)
%     S1(k) = load([cyc1_files(k).folder, filesep, cyc1_files(k).name]);
    fullname = fullfile(cyc1_folder,cyc1_files(k));
    S1(k) = load(char(fullname));

end


for k = 1:length(mat2_files)
%     C2(k) = load([mat2_files(k).folder, filesep, mat2_files(k).name]);
    fullname = fullfile(set2_folder,mat2_files(k));
    C2(k) = load(char(fullname));

    
end

for k = 1:length(cyc2_files)
%     S2(k) = load([cyc2_files(k).folder, filesep, cyc2_files(k).name]);
    fullname = fullfile(cyc2_folder,cyc2_files(k));
    S2(k) = load(char(fullname));

end

EEG_1 = cat(1, C1.EEG);
SleepCyc_1 = cat(1, S1.S_sleepcyc);

EEG_2 = cat(1, C2.EEG);
SleepCyc_2 = cat(1, S2.S_sleepcyc);

%% Check the minimum number of sleep cycle across all subjects
n_sleepcyc1 = [];
for jj = 1:length(SleepCyc_1)
    n_sleepcyc1(jj) = length(SleepCyc_1(jj).sleepcyc_NREM);
end
n_sleepcyc2 = [];
for jj = 1:length(SleepCyc_2)
    n_sleepcyc2(jj) = length(SleepCyc_2(jj).sleepcyc_NREM);
end
ncycle = min(min(n_sleepcyc1,n_sleepcyc2));
%% self definded parameters
% stat_type = 'twosampleT'; % twosampleT vs. pairT (two-sample t-test,  paired two-sample t-test)
% norm_type = 'norm'; % norm vs raw; if normalize apply to each subject
% cond_name = 'PSG_CondA_CondB_SleepCycle';
cur_stage = 2; 

prompt = {'Save name for combined plots:', 'Statistical analysis type (twosampleT = two-sample T-test, pairT = paired two-sample T-test (must be SAME number of subjects)):', 'Normalisation setting (raw = raw, norm = normalised):'};
dlg_title = 'Define parameters';
num_lines = [1 60];
defaultans = {'PSG_CondA_CondB_SleepCycle','twosampleT','norm'};
stat_settings = inputdlg(prompt,dlg_title,num_lines,defaultans);
cond_name = char(stat_settings(1));
stat_type = char(stat_settings(2)); % twosampleT vs. pairT (two-sample t-test,  paired two-sample t-test)
norm_type = char(stat_settings(3)); % norm vs raw; if normalize apply to each subject
%% prepare plot topography map and statistic analysis

subj_code1 = {EEG_1.subject};
cond_code1 = {EEG_1.condition};
subj_idx1     = unique(subj_code1);

subj_code2 = {EEG_2.subject};
cond_code2 = {EEG_2.condition};
subj_idx2     = unique(subj_code2);

nSubj1       = length({EEG_1.subject});
nSubj2       = length({EEG_2.subject});

%% define sleep stage
stages = [1,2,3,4,5]; % treat 4 as S2+S3
stage_names ={'N1','N2','N3','NREM(N2+N3)','REM'};

%%
% main plot section
tmp_Cond1_dat = [];
tmp_Cond2_dat = [];
% consider good channels 
good_chans = find(egi_clusters(:,2)~=0);

for jcycle = 1:ncycle
    
     for isubj = 1:nSubj1
        Cond1 = strcmp(subj_code1, char(subj_idx1(isubj))); 
        
        Cond1file = EEG_1(Cond1);
        Cond1_sleepcyc = SleepCyc_1(Cond1);
        
          
        % select channels of interest        
        goodchans_Cond1 = Cond1file.data(good_chans,:,:);   
        
        % % get sleep cycle
        if (length(Cond1_sleepcyc.sleepcyc_NREM) >= jcycle)
            Cond1_NREM_cyc = cell2mat(Cond1_sleepcyc.sleepcyc_NREM(jcycle));
             if stages(cur_stage) == 4
            % S2 + S3 
                Cond1_idx_stage = [find(Cond1file.sscore==2); find(Cond1file.sscore==3)];
            else
                Cond1_idx_stage = find(Cond1file.sscore==stages(cur_stage));
            end

            Cond1_curStage = intersect(Cond1_NREM_cyc, Cond1_idx_stage);
            
            Cond1_selDat = goodchans_Cond1(:, :, Cond1_curStage);
            tmp_Cond1_dat(:,:,isubj) =squeeze(nanmean(Cond1_selDat,3));
        end
    end
    
    for isubj = 1:nSubj2
        Cond2 = strcmp(subj_code2, char(subj_idx2(isubj))); 

        Cond2file = EEG_2(Cond2);
        Cond2_sleepcyc = SleepCyc_2(Cond2);
        
        % select channels of interest        
        goodchans_Cond2 = Cond2file.data(good_chans,:,:);   

        % % get sleep cycle
        if (length(Cond2_sleepcyc.sleepcyc_NREM) >= jcycle)
            Cond2_NREM_cyc = cell2mat(Cond2_sleepcyc.sleepcyc_NREM(jcycle));
            
            if stages(cur_stage) == 4
            % S2 + S3 
                Cond2_idx_stage = [find(Cond2file.sscore==2); find(Cond2file.sscore==3)];
            else
                Cond2_idx_stage = find(Cond2file.sscore==stages(cur_stage));
            end

            Cond2_curStage = intersect(Cond2_NREM_cyc, Cond2_idx_stage);
            Cond2_selDat = goodchans_Cond2(:, :, Cond2_curStage);
            tmp_Cond2_dat(:,:,isubj) =squeeze(nanmean(Cond2_selDat,3));
        end


    end    
    
    if ~isempty(tmp_Cond1_dat) & ~isempty(tmp_Cond2_dat)
        EEG.filepath = save_folder;
        EEG.chanlocs = EEG_1.chanlocs;
        EEG.Hzbins = EEG_1.Hzbins;
        EEG.stage_name = ['Cycle-', num2str(jcycle),' ',...
            'Stage-', char(stage_names(cur_stage))];
        EEG.save_title = cond_name;
        
        plot_tval_topo_TK(tmp_Cond1_dat,tmp_Cond2_dat,EEG, good_chans, norm_type, stat_type);    
    end 
    %clear tmp_Cond1_dat  tmp_Cond2_dat
end

disp('Done!');