function plot_power_stages_pval_ind(baseData,trtData, baseEEG, trtEEG, kdt, channels_label)


if kdt == 1
    out_name = 'KDT';
    stages = [1,0,3];
    stage_names ={'eyes_open','eyes_closed','overall'};

elseif kdt == 0
    out_name = 'PSG';
    stages = [0,1,2,3,4,5]; % treat 4 as S2+S3
    stage_names ={'Wake','S1','S2','S3','NREM(S2+S3)','REM'};

end


[m n roi_n] = size(baseData);
roi_names = {'Global area','Right temporal area', 'Frontal area', ...
    'Central area','Parietal area', 'Occipital area', 'Left temporal area'};

frequencies = baseEEG.Hzbins; 
num_frex = length(frequencies);


a = [];
for roi = 1: roi_n

fig = figure('Renderer', 'painters', 'Position', [20 50 1500 400]);
figlabel = strcat(baseEEG.subject,{', '},roi_names(roi));
%delete(a); %clear title to avoid overlap
a = annotation('textbox', [0 0.9 1 0.1], ...
    'String', figlabel, ...
    'EdgeColor', 'none', ...
    'fontweight','bold', ...
    'FontSize',12,...
    'HorizontalAlignment', 'center');


    for stage_i = 1:length(stages)
        
        if kdt == 1
            if stages(stage_i) == 3
                cur_stage = [find(baseEEG.sscore==1) find(baseEEG.sscore==0)];
                cur_stage2 = [find(trtEEG.sscore==1) find(trtEEG.sscore==0)];
                
            else
                cur_stage = find(baseEEG.sscore==stages(stage_i));
                cur_stage2 = find(trtEEG.sscore==stages(stage_i));
                
            end
            
        elseif kdt == 0
            
            if stages(stage_i) == 4
               % N2 + N3 
                 cur_stage = [find(baseEEG.sscore==2); find(baseEEG.sscore==3)];
                 cur_stage2 = [find(trtEEG.sscore==2); find(trtEEG.sscore==3)];             
            else
                cur_stage = find(baseEEG.sscore == stages(stage_i));
                cur_stage2 = find(trtEEG.sscore == stages(stage_i));
            end

            
        end
        

        % average power across epochs
        mean_pwr = squeeze(nanmean(baseData(:,cur_stage,roi),2));
        mean_pwr2 = squeeze(nanmean(trtData(:,cur_stage2,roi),2));
        subplot(2,6,stage_i)
        plot(mean_pwr,'LineWidth',2);
        hold on
        plot(mean_pwr2,'LineWidth',2);
        hold off

        xtickskip = 2:20:num_frex;
        set(gca,'xtick',xtickskip,'xticklabel',round(frequencies(xtickskip)))
        ax = gca;
        %ax.YAsix.Exponent = 0;
        ax.YScale = 'log';

        title([char(stage_names(stage_i)),' ','Stage'])
        xlabel('Frequency(Hz)'), ylabel('EEG spectral density (uV^2/Hz)')
        legend('cond1','cond2')
        
        
        p_values = zeros(num_frex,1);
        for freq_i = 1:num_frex
            base_stage  = baseData(:,cur_stage,1);
            trt_stage   = trtData(:,cur_stage2,1);
            bpt = size(base_stage,2);    
            tpt = size(trt_stage,2);
            
            if bpt>tpt
                [h,p,ci,stats] = ttest(log10(base_stage(freq_i,[1:tpt])), log10(trt_stage(freq_i,:)));             
            elseif bpt==tpt
                [h,p,ci,stats] = ttest(log10(base_stage(freq_i,:)), log10(trt_stage(freq_i,:)));
            elseif bpt<tpt
                [h,p,ci,stats] = ttest(log10(base_stage(freq_i,:)), log10(trt_stage(freq_i,[1:bpt])));
            end          
            p_values(freq_i) = -p; % for plot purpose   
        end
        
        
        subplot(2,6,stage_i+6)
        h = area(p_values,-0.1);
        h.FaceColor = [0.85 0.85 0.85]; % grey color
        axis([0 num_frex -0.1 0])
        hold on;
        plot([0 num_frex], [-0.05 -0.05], '-.b'); 
        set(gca,'xtick',xtickskip,'xticklabel',round(frequencies(xtickskip)))
        %set(gca,'yticklabel',[])
        yticks([-0.1 -0.05 0])
        yticklabels({'0.1','0.05','0.00'})
 
        text(130,-0.045, 'p<0.05')
        xlabel('Frequency(Hz)'), ylabel('p value')
        hold off;   
%         
       
        
    end
    % export figure
    set(fig,'color','w','paperpositionmode','auto');
    print(fig,'-dpng','-r500',[baseEEG.filepath,baseEEG.subject,'_',out_name,'_CompareSPower_', channels_label, '.png']);
    %close Figure 1

 
end