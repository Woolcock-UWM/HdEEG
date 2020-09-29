%% HD6b_Spectra_EEG_group_analysis
% by tancy 17/May/2019

% Description: Generates a topography plot and statistical analysis of multiple
% subjects. Merge multiple structures with same fields into one study. Can
% be used for both PSG and KDT data, with the following settings:
% - Raw signal or normalised signal 
% - Two-sample t-test (could use for when there are different numbers of
% subjects for each condition) 
% - Paired-sample t-test (each subject has two conditoins i.e. pre and post
% condition)

% % by tancy 17/May/2019


clear
close all
clc

tic

% Message to remind the user they need .mat files with ALL 256 channels
waitfor(msgbox('Make sure to select .mat files processed with ALL 256 CHANNELS.(e.g. 04KS-Condition_PSG MCI-all_channels.mat)'));

% Ask to input condition 1 and condition 2 files until user confirms Yes
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
%% defined parameters

% save_folder = '/Users/tkao6355/Dropbox/Woolcock_DS/HDEEG/postPRANA_HDEEGanalysis/Matlab imported files/';
% save path
disp('Select the folder in which to save the combined plots - e.g. Group Output Files');
folder = uigetdir;
save_folder = fullfile(folder);
clc

prompt = {'Study type (KDT or PSG):', 'Save name for combined plots:', sprintf('Statistical analysis type: twosampeT or pairT \n( twosampleT = two-sample T-test, \n pairT = paired two-sample T-test (must SAME number of subjects for both conditions)):'), 'Normalisation setting (raw = raw, norm = normalised):'};
dlg_title = 'Define parameters';
num_lines = [1 90];
defaultans = {'PSG','MCI_PSG_CondA_CondB','twosampleT','norm'};
stat_settings = inputdlg(prompt,dlg_title,num_lines,defaultans);
KDTvPSG = char(stat_settings(1));
cond_name = char(stat_settings(2));
stat_type = char(stat_settings(3)); % twosampleT vs. pairT (two-sample t-test,  paired two-sample t-test)
norm_type = char(stat_settings(4)); % norm vs raw; if normalize apply to each subject

% load defined brain areas
fprintf('Select the .mat file for defined channels, e.g. egi_clusters ');
[defined_file, defined_folder] = uigetfile('*.mat');
load(fullfile(defined_folder, defined_file));
clc

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

%% main plot section
tmp_dat1 = [];
for jstage = 1: numstages

    for isubj = 1:nSubj1
        EEGdat = EEG_1(isubj);
 
        good_chans = egi_clusters(:,1);  
        % select channels of interest        
        goodchans_EEG1 = EEGdat.data(good_chans,:,:);
         
        
        switch KDTvPSG
           case 'PSG'
                if stages(jstage) == 4
                % S2 + S3 
                    idx_stage = [find(EEGdat.sscore==2); find(EEGdat.sscore==3)];
                else
                    idx_stage = find(EEGdat.sscore==stages(jstage));
                end
            case 'KDT'
                if stages(jstage) == 3
                    idx_stage = [find(EEGdat.sscore==1); find(EEGdat.sscore==0)];
                else
                    idx_stage = find(EEGdat.sscore==stages(jstage));
                end
        end
        
               
        selDat = goodchans_EEG1(:, :, idx_stage);
        tmp_dat1(:,:,isubj) =squeeze(nanmean(selDat,3));
        % warning message
        if all(isnan(selDat(:)))
            disp([EEG_1(isubj).subject, 'No data in stage:',stage_names(jstage)])
        
        end
       
    end
    
    
    clear isubj EEGdat selDat
    
    for isubj = 1:nSubj2
        EEGdat = EEG_2(isubj);
      
        good_chans = egi_clusters(:,1);  
        % select channels of interest        
        goodchans_EEG2 = EEGdat.data(good_chans,:,:);
         
        switch KDTvPSG
           case 'PSG'
                if stages(jstage) == 4
                % S2 + S3 
                    idx_stage = [find(EEGdat.sscore==2); find(EEGdat.sscore==3)];
                else
                    idx_stage = find(EEGdat.sscore==stages(jstage));
                end
            case 'KDT'
                if stages(jstage) == 3
                    idx_stage = [find(EEGdat.sscore==1); find(EEGdat.sscore==0)];
                else
                    idx_stage = find(EEGdat.sscore==stages(jstage));
                end
        end
        
               
        selDat = goodchans_EEG2(:, :, idx_stage);
        tmp_dat2(:,:,isubj) =squeeze(nanmean(selDat,3));
        % warning message 
        if all(isnan(selDat(:)))
            disp([EEG_2(isubj).subject, 'No data in stage:',stage_names(jstage)])
        
        end
        
    end
    clear isubj EEGdat selDat
    
% remove NAN stage

if strcmp(stat_type, 'pairT')
    for jj = 1:nSubj1
        vec1(jj) = all(all(isnan(tmp_dat1(:,:,jj))));
    end
    
    for jn = 1:nSubj2
        vec2(jn) = all(all(isnan(tmp_dat2(:,:,jn))));
    end
    
    idx = find([(vec1==0) & (vec2==0)]);
    
    tmp_dat1 = tmp_dat1(:,:,idx); % extract subjects with data
    tmp_dat2 = tmp_dat2(:,:,idx); % extract subjects with data
    
end


    
    EEG.filepath = save_folder;
    EEG.chanlocs = EEG_1(1).chanlocs;
    EEG.Hzbins = EEG_1(1).Hzbins;
    EEG.stage_name = stage_names(jstage);
    EEG.save_title = cond_name;
    
    if size(tmp_dat1,3) == 1
        disp(['NO DATA SHOW FOR STAGE:', stage_names(jstage)])
    elseif size(tmp_dat1,3) > 1
        plot_tval_group(tmp_dat1,tmp_dat2,EEG, good_chans, norm_type, stat_type);    
    end
    
           
end

disp('Done!');