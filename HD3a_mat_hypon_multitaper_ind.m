%% HD3a_nat_hypon_multitaper_ind.m

% Description: Plots hypnogram and multitaper spectrogram from global (all good channels) or defined
% channels, for an individual subject under one condition. power of the
% frequencies over time.
% Plots based on overnight time-frequency by sleep stages, using either a raw or dB scale. 

% Inputs: 
% - .mat file output from HD2_mat2EEGlab_topo_ind_PSG.m
% - .mat file containing the defined good channels to analyse 

% Outputs: 
% - one figure containing a hypnogram plot, and a  multitaper
% spectrogram plot


clc
clear
close all

fprintf('Select the PSG .mat file output with 256 channels from "HD2 Output files" folder (e.g. 04KS-Condition_PSG MCI-all_channels.mat) \n');
[defined_file, defined_folder] = uigetfile('*.mat');
clc

S(1) = load([defined_folder, filesep, defined_file]);


% Load the defined good channels
fprintf('Select the .mat file for defined channels, e.g. egi_clusters ');
[defined_file, defined_folder] = uigetfile('*.mat');
load(fullfile(defined_folder, defined_file));
clc

% Ask user if all channels are being used or just defined channels 
prompt = {'Use all channels or defined channels? (1 = all 256 channels, 2 = defined channels)', 'plot multitpaer with raw or dB scale? (1 = raw, 2 = dB scale)'};
dlgtitle = 'Plot Settings';
dims = [1 35];
definput = {'1', '2'};
define_dlg = inputdlg(prompt,dlgtitle,dims,definput);
select_channels = str2double(char(define_dlg(1))); 
scale = str2double(char(define_dlg(2)));


EEG = S(1).EEG;
%% Define channels for ROI

num_rois = length(unique(egi_clusters(:,2)))-1;

baseData =[];
for cond_i = 1:length(S)
    
    switch select_channels
        case 1
            cur_chans = egi_clusters(:,1);
        case 2
            cur_chans = find(egi_clusters(:,2)~=0);
    end
        
    % select channels of interest        
    roi_chans = S(cond_i).EEG.data(cur_chans,:,:);
    % averaged timeseries of channels
    avg_chans = squeeze(nanmean(roi_chans,1));
    % fill missing value
    fill_dat = fillmissing(avg_chans,'linear',2, 'EndValues','nearest');

    if scale == 1 % raw
        scale_dat = fill_dat;
    elseif scale == 2 % dB
        scale_dat = real(10*(log10(fill_dat)));
    end

    baseData = cat(3, baseData, scale_dat); 
        
end

%% Hyponogram plot and dB power overnight
%  need to use dB scale

plot_hypon_multitaper(baseData,S(1).EEG)

