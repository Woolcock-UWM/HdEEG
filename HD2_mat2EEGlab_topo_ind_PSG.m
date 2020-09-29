%% HD2_mat2EEGlab_topo_ind.m
% SUMMARY: 
% Plots spectrum EEG topographs and spectrum powers of individual subject
% including all stages and all frequency bands. Manually identifies and handles the bad
% channels.

% INPUTS: 
% 1) .mat file output from HD1_prana2matlab - individual subject's PRANA
% results for one condition
% 2) .mat file with EEG channel locations
% 3) .mat file with channel names and corresponding channel numbers
% 4) If analysing defined channels: .mat file with defined channels
% 5) If removing channels from the analysis: .xlsx file listing the names
% of EEG channels to remove

% OUTPUTS: 
% Creates a folder named with the Subject ID, containing: 
% - A .mat file with interpolated EEG data for the individual subject and one condition, for further analysis
% - A folder of the interpolated topoplots and spectral power graphs for
% each sleep stage

% USE: 
% 1) Prepare all relevant input .mat/.xlsx files, and a folder to save the
% exported files
% 2) Follow the prompts to select the .mat file to analyse, the channel
% locations, channel names, and the folder to save the output plots. 
% 3) Follow the prompts to enter conditions and parameters.
% 4) Wait for the program to generate all plots and figures. This may take
% a while. When the "Done!" message is displayed, the program has finished
% and the exported files have been successfully saved. 

% By Tancy Kao 17th Mar 2019

clc
clear
close all
%% load mat files output from HD1
fprintf('Select .mat file output from "HD1 Output files" (e.g. 04KS_PSG_PSG.mat)');
[outputFile, outputFolder] = uigetfile('*.mat');
load(fullfile(outputFolder, outputFile));
clc

% load EGI 256 channel locations
fprintf('Select .mat file for channel locations, e.g. egi256_chanlocs');
[chanlocsFile, chanlocsFolder] = uigetfile('*.mat');
load(fullfile(chanlocsFolder, chanlocsFile));
clc

% load channel names and cooresponding EEG chan numbers
fprintf('Select .mat file for channel names and corresponding 256 EEG channel numbers, e.g. channels_EGI');
[EEGchanFile, EEGchanFolder] = uigetfile('*.mat');
load(fullfile(EEGchanFolder, EEGchanFile));
clc

% Load the defined good channels
fprintf('Select .mat file for defined channels, e.g. egi_clusters');
[definedchanFile, definedchanFolder] = uigetfile('*.mat');
load(fullfile(definedchanFolder, definedchanFile));
clc


% set the folder to save exported figs
fprintf("Select the folder in which you want to create the 'HD2 Output files' folder, e.g. a folder named with the subject ID");
folder = uigetdir;
figpath = fullfile(folder);
clc

cd (figpath)
if exist ('HD2 Output files', 'dir')  ~= 7
    mkdir('HD2 Output files');
    
end

figpath = [figpath, filesep,'HD2 Output files']; 

% ask for user input to set conditions 
prompt = {'Enter Subject ID:','Enter Condition ID: i.e. PSG MCI'};
dlgtitle = 'Input conditions';
dims = [1 35];
definput = {'12AB','PSG MCI'};
conditions = inputdlg(prompt,dlgtitle,dims,definput); 
subjectID = char(conditions(1));
conditionID = char(conditions(2));

prompt = {'Are there channels to remove? (1 = Yes, 2 = No)','Analyse all channels or defined channels? (1 = all 256 channels, 2 = defined channels)'};
dlgtitle = 'Input EEG Settings';
dims = [1 35];
definput = {'1','2'};
EEGSettings = inputdlg(prompt,dlgtitle,dims,definput);
channels_remove = str2double(char(EEGSettings(1))); 
channels_plot = str2double(char(EEGSettings(2)));

if channels_remove == 1 
    % request excel file with list of channels to remove
    fprintf('Select .xlsx file with the names of channels to remove (e.g. EEG100)'); 
    [removeFile, removeFolder] = uigetfile('*.xlsx');
    [~,rm_channels] = xlsread(fullfile(removeFolder,removeFile));
    clc
end

    
% load defined channels if option is chosen
if channels_plot == 2
    good_chans = find(egi_clusters(:,2)~=0); % consider defined channels 
    channels_label = 'defined_channels'; % add defined channels label to file name 
else 
    channels_label = 'all_channels'; % add all channels label to file name
end 

%%
% % select condition 1 and their sleep scores
    if exist('power1','var')
        power=power1;
        sleep_scores = sscore1';
        fileName = folder1;
    else
        error('The imported .mat file does not contain data.');
    end

cur_chan_names = fieldnames(power);

% % remove reference Cz 
channels_EGI(ismember(channels_EGI, 'Cz'))=[];
cur_chan_names(ismember(cur_chan_names, 'Cz')) =[];

%% bad channels 
% % remove the channels imported from the excel file 
if channels_remove == 1
    for i = 1:length(rm_channels)
        cur_chan_names(ismember(cur_chan_names, rm_channels(i))) =[];
        power_chan = rm_channels(i);
        power = rmfield(power,power_chan);
    end 
end

EEG.original_chanlocs = EEG_256chanlocs; 

%% get current channels, remove bad channels 

% find original channels appear in current channels
[tf,loc]=ismember(channels_EGI,cur_chan_names);

