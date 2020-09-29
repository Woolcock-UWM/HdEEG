function plot_hypon_multitaper(dbData, EEG)


[m n s] = size(dbData);
epoch = 1:n;
frequencies = EEG.Hzbins; 
num_frex = length(frequencies);
%num_frex = 40;
ytickskip = 2:20:num_frex;
xtickskip = 0:120:length(epoch)-1; %every hour from 00:00




figset = figure('position',[20 50 1000 400]);


% initialize output Hyponogram data
Hypo_scores = zeros(length(EEG.sscore),1);

for k = 1:length(EEG.sscore)
    if EEG.sscore(k) == 0 % Wake
        Hypo_scores(k)=5;
    elseif EEG.sscore(k) == 5 %REM
         Hypo_scores(k)=4;
    elseif EEG.sscore(k) == 1 %S1
         Hypo_scores(k)=3;
    elseif EEG.sscore(k) == 2 %S2
        Hypo_scores(k)=2;
    elseif EEG.sscore(k) == 3 %S3
        Hypo_scores(k)=1;
    end
end


% plot
figure(figset)

figlabel = [EEG.subject,' ',EEG.condition];

%sgtitle('')
colormap(jet)
ax1 = subplot(211);
plot(epoch,Hypo_scores, 'LineWidth',2, 'Color','k');
yticks([1,2,3,4,5])
yticklabels({'N3', 'N2','N1','REM','Wake'})
%xlim([0 1050]) for 08 subject
set(gca, 'xtick', xtickskip, 'xticklabel', ...
    cellstr(num2str(mod(round(xtickskip .' ./120),24) ) ) )

title({figlabel;'Hypnogram'}, 'fontsize',13)
xlabel('Hour')  

% plot dB-converted power
ax2 = subplot(212);
imagesc(epoch,[],squeeze(dbData(:,:,1)));

set(gca,'ytick',ytickskip,'yticklabel',round(frequencies(ytickskip)),...
    'ydir','normal','clim',[-20 10])
set(gca, 'xtick', xtickskip, 'xticklabel', ...
    cellstr(num2str(mod(round(xtickskip .' ./120),24) ) ) )

title('Multitaper Spectrogram')% across 164 good channels')
xlabel('Hour'), ylabel('Frequency(Hz)')


linkaxes([ax1,ax2],'x')


c = colorbar;
c.Position = [0.91 0.35 0.02 0.1]; 
c.Label.String = 'dB power';

% export figure
set(figset,'color','w','paperpositionmode','auto');
print(figset,'-dpng','-r500',[EEG.filepath,filesep,EEG.subject,EEG.condition,'_multitaper.png']);




