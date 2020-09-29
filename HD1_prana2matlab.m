%% HD1_prana2matlab.m
%  By: Tancy Kao, 2019

% Summary: Loads sleep scoring as well as spectral power data from files
% produced by PRANA (e.g., *.hpn and *.spc files) to MAT-files
% that contain all the above data, in a Matlab friendly format.

% Input: .hpn and .spc files for a single subject 
%
% Output: .mat files


clc
close all hidden
clear

warning('off','all')
disp('Select the folder where the analysis scripts reside.');
folder = uigetdir;
scripts_folder = fullfile(folder);
clc


fprintf('Select the folder containing the PSG or KDT data you want to analyse.');
folder = uigetdir;
fullFileName_bl = fullfile(folder);
clc
if sum(fullFileName_bl) ~= 0
    base_files = dir([fullFileName_bl,filesep,'**/*.spc']);
    fprintf('Select the hyn file');
    [hpnfile_bl,hpnpath_bl] = uigetfile('*.hpn');
    hpndata_bl = [hpnpath_bl,hpnfile_bl];
    clc
end

fprintf("Select the folder in which you want to create the 'HD1 Output files' folder, e.g. a folder named with the subject ID \n");
folder = uigetdir;
outputFileName = fullfile(folder);
clc

prompt = {'Is this PSG or KDT data? (0 = PSG, 1 = KDT)','Frequency resolution of spectral analysis:', 'End frequency:'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'0','0.25','44.75'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
kdt = str2num(char(answer(1)));
freq_resolution = str2num(char(answer(2)));
freq_end = str2num(char(answer(3)));

if kdt == 1
    TaskTypes= char('KDT');
elseif kdt == 0
    TaskTypes = char('PSG');
end 


%%
tic
disp ('THIS PROGRAM MAY TAKE A WHILE TO COMPLETE... PLEASE BE PATIENT.');

addpath(scripts_folder);
load label_list
freq = (0:freq_resolution:freq_end);

%%
if sum(fullFileName_bl) ~= 0
    for k = 1:length(base_files)
        channel_name = extractBefore(base_files(k).name,'.');

        [data1, sscore1] = func_power_compile2(k, base_files, hpndata_bl, channel_name, label_list);
        if ~isempty(data1)
            power1.(channel_name)= data1;
        end

    end
end

%% define KDT sscore
if kdt == 1
    sscore1 = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0]; % 1: eyes open, 0: eyes close
    sscore2 = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0]; 
end
%% export data and score to matfile

cd (outputFileName)
if exist ('HD1 Output files', 'dir')  ~= 7
    mkdir('HD1 Output files');
    
end

cd ([outputFileName, filesep, 'HD1 Output files', filesep])

if  sum(fullFileName_bl) ~= 0 
    
    newStr = split((base_files(1).folder),filesep);
    fname = strcat(char(newStr(end-2)), '_', char(newStr(end-1)),'_',TaskTypes);
    folder1 = base_files(1).folder;

    save(fname, 'power1', 'sscore1', 'folder1')
    cd ..
    msgbox ('DONE! - All PRANA result files were imported into MATLAB. Please check the folder "Output files" for the .mat file.');

end
toc
