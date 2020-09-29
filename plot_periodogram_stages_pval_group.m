function plot_periodogram_stages_pval_group(EEG, stat_type, select_channels)



Cond1_name = EEG.cond1name;
Cond2_name = EEG.cond2name;
Cond1_gp = EEG.cond1data;
Cond2_gp = EEG.cond2data;
frequencies = EEG.freqs;
num_frex = length(EEG.freqs);
n_stage = length(EEG.stage_names);
stage_names = EEG.stage_names;
[~, ~, nsubj1] = size(Cond1_gp);
[~, ~, nsubj2] = size(Cond2_gp);


fig = figure('Renderer', 'painters', 'Position', [40 60 1500 400]);
figlabel = strcat([Cond1_name], {' '}, 'N=',num2str(nsubj1),{' '}, ...
    [Cond2_name], {' '}, 'N=',num2str(nsubj2));


a = annotation('textbox', [0 0.9 1 0.1], ...
    'String', figlabel, ...
    'EdgeColor', 'none', ...
    'fontweight','bold', ...
    'FontSize',12,...
    'HorizontalAlignment', 'center');

    for stage_i = 1:n_stage
        % average subjects 
        avg_subj_C1 = squeeze(nanmean(Cond1_gp(:,stage_i,:),3));
        avg_subj_C2 = squeeze(nanmean(Cond2_gp(:,stage_i,:),3));
        
        subplot(2,n_stage,stage_i)
        plot(avg_subj_C1,'LineWidth',2);
                
        hold on
        plot(avg_subj_C2,'LineWidth',2);

        hold off

        xtickskip = 2:20:num_frex;
        set(gca,'xtick',xtickskip,'xticklabel',round(frequencies(xtickskip)))

        ax = gca;
        ax.YScale = 'log';

        title([char(stage_names(stage_i))])
        xlabel('Frequency(Hz)'), ylabel('Spectral density')
        legend([Cond1_name],[Cond2_name])
        box off
        
        p_values = NaN(num_frex,1);
        for freq_i = 1:num_frex
             C1_stage  = squeeze(Cond1_gp(:,stage_i,:));
             C2_stage   = squeeze(Cond2_gp(:,stage_i,:));
            switch stat_type
                case 'pairT' % pair t test
                    if all(isnan(C1_stage(:))) || all(isnan(C2_stage(:)))
                        p_values(freq_i) = NaN;
                    else
                        [h,p,ci,stats] = ttest(C1_stage(freq_i,:),...  
                                               C2_stage(freq_i,:), 0.05);
                        p_values(freq_i) = -p;
                    end
                    
                case 'twosampleT' % two sample t test
                    [h,p,ci,stats] = ttest2(C1_stage(freq_i,:),...
                                            C2_stage(freq_i,:), 0.05);
                     p_values(freq_i) = -p;                             
            end
        end
        
        subplot(2,n_stage,stage_i+n_stage)
        h = area(p_values,-0.1);
        h.FaceColor = [0.85 0.85 0.85]; % grey color
        axis([0 num_frex -0.1 0])
        hold on;
        plot([0 num_frex], [-0.05 -0.05], '-.b'); 
        set(gca,'xtick',xtickskip,'xticklabel',round(frequencies(xtickskip)))
        %set(gca,'yticklabel',[])
        yticks([-0.1 -0.05 0])
        yticklabels({'0.1','0.05','0.00'})
        if all(isnan(p_values(:)))
           text(50,-0.045, 'Missing data to do statistic test', 'FontSize',12) 
        else
            text(130,-0.045, 'p<0.05')
    
        end
        xlabel('Frequency(Hz)'), ylabel('p value')
        box off
     
    end

   

% export figure
set(fig,'color','w','paperpositionmode','auto');
if select_channels == 1
    print(fig,'-dpng','-r300',[EEG.filepath, filesep, EEG.save_title,'_','all_channels_','periodogram.png'])
elseif select_channels == 2
    print(fig,'-dpng','-r300',[EEG.filepath,filesep, EEG.save_title,'_','defined_channels_','periodogram.png'])
end


