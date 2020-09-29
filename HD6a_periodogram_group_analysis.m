%% HD6a_periodogram_group_analysis

% % plot periodogram of frequency of different sleep stages 
% % and statistical analysis of multiple subjects
% % PSG and KDT
% % two-sample t-test (could use for different number of subjects in each
% condition)
% % paired-sample t-test (each subject has two conditions i.e. pre and post
% condition)
% % import all channels mat
% % wh
% % by tancy 17/May/2019

clear
close all
clc

tic

% Message to remind the user they need .mat files with ALL 256 channels
waitfor(msgbox('Make sure to input .mat files processed with ALL 256 CHANNELS from HD2 (e.g. 04KS-Condition_PSG MCI-all_channels.mat).'));

confirm_files = 'No';

% Choose Condition 1 files until confirmation returns Yes
while strcmp('No',confirm_files) == 1
    fprintf('Select the files for Condition 1. Hold down Ctrl to select multiple files.');
    disp('e.g. The files should be in the Group Input Files folder');
    [mat1_files, mat1_files_Folder] = uigetfile('*.mat',...
        'Select Condition 1 files','MultiSelect', 'on');
    if ~iscell(mat1_files)
        mat1_files = {mat1_files};
    end %now filename is a cell array regardless of the number of selected files.
    clc

    fprintf('Select the files for Condition 2. Hold down Ctrl to select multiple files.');
    disp('e.g. The files should be in the Group Input Files folder');
    [mat2_files, mat2_files_Folder] = uigetfile('*.mat',...
        'Select Condition 2 files', 'MultiSelect', 'on');
    if ~iscell(mat2_files)
        mat2_files = {mat2_files};
    end
    clc
    
    % Set up different confirmation messages if Condition 1 and 2 have different numbers of files
    if length(mat1_files) ~= length(mat2_files) 
        msg = sprintf('The two groups have different numbers of files - please check this is correct. \nConfirm the Condition 1 files are:\n%s \n \nConfirm the Condition 2 files are: \n%s', strjoin(mat1_files,'\n'), strjoin(mat2_files,'\n'));
        title = 'Confirm Selected Files';
    else % same numbers -> just confirm the files are correct
        msg = sprintf('Confirm the Condition 1 files are:\n%s \n \nConfirm the Condition 2 files are: \n%s', strjoin(mat1_files,'\n'), strjoin(mat2_files,'\n'));
        title = 'Confirm Selected Files';
    end 
    
    confirm_files = questdlg(msg,...
    title,...
    'Yes','No','Yes');    
end 

% load defined brain areas
fprintf('Select the .mat file for defined channels, e.g. egi_clusters ');
[defined_file, defined_folder] = uigetfile('*.mat');
load(fullfile(defined_folder, defined_file));
clc

for k = 1 : length(mat1_files)
  fullname = fullfile(mat1_files_Folder,mat1_files(k));
  S1(k) = load(char(fullname));
end

for k = 1 : length(mat2_files)
  fullname = fullfile(mat2_files_Folder,mat2_files(k));
  S2(k) = load(char(fullname));
end

EEG_1 = cat(1, S1.EEG);
EEG_2 = cat(1, S2.EEG);

toc
%% user defined parameters
% save path
disp('Select the folder in which to save the combined plots - e.g. Group Output Files');
folder = uigetdir;
save_folder = fullfile(folder);
clc

prompt = {'Study type (KDT or PSG):', 'Average all channels or defined channels? (1 = all 256 channels, 2 = defined channels)','Save name for combined plots:', sprintf('Statistical analysis type \n(twosampleT = two-sample T-test, \n pairT = paired two-sample T-test (must SAME number of subjects for both conditions)):')};
dlg_title = 'Define parameters';
num_lines = [1 90];
defaultans = {'KDT','1','MCI_PSG_CondA_CondB','pairT'};
settings = inputdlg(prompt,dlg_title,num_lines,defaultans);

KDTvPSG = char(settings(1));
select_channels = str2double(char(settings(2)));
cond_name = char(settings(3));
stat_type = char(settings(4)); % twosampleT vs. pairT (two-sample t-test,  paired two-sample t-test)

%%
switch KDTvPSG
    case 'PSG'
        stages = [0,1,2,3,4,5]; % treat 4 as S2+S3
        stage_names ={'Wake','S1','S2','S3','NREM(S2+S3)','REM'};
            
    case 'KDT'
        stages = [1,0,3];
        stage_names ={'eyes open','eyes closed','overall'};
end
    
numstages   =  length(stages);
nSubj1       = length({EEG_1.subject});
nSubj2       = length({EEG_2.subject});

%%
switch select_channels
        case 1
            good_chans = egi_clusters(:,1);
        case 2
            good_chans = find(egi_clusters(:,2)~=0);
end

%% condition 1
all_cond1Data = [];

for isubj = 1:nSubj1
    EEGdat = EEG_1(isubj);
    
    % select channels of interest        
    goodchans_EEG1 = EEGdat.data(good_chans,:,:);
    

    avg_chans = squeeze(nanmean(goodchans_EEG1,1));
    %fill_dat = fillmissing(avg_chans,'linear',2, 'EndValues','nearest');
        
    % aggrate stages
    agg_stages = [];
    for jstage = 1:length(stages)

        switch KDTvPSG
           case 'PSG'
                if stages(jstage) == 4
                % S2 + S3 
                    cur_stage = [find(EEGdat.sscore==2); find(EEGdat.sscore==3)];
                else
                    cur_stage = find(EEGdat.sscore==stages(jstage));
                end
            case 'KDT'
                if stages(jstage) == 3
                    cur_stage = [find(EEGdat.sscore==1); find(EEGdat.sscore==0)];
                else
                    cur_stage = find(EEGdat.sscore==stages(jstage));
                end
        end

        median_pwr = squeeze(nanmedian(avg_chans(:,cur_stage),2)); 
        if all(isnan(median_pwr(:)))
            disp([EEG_1(isubj).subject, 'No data in stage:',stage_names(jstage)])
        end
        agg_stages = cat(2, agg_stages, median_pwr); 
    end

    % export baseline and treatment data of all rois and all stages
   
    all_cond1Data  = cat(3,all_cond1Data,agg_stages);        
end

clear EEGdat avg_chans fill_dat agg_stages
%% condition 2
all_cond2Data = [];
for isubj = 1:nSubj2
    EEGdat = EEG_2(isubj);
    
    % select channels of interest        
    goodchans_EEG2 = EEGdat.data(good_chans,:,:);
    
    avg_chans = squeeze(nanmean(goodchans_EEG2,1));
    %fill_dat = fillmissing(avg_chans,'linear',2, 'EndValues','nearest');

    % aggrate stages
    agg_stages = [];
    for jstage = 1:length(stages)

        switch KDTvPSG
           case 'PSG'
                if stages(jstage) == 4
                % S2 + S3 
                    cur_stage = [find(EEGdat.sscore==2); find(EEGdat.sscore==3)];
                else
                    cur_stage = find(EEGdat.sscore==stages(jstage));
                end
            case 'KDT'
                if stages(jstage) == 3
                    cur_stage = [find(EEGdat.sscore==1); find(EEGdat.sscore==0)];
                else
                    cur_stage = find(EEGdat.sscore==stages(jstage));
                end
        end

        % warning message 
        median_pwr = squeeze(nanmedian(avg_chans(:,cur_stage),2));  
        if all(isnan(median_pwr(:)))
            disp([EEG_2(isubj).subject, 'No data in stage:',stage_names(jstage)])

        end
        agg_stages = cat(2, agg_stages, median_pwr); 
    end
  
    all_cond2Data  = cat(3,all_cond2Data,agg_stages);        
end



%% plot power_stages_pval
% to plot log, input raw as scale_convert
EEG.filepath = save_folder;
EEG.save_title = cond_name;
EEG.cond1name = EEG_1(1).condition;
EEG.cond2name = EEG_2(1).condition;
EEG.cond1data = all_cond1Data;
EEG.cond2data = all_cond2Data;
EEG.stage_names = stage_names;
EEG.freqs = EEG_1.Hzbins;

plot_periodogram_stages_pval_group(EEG, stat_type, select_channels); 

disp('Done!');

