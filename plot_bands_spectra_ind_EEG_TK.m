function [outlier_tot] = plot_bands_spectra_ind_EEG_TK(EEG)


EEG.psdinterp.Bands.SWA     = find(EEG.psdinterp.Hzbins > 1  & EEG.psdinterp.Hzbins    <= 4.5);
EEG.psdinterp.Bands.Theta   = find(EEG.psdinterp.Hzbins > 4.5   & EEG.psdinterp.Hzbins    <= 8);
EEG.psdinterp.Bands.Alpha   = find(EEG.psdinterp.Hzbins > 8   & EEG.psdinterp.Hzbins    <= 12);
EEG.psdinterp.Bands.Sigma   = find(EEG.psdinterp.Hzbins > 12  & EEG.psdinterp.Hzbins    <= 15);
EEG.psdinterp.Bands.Beta    = find(EEG.psdinterp.Hzbins > 15  & EEG.psdinterp.Hzbins    <= 25);
EEG.psdinterp.Bands.Gamma   = find(EEG.psdinterp.Hzbins > 25  & EEG.psdinterp.Hzbins    <= 40);
%EEG.psdinterp.Bands.All     = find(EEG.psdinterp.Hzbins > 1   & EEG.psdinterp.Hzbins    <= 40);
Bands               = fieldnames(EEG.psdinterp.Bands);
numbands    = length(Bands);
%numchannels = size(EEG.psd.data,1);
numtrials   = size(EEG.psdinterp.data,4);


psdinterp_average = squeeze(nanmedian(EEG.psdinterp.data,3)); % average across epochs

for n = 1:numtrials
topofig = figure('position',[20 50 500 150*numbands]);
subplot('position',[.1 .96 .8 .02])
%figlabel = strrep(EEG.setname,'_',' ');
figlabel = [EEG.setname,' ',EEG.stage_name];

text(.5,.5,figlabel,'FontSize',12,'fontweight','bold','horizontalalignment','center');
%text(.1,.5,['Trial ',num2str(n)],'FontSize',12,'fontweight','bold','horizontalalignment','center');
colormap(jet);
axis off
outlier_tot = [];

    for b=1:numbands
        figure(topofig);
        
        subplot('position',[.15 (1-.07)*(numbands-b)/numbands .7 (1-.07)/numbands]);
        data = squeeze(nanmean(psdinterp_average(:,EEG.psdinterp.Bands.(Bands{b}),n),2));
        % this determines outliers - could be put in as an input
        outlier = find(bsxfun(@gt, abs(bsxfun(@minus, data,mean(data))), 3*std(data)));
        
        topoplot(data,EEG.chanlocs,'shading','interp','style','map','maplimits',...
               'maxmin','whitebk','on','electrodes','on');

        
        electrodes.x=get(findobj(gca,'Marker','.'),'XData'); electrodes.y=get(findobj(gca,'Marker','.'),'YData'); electrodes.z=get(findobj(gca,'Marker','.'),'ZData');
        delete(findobj(gca,'Marker','.'));
        for oi = 1:length(outlier)
           outch = outlier(oi);
           text(electrodes.x(outch),electrodes.y(outch),EEG.chanlocs(outch).labels,'Fontsize',8);
        end
        set(gca,'Xlim',[-.55 .55]); set(gca,'Ylim',[-.59 .59]);
        text(-.8,0,(Bands{b}),'FontSize',18,'rotation',90,'HorizontalAlignment','center');
        h=colorbar;
        set(h,'position',[.68 (1-.05)*(numbands-b)/numbands .05 (1-.2)/numbands]);
        outlier_tot = unique([outlier_tot;outlier]);  
    end
    
    set(topofig,'color','w','paperpositionmode','auto'); 
    print(topofig,'-dpng','-r500',[EEG.filepath,filesep,EEG.setname,EEG.stage_name,'_all_channels_topo.png']);
    
   
    %psdinterp_average_fb = psdinterp_average(:,EEG.psdinterp.Bands.(Bands{b}),n);
    
    %startpoint = EEG.psdinterp.Bands.(Bands{b})(1);
    %endpoint = EEG.psdinterp.Bands.(Bands{b})(end);
    globalspectralfig = figure('position',[550 200 550 900]);
    %h=semilogy(EEG.psdinterp.Hzbins(startpoint:endpoint),psdinterp_average_fb);
    h=semilogy(EEG.psdinterp.Hzbins,psdinterp_average);
    
    title([EEG.setname,' ',EEG.stage_name],'FontSize',24,'fontweight','bold','horizontalalignment','center');
    colormap(jet);
    xlim([0 EEG.psdinterp.Hzbins(end)]);
    xlabel('Frequency (Hz)', 'FontSize',12);
    ylabel('EEG Spectral Power (uV^2/Hz)', 'FontSize',12)
    
     % label all channel numbers
%    for c = 1:EEG.nbchan
%         figure(globalspectralfig);
%         hold on;
%         text(double(EEG.psdinterp.Hzbins(end)),double(psdinterp_average(c,end)),EEG.chanlocs(c).labels);      
%         xlim([0 EEG.psdinterp.Hzbins(end)+5]);
%     end
    
    for oi = 1:length(outlier_tot)
            outch = outlier_tot(oi);
            set(h(outch),'linewidth',3)
    end
    
     set(globalspectralfig,'color','w','paperpositionmode','auto')
     print(globalspectralfig,'-dpng','-r500',[EEG.filepath,filesep,EEG.setname,EEG.stage_name,'_all_channels.png']);
     savefig(globalspectralfig, [EEG.filepath,filesep,EEG.setname,EEG.stage_name,'_all_channels.fig']);

end
  
