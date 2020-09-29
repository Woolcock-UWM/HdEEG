%% HD5b_topo_group_2Conds.m
% Description: Plot spectrum EEG topographs and power spectra of multiple
% subjects under two different conditions, including all stages and frequency bands 
% - FOR BOTH KDT AND PSG DATA.
% - Can be used between two groups of multiple subjects under two different
% conditions, OR the same subject under two different conditions
% - The same colorbar scale is used for the two conditions

% Note: you can alter the threshholds for the different frequency bands in
% lines ....

% Inputs:
% - folder containing .mat files (output from hdEEG2 script) for one or multiple
% subjects under two different conditions in a KDT or PSG

% Outputs:
% - topoplots of merged group data for the two conditions 

% By tancy kao 07th Apr 2020

clear
close all
clc

fprintf('Select the folder containing the .mat files to analyse.\n e.g. Group Input Files folder');
folder = uigetdir;
set_folder = fullfile(folder);
clc

% input conditions 
prompt = {'Condition 1: (e.g. PM)','Condition 2: (e.g. AM)', 'Study Type (KDT or PSG):', 'Save name for combined plots:'};
dlg_title = 'Input conditions';
num_lines = 1;
defaultans = {'KDT PM','KDT AM', 'KDT','KDT PM and AM'};
conds = inputdlg(prompt,dlg_title,num_lines,defaultans);
cond1_name = char(conds(1));
cond2_name = char(conds(2)); 
KDTvPSG = char(conds(3));
save_name = char(conds(4));


confirm_files = 'No';

% Ask user to select files until the confirmation returns Yes
while strcmp('No',confirm_files) == 1
    fprintf('Select the files for Condition 1: %s. Hold down Ctrl to select multiple files.', cond1_name);
    disp('e.g. The files should be in the Group Input Files folder');
    [cond1_mat_files, cond1_mat_files_Folder] = uigetfile('*.mat',...
        'Select Condition 1 files', set_folder,'MultiSelect', 'on');
    if ~iscell(cond1_mat_files)
        cond1_mat_files = {cond1_mat_files};
    end %now filename is a cell array regardless of the number of selected files.
    clc

    fprintf('Select the files for Condition 2: %s. Hold down Ctrl to select multiple files.', cond2_name);
    disp('e.g. The files should be in the Group Input Files folder');
    [cond2_mat_files, cond2_mat_files_Folder] = uigetfile('*.mat',...
        'Select Condition 2 files', set_folder,'MultiSelect', 'on');
    if ~iscell(cond2_mat_files)
        cond2_mat_files = {cond2_mat_files};
    end
    clc
    
    % Set up different confirmation messages if Condition 1 and 2 have different numbers of files
    if length(cond1_mat_files) ~= length(cond2_mat_files) 
        msg = sprintf('The two groups have different numbers of files - please check this is correct. \nConfirm the Condition 1 files are:\n%s \n \nConfirm the Condition 2 files are: \n%s', strjoin(cond1_mat_files,'\n'), strjoin(cond2_mat_files,'\n'));
        title = 'Confirm Selected Files';
    else % same numbers -> just confirm the files are correct
        msg = sprintf('Confirm the Condition 1 files are:\n%s \n \nConfirm the Condition 2 files are: \n%s', strjoin(cond1_mat_files,'\n'), strjoin(cond2_mat_files,'\n'));
        title = 'Confirm Selected Files';
    end 
    confirm_files = questdlg(msg,...
    title,...
    'Yes','No','Yes');    
end 

% save path
disp('Select the folder in which to save the combined plots - e.g. Group Output Files');
folder = uigetdir;
save_dir = fullfile(folder);
clc

for k = 1 : length(cond1_mat_files)
%   fName = cond1_mat_files(k).name;
%   fFolder = cond1_mat_files(k).folder;
  fullname = fullfile(set_folder,cond1_mat_files(k));
  Cond1(k) = load(char(fullname));
end

for k = 1 : length(cond2_mat_files)
%   fName = cond2_mat_files(k).name;
%   fFolder = cond2_mat_files(k).folder;
  fullname = fullfile(set_folder,cond2_mat_files(k));
  Cond2(k) = load(char(fullname));
end

% 
AllEEG_cond1 = cat(1, Cond1.EEG);
AllEEG_cond2 = cat(1, Cond2.EEG);

%%

switch KDTvPSG
    case 'PSG'
        stages = [0,1,2,3,4,5]; % treat 4 as S2+S3
        stage_names ={'Wake','S1','S2','S3','NREM(S2+S3)','REM'};
            
    case 'KDT'
        stages = [1,0,3];
        stage_names ={'eyes open','eyes closed','overall'};
end
    
numstages    = length(stages);

for jstage = 1:numstages

    allSubjsCd1 = fun_mergeSubjsdata(AllEEG_cond1, stages, jstage, KDTvPSG);
    allSubjsCd2 = fun_mergeSubjsdata(AllEEG_cond2, stages, jstage, KDTvPSG);
   
    
    EEG.chanlocs = AllEEG_cond1.chanlocs;
    EEG.Hzbins = AllEEG_cond1.Hzbins;
    EEG.Bands.SWA     = find(EEG.Hzbins > 1   & EEG.Hzbins <= 4.5);
    EEG.Bands.Theta   = find(EEG.Hzbins > 4.5   & EEG.Hzbins  <= 8);
    EEG.Bands.Alpha   = find(EEG.Hzbins > 8   & EEG.Hzbins    <= 12);
    EEG.Bands.Sigma   = find(EEG.Hzbins > 12  & EEG.Hzbins    <= 15);
    EEG.Bands.Beta    = find(EEG.Hzbins > 15  & EEG.Hzbins    <= 25);
    EEG.Bands.Gamma   = find(EEG.Hzbins > 25  & EEG.Hzbins    <= 40);

    Bands       = fieldnames(EEG.Bands);
    numbands    = length(Bands);
    

    topofig = figure('position',[20 50 300 150*numbands]); %[left, bottom, width, height]
    
    subplot('position',[.1 .96 .8 .02])
    
    figlabel = strcat(stage_names{jstage}, {'_'}, {' group data'});

    
    text(.5,.5,figlabel,'FontSize',16,'fontweight',...
        'bold','horizontalalignment','center');
   
    colormap(jet);
    axis off
    
    % average subjects
    avgSubjsCd1 = squeeze(nanmean(allSubjsCd1,3));
    avgSubjsCd2 = squeeze(nanmean(allSubjsCd2,3));
   
    i=0;
    for kfreq = 1 : numbands
        figure(topofig); 

        avgBandsCd1 = squeeze(nanmean(avgSubjsCd1(:,EEG.Bands.(Bands{kfreq})),2));
        avgBandsCd2 = squeeze(nanmean(avgSubjsCd2(:,EEG.Bands.(Bands{kfreq})),2));             
        
        subplot(numbands,2, i+kfreq);
        if strcmp(Bands{kfreq},'SWA')==1
            text(-0.1,0.75,cond1_name,'FontSize',13,'fontweight','bold');
        end
        
     
        [~,Zi_TRT,~,~,~] = topoplot(avgBandsCd1, EEG.chanlocs,'shading','interp','style','map','maplimits',...
                                           'maxmin','whitebk','on','electrodes','off', 'plotrad', 0.57);
        [~,Zi_BS,~,~,~] = topoplot(avgBandsCd2, EEG.chanlocs,'shading','interp','style','map','maplimits',...
                                           'maxmin','whitebk','on','electrodes','off', 'plotrad', 0.57);
        
        amin = min(min(min(Zi_TRT), min(Zi_BS)));
        amax = max(max(max(Zi_TRT), max(Zi_BS)));  
                                       
        caxis manual

        caxis([amin amax]);     

        colorbar;

        text(-.8,0,(Bands{kfreq}),'FontSize',18,'rotation',90,'HorizontalAlignment','center');

        subplot(numbands,2,kfreq+i+1)
        if strcmp(Bands{kfreq},'SWA')==1
            text(-0.1,0.75,cond2_name,'FontSize',13,'fontweight','bold');
        end
        
        topoplot(avgBandsCd2, EEG.chanlocs,'shading','interp','style','map','maplimits',...
                                           'maxmin','whitebk','on','electrodes','off', 'plotrad', 0.57);

        caxis manual
           caxis([amin amax]);     
               
        colorbar;
        
        
        i = i+1;        
        clear Zi_BS Zi_TRT colormap       
        
    end
   
    % export figure
    set(topofig,'color','w','paperpositionmode','auto');
    print(topofig,'-dpng','-r500',[save_dir,filesep, save_name,'_',char(stage_names(jstage)),'_spectral_power_two_groups_topo.png']);
              
end
disp('Done!');


