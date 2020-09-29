function plot_sleepcycle_topo_ind(BS_dat, EEG, norm_type, save_folder, channels_label)

EEG.Bands.SWA     = find(EEG.Hzbins > 1   & EEG.Hzbins <= 4.5);
EEG.Bands.Theta   = find(EEG.Hzbins > 4.5   & EEG.Hzbins  <= 8);
EEG.Bands.Alpha   = find(EEG.Hzbins > 8   & EEG.Hzbins    <= 12);
EEG.Bands.Sigma   = find(EEG.Hzbins > 12  & EEG.Hzbins    <= 15);
EEG.Bands.Beta    = find(EEG.Hzbins > 15  & EEG.Hzbins    <= 25);
EEG.Bands.Gamma   = find(EEG.Hzbins > 25  & EEG.Hzbins    <= 40);

Bands       = fieldnames(EEG.Bands);
numbands    = length(Bands);

topofig = figure('position',[20 50 500 150*numbands]);
%topofig = figure('position',[20 50 500 150]);
subplot('position',[.1 .96 .8 .02])


if strcmp(norm_type, 'raw') 
    save_name = 'topo_abs';
elseif strcmp(norm_type,'norm')
    save_name = 'topo_norm';

end

figlabel = [EEG.subject,' ',norm_type,' ', EEG.stage_name];

text(0.5,0.5,figlabel,'FontSize',12,'fontweight','bold','horizontalalignment','center');

colormap(jet);
axis off
i = 0;
for kfreq = 1 : numbands
    figure(topofig);
    switch norm_type 
        case 'norm'
            tmp_BS_avg = squeeze(nanmean(BS_dat(:,EEG.Bands.(Bands{kfreq}),:),2));         
            data = zscore(tmp_BS_avg,1);
        case 'raw'        
            data = squeeze(nanmean(BS_dat(:,EEG.Bands.(Bands{kfreq}),:),2));
    end
          


    subplot('position',[.15 (1-.07)*(numbands-kfreq)/numbands .7 (1-.07)/numbands]);

    topoplot(data,EEG.chanlocs,'shading','interp','style','map','maplimits',...
                                'maxmin','whitebk','on','electrodes','on','plotrad', 0.57);
    
  
     hh = colorbar;
    
    

    set(gca,'Xlim',[-.55 .55],'Ylim',[-.59 .59]);
    electrodes.x=get(findobj(gca,'Marker','.'),'XData'); % need to figure out how to get xyz
    electrodes.y=get(findobj(gca,'Marker','.'),'YData'); 
    electrodes.z=get(findobj(gca,'Marker','.'),'ZData');
    delete(findobj(gca,'Marker','.'));
    
    
    text(-.8,0,(Bands{kfreq}),'FontSize',18,'rotation',90,'HorizontalAlignment','center');
  
    set(hh,'position',[.68 (1-.05)*(numbands-kfreq)/numbands .05 (1-.2)/numbands]);

    
    %subplot('position',[.15 (1-.07)*(numbands-kfreq)/numbands .7 (1-.07)/numbands]);


end


set(topofig,'color','w','paperpositionmode','auto');
print(topofig,'-dpng','-r300',[save_folder, filesep, EEG.subject, char(EEG.stage_name),'_',channels_label,'_',save_name])