cur_chans = channels_EGI(tf); 

% set default allData size
[i,j] = size(power.(cur_chans{1}));
allData = zeros(length(cur_chans), i, j);

for i = 1: length(cur_chans)
    %if sum(strcmp(names,cur_chans{i}))
    data = power.(cur_chans{i});
    allData(i,:,:) = data; 
    %end
end

[chans, time_range, freqbans]=size(allData);
EEG.data = reshape(allData, chans, time_range*freqbans); % save data to EEG structure


%% get current channel locations 
% extract the index of bad channels 
bad_channels = find(tf==0);
disp(['bad_channels:' num2str(bad_channels)]);

% remove bad channels from chanlocs
for i = 1:length(bad_channels)
    toRemove = strcmp({EEG_256chanlocs.labels}, num2str(bad_channels(i)));
    EEG_256chanlocs(toRemove) = [];
end

% save current channels to EEG
EEG.chanlocs = EEG_256chanlocs; 

% adjust parameters for eeg_interp
EEG.setname = 'psd';
EEG.filepath = [figpath, filesep];
%EEG.subjectID = subjectID;
EEG.subject = subjectID;
EEG.condition = conditionID;
EEG.filename = fileName;
EEG.sscore = sleep_scores;
                                                        
EEG.trials = 1;
EEG.nbchan = chans;
EEG.pnts = time_range*freqbans;
EEG.icasphere = [];

EEG.icawinv =[];
EEG.icaweights = [];
EEG.icaact = [];
EEG.srate = 0.0333; % sampling rate (in Hz)
EEG.xmin = 0; %  start time (sec)
EEG.xmax = EEG.pnts/EEG.srate; % epoch end time (sec)

% freq = 0.25;% default from prana 
prompt = {'Frequency resolution of spectral analysis:', 'End frequency:'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'0.25','44.75'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
freq = str2num(char(answer(1)));
freq_end = str2num(char(answer(2)));
EEG.Hzbins = (0:freq:freq_end);

%% interpolation of removed channels
tic

EEG = eeg_interp(EEG, EEG.original_chanlocs);
disp(['... elapsed time ',num2str(toc/60),' interpolating channels']);

%newfilename = strrep(EEG.filename,'.set','interp.set');
EEG.setname  = [EEG.setname,'interp'];

% ouputname
EEG.setname = [subjectID,'-',conditionID,'-',EEG.setname];

% get size from interp EEG.data
[m, n]=size(EEG.data);
EEG.psdinterp.Hzbins = EEG.Hzbins;
EEG.psdinterp.alldata = reshape(EEG.data, [m, time_range, freqbans]);
EEG.psdinterp.alldata = permute(EEG.psdinterp.alldata, [1 3 2]); % rearrange dim2 and 3
%% plot spectrum for all stages
%'1 for S1; 2 for S2; 3 for S3+S4; 5 for REM)';

stages = [1,2,3,5];
stage_names ={'S1','S2','S3+S4','REM'};

outchans =[];
len_chans =[];
for i = 1: length(stages)
    if stages(i) == 3
        idx_stage = [find(sleep_scores==stages(i)) find(sleep_scores==stages(i)+1)];
    else
        idx_stage = find(sleep_scores==stages(i));
    end
    
    data_selection = EEG.psdinterp.alldata(:, :, idx_stage);
    EEG.psdinterp.data = data_selection; 
    
    
    EEG.stage_name = char(stage_names(i));
   
    if channels_plot == 1 % 256 channels
        [outlier_tot] = plot_bands_spectra_ind_EEG_TK(EEG);
        
    elseif channels_plot == 2 % defined good 164 channels
        [outlier_tot] = plot_bands_spectra_ind_goodEEG_TK(EEG, good_chans);
    end
    
        
    if sum(outlier_tot)>0
        % export outlier channels
        len_chans = [len_chans length(outlier_tot)];
        outchans{i} = outlier_tot;
    else % no outlier 
        len_chans = [len_chans length(outlier_tot)];
        outchans{i} = NaN;        
    end
    
end

%% 2 dim to 3 dim

EEG.times = freqbans;
EEG.pnts = time_range;
EEG.data = EEG.psdinterp.alldata;
EEG.psdinterp =[];

%% Export EEG and outliers

% Export outlier channels
% Convert cell to a table and use first row as variable names

output_stages = {'S1','S2','S3_S4','REM'};
outchans_all = nan(max(len_chans),length(stages));

for ii = 1: length(stages)
    outchans_all(1:length(outchans{ii}),ii) = outchans{ii};
end

outchans_table = array2table(outchans_all,'VariableNames',output_stages);

% % Write the table to a CSV file

if channels_plot == 1 % 256 channels
    save_outchansname = fullfile(figpath,...
    [subjectID,'_',EEG.condition,'_outlier_chans.txt']);

elseif channels_plot == 2 % defined good 164 channels
    save_outchansname = fullfile(figpath,...
    [subjectID,'_',EEG.condition,'_outlier_', channels_label,'.txt']);

end

writetable(outchans_table,save_outchansname, 'Delimiter',' ')


% % export interp EEG mat as separate baseline and treatment
saveID = sprintf('%s-Condition%s-%s',subjectID,conditionID,channels_label);
savepath = fullfile(figpath,saveID);
save(savepath, 'EEG');

disp('==========')
disp('Done!');

