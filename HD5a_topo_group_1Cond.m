%% HD5a_mat2EEGlab_topo_group.m

% Description: Plots the spectrum EEG topographs across multiple subjects 
% for a single condition, based on all frequency bands during the different sleep stages (PSG data) or
% eyes open/eyes closed stages (KDT data). 

% Inputs: 
% - a folder containing the .mat files for multiple subjects under one
% condition (should be the output from HD2_mat2EEGlab_topo_ind.m)
% - a folder where you want to save the merged group data

% Outputs: 
% - folder containing merged group data and topographs

% By tancy kao 17th Mar 2019

%% %% create EEG data match with EEGlab 
clc
clear
close all

% Make sure folder of group files is ready.
waitfor(msgbox('Before starting: Prepare a folder containing the .mat files for the different subjects to be analysed (e.g. Group Input Files folder). Files will be HD2 Output Files for different subjects.'));

% Message to remind the user they need .mat files with ALL 256 channels
waitfor(msgbox('Make sure the .mat files processed with ALL 256 CHANNELS from HD2 (e.g. 04KS-Condition_PSG MCI-all_channels.mat).'));

confirmation = 'No';

% Ask user to select files until the confirmation no longer returns No
while strcmp('No',confirmation) == 1
    fprintf('Select multiple .mat files for the one condition to plot - Hold down Ctrl to select multiple files. e.g. The files should be located in Group Input Files.');
    [mat_files, mat_files_Folder] = uigetfile('*.mat',...
        'Select .mat files with the same condition', 'MultiSelect', 'on');
    clc
    
    % Confirm the mat files
    for k = 1:length(mat_files)
        fullname = fullfile(mat_files_Folder,mat_files(k));
        S1(k) = load(char(fullname));
    end

    msg = sprintf('Confirm the input .mat files are:\n%s', strjoin(mat_files,'\n'));
    title = 'Confirm Selected Files';

    confirmation = questdlg(msg,...
        title,...
        'Yes','No','Yes');  
end 


% Check the mat files all have the same condition
conditionID_check = S1(1).EEG.condition; 

for k = 1:length(mat_files)
    if strcmp(S1(k).EEG.condition,conditionID_check) == 0
        waitfor(warndlg('The input .mat files do not all have the same Condition ID. Please check before proceeding.', 'Warning'));
        break 
    end 
end 

% set save path
fprintf('Select folder in which to save the merged group data - e.g. Group Output Files.');
folder = uigetdir;
savepath_folder = fullfile(folder);
clc

prompt = {'Enter the sleep study type (KDT or PSG):','Enter filename for the merged group dataset:'};
dlgtitle = 'Save settings';
dims = [1 35];
definput = {'KDT','NRS group data'};
savesettings = inputdlg(prompt,dlgtitle,dims,definput);
saveID = char(savesettings(2));
KDTvPSG = char(savesettings(1));

%% merge all data

all_dat =[];
switch KDTvPSG
    case 'PSG'
        stages = [0,1,2,3,4,5]; % treat 4 as S2+S3
        stage_names ={'Wake','S1','S2','S3','NREM(S2+S3)','REM'};
            
    case 'KDT'
        stages = [1,0,3];
        stage_names ={'eyes open','eyes closed','overall'};
end

for i = 1: length(stages)

    for subj_i = 1:length(mat_files)
        filenames{subj_i} = mat_files(subj_i);
%         EEG = load([mat_files(subj_i).folder, filesep, mat_files(subj_i).name]);
        EEG = load(char(fullfile(mat_files_Folder,mat_files(subj_i))));
        %EEG = load(mat_files(sfi).name);
        field = fieldnames(EEG);
        EEG_data = EEG.(field{1});
        
        switch KDTvPSG
           case 'PSG'
                if stages(i) == 4
                % S2 + S3 
                    idx_stage = [find(EEG_data.sscore==2); find(EEG_data.sscore==3)];
                else
                    idx_stage = find(EEG_data.sscore==stages(i));
                end
            case 'KDT'
                if stages(i) == 3
                    idx_stage = [find(EEG_data.sscore==1); find(EEG_data.sscore==0)];
                else
                    idx_stage = find(EEG_data.sscore==stages(i));
                end

        end
        
%         if stages(i) == 3
%             idx_stage = [find(EEG_data.sscore==stages(i)) find(EEG_data.sscore==stages(i)+1)];
%         else
%             idx_stage = find(EEG_data.sscore==stages(i));
%         end

        %data_selection = EEG_data.psdinterp.alldata(:, :, idx_stage);
        data_selection = EEG_data.data(:, :, idx_stage);
        all_dat(:,:,subj_i) =squeeze(nanmean(data_selection,3)); % average across epochs;
    end
    
    EEG = EEG_data;
    EEG.stage_name = char(stage_names(i)); 
    EEG.subject = 'Group';
    EEG.filepath = savepath_folder;
    
    EEG.psdinterp.data = all_dat;
    EEG.psdinterp.Hzbins = EEG.Hzbins;
    
    plot_bands_topo_EEG_TK(EEG);
    
end
savepath = fullfile(savepath_folder,saveID);
save(savepath,'EEG');
disp('==========================')
disp('Done')


