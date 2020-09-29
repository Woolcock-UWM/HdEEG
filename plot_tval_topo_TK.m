function [TRT_norm_bands, BL_norm_bands, insidegoodch2] = plot_tval_topo_TK(TRT_dat,BS_dat, EEG, my_chans, norm_type, stat_type)


EEG.Bands.SWA     = find(EEG.Hzbins > 1   & EEG.Hzbins <= 4.5);
EEG.Bands.Theta   = find(EEG.Hzbins > 4.5   & EEG.Hzbins  <= 8);
EEG.Bands.Alpha   = find(EEG.Hzbins > 8   & EEG.Hzbins    <= 12);
EEG.Bands.Sigma   = find(EEG.Hzbins > 12  & EEG.Hzbins    <= 15);
EEG.Bands.Beta    = find(EEG.Hzbins > 15  & EEG.Hzbins    <= 25);
EEG.Bands.Gamma   = find(EEG.Hzbins > 25  & EEG.Hzbins    <= 40);

Bands       = fieldnames(EEG.Bands);
numbands    = length(Bands);

insidegoodch = find([EEG.chanlocs(1:256).radius]< 0.6 & ~strcmp({EEG.chanlocs(1:256).labels},'Cz'));
insidegoodch2 = intersect(insidegoodch,my_chans'); % return electrode labels


topofig = figure('position',[20 50 500 150*numbands]);
subplot('position',[.1 .96 .8 .02])


if strcmp(norm_type, 'raw') && strcmp(stat_type,'pairT')
    EEG.subject ='tval absolute map and significant channels (p<.05) '; 
    save_name = 'power_stat_topo_pairT_raw';

elseif strcmp(norm_type,'norm') && strcmp(stat_type,'pairT')
    EEG.subject ='tval normalized map and significant channels (p<.05)'; 
    save_name = 'power_stat_topo_pairT_norm';

elseif strcmp(norm_type,'raw') && strcmp(stat_type,'twosampleT')
    EEG.subject ='tval absolute map and significant channels (p<.05)'; 
    save_name = 'power_stat_topo_twosampleT_raw';

elseif strcmp(norm_type,'norm') && strcmp(stat_type,'twosampleT')
    EEG.subject ='tval normalized map and significant channels (p<.05) '; 
    save_name = 'power_stat_topo_twosampleT_norm';

end

figlabel = [EEG.subject,' ',EEG.stage_name];

text(.5,.5,figlabel,'FontSize',12,'fontweight','bold','horizontalalignment','center');
text(.9,-1,'warm color: cond1>cond2','FontSize',8,'horizontalalignment','right');

colormap(jet);
axis off
for kfreq = 1 : numbands

    
    switch norm_type 
        case 'norm'
            tmp_TRT_avg = squeeze(nanmean(TRT_dat(:,EEG.Bands.(Bands{kfreq}),:),2));
            tmp_BS_avg = squeeze(nanmean(BS_dat(:,EEG.Bands.(Bands{kfreq}),:),2));
            
            tmp_TRT_avg = bsxfun(@minus, tmp_TRT_avg,nanmean(tmp_TRT_avg,1));
            tmp_TRT_avg = bsxfun(@rdivide,tmp_TRT_avg,nanstd(tmp_TRT_avg,[],1));
            tmp_BS_avg = bsxfun(@minus, tmp_BS_avg,nanmean(tmp_BS_avg,1)); 
            tmp_BS_avg = bsxfun(@rdivide,tmp_BS_avg,nanstd(tmp_BS_avg,[],1));
            
            
            TRT_norm_bands(:,:,kfreq) = tmp_TRT_avg;
            BL_norm_bands(:,:,kfreq) = tmp_BS_avg;
            
        case 'raw'        
            tmp_TRT_avg = squeeze(nanmean(TRT_dat(:,EEG.Bands.(Bands{kfreq}),:),2));
            tmp_BS_avg = squeeze(nanmean(BS_dat(:,EEG.Bands.(Bands{kfreq}),:),2));
    end
          
            t_values = NaN(256,1);

    for ichan = 1:length(insidegoodch2)
        switch stat_type
            case 'pairT' % pair t test
                [hh(ichan), p(ichan), ci, stats] = ttest(tmp_TRT_avg(ichan,:),...
                                                  tmp_BS_avg(ichan,:), 0.05);
                t_values(insidegoodch2(ichan)) = stats.tstat;

            case 'twosampleT' % two sample t test
                [hh(ichan), p(ichan), ci, stats] = ttest2(tmp_TRT_avg(ichan,:),...
                                                  tmp_BS_avg(ichan,:), 0.05);
                t_values(insidegoodch2(ichan)) = stats.tstat;
        end
    end
    
    % significant channels
    sigch    = find(hh==1); % return electrode order
   
    figure(topofig);
    subplot('position',[.15 (1-.07)*(numbands-kfreq)/numbands .7 (1-.07)/numbands]);
       
    % plot t values and significant channels    
    topoplot(t_values,EEG.chanlocs,'headrad',0.57,'style','map','electrodes','on','maplimits','minmax','whitebk','on');
    
    caxis manual 
    caxis([-3 3]);
    
    %title(titletext);
    cbh = colorbar;
    cbh.TickLabels = [-3 3];
    set(gca,'Xlim',[-.55 .55],'Ylim',[-.59 .59]);
    electrodes.x=get(findobj(gca,'Marker','.'),'XData'); % need to figure out how to get xyz
    electrodes.y=get(findobj(gca,'Marker','.'),'YData'); 
    electrodes.z=get(findobj(gca,'Marker','.'),'ZData');
    delete(findobj(gca,'Marker','.'));
    


    % if you use inside good, be careful to pull correct indicies 
    if ~isequal(length(electrodes.x),length(insidegoodch2))
    disp('error with plotting sig channels');
    end

    %chi = intersect(insidegoodch2,sigch);
    chi = sigch; % electrode order
    if length(chi)>0
       hold on;
       h = scatter(electrodes.x(chi),electrodes.y(chi),electrodes.z(chi),...
                'filled','SizeData',20,'Cdata',[1 1 1],'MarkerEdgeColor',[0 0 0],'linewidth',.5);

    end
    
    text(-.8,0,(Bands{kfreq}),'FontSize',18,'rotation',90,'HorizontalAlignment','center');
    h=colorbar;

    set(h,'position',[.68 (1-.05)*(numbands-kfreq)/numbands .05 (1-.2)/numbands]);

    text(-.8,0,[(Bands{kfreq})],'FontSize',18,'rotation',90,'HorizontalAlignment','center');

    figure(topofig);
    subplot('position',[.15 (1-.07)*(numbands-kfreq)/numbands .7 (1-.07)/numbands]);

    clear hh p t_values       

end

   
set(topofig,'color','w','paperpositionmode','auto');
print(topofig,'-dpng','-r300',[EEG.filepath, filesep, EEG.save_title,'_',char(EEG.stage_name),'_',save_name])

