%Plotting tool which uses exportet variables from the gueeg program.
% It can plot single subjects or make an overlay of single subjects in a selected plotlayout.
% black and white version

% answer = inputdlg({'Single subject overlay-plot: which dataset?', 'Which channels?','Plotlayout?', 'Epochsize?', 'y-axis limits', 'x-axis limits','How many subjects/which subject?', 'Axis on or off'}, ...
%     'Please define:', 1, {'GAMV_', '[1 2 3 4 5 6 7 8 9 10]', '[5 2]', '[-1024 1022]','[-9 15]', '[-1000 1000]', '[1:10]', 'axis on'}); 

answer = inputdlg({'Single subject overlay-plot: which dataset?', 'Which channels?','Plotlayout?', 'Epochsize?', 'y-axis limits', 'x-axis limits','x-ticks?','How many subjects/which subject?', 'Axis on or off'}, ...
    'Please define:', 1, {'GAMV_boyfr_reg_05to4hz_n20', '[1 2 12 13 6 7 4 5 14 15 8 9]', '[6 2]', '[-1024 1022]', ...
        '[-9 15]', '[-1000 1000]', '[0 300 600 900]','[1:20]', 'axis on'}); 

data = char(answer(1,1)); chan = str2num(char(answer(2,1))); 
plotlayout = str2num(char(answer(3,1))); time = str2num(char(answer(4,1))); 
y = str2num(char(answer(5,1))); x = str2num(char(answer(6,1))); 
x_tick=str2num(char(answer(7,1)));
subj = str2num(char(answer(8,1)));
channelnames = eval(char([data, '_p','.text_channel(chan,:)']));
axis_on=char(answer(9,1));
data = eval(data);

figure
    for i = 1:size(chan,2); % Anzahl Plots (Kanaele)
        subplot(plotlayout(1,1),plotlayout(1,2),i); plot(linspace(time(1,1),time(1,2),size(data,2)), squeeze(data(chan(i),:,subj)),'k');
        set(gca, 'ydir', 'reverse','color','none','xtick', x_tick); xlim([x(1) x(2)]); ylim([y(1) y(2)]); y = get(gca, 'ylim');  x = get(gca, 'xlim');
        line([0 0], [y(1) y(2)], 'color', 'k'); text(x(1)+100, y(1), channelnames(i,1:7)); box off; 
        line([100 100], [y(1) y(2)], 'color', [0.5 0.5 0.5], 'linestyle', '--');
        line([300 300], [y(1) y(2)], 'color', [0.5 0.5 0.5], 'linestyle', '--');
        line([600 600], [y(1) y(2)], 'color', [0.5 0.5 0.5], 'linestyle', '--');
        hold on
        if i == 1
            title([strrep(char(answer(1,1)),'_', ' '), ' single subject overlay-plot']);
        end
        if i ==size(chan,2)
            axis on
        end
    end; 
files = char(['p_',char(answer(1,1)),'.filename(subj)']);
set(gcf, 'PaperType', 'A4', 'PaperPosition', [0.63 0.63 19.72 28.41], 'PaperOrientation', 'Portrait');

%legend(eval(files)) 
saveas(gcf, char(answer(1,1)), 'fig'); 

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% answer = inputdlg({'Single subject overlay-plot: which dataset?', 'Which channels?','Plotlayout?', 'Epochsize?', 'y-axis limits', 'x-axis limits','x-ticks?','How many subjects/which subject?', 'Axis on or off'}, ...
%     'Please define:', 1, {'GAMV_friend_reg_05to4hz_n20', '[1 2 12 13 6 7 4 5 14 15 8 9]', '[6 2]', '[-1024 1022]', ...
%         '[-9 15]', '[-1000 1000]', '[0 300 600 900]','[1:20]', 'axis on'}); 
% 
% data = char(answer(1,1)); chan = str2num(char(answer(2,1))); 
% plotlayout = str2num(char(answer(3,1))); time = str2num(char(answer(4,1))); 
% y = str2num(char(answer(5,1))); x = str2num(char(answer(6,1))); 
% x_tick=str2num(char(answer(7,1)));
% subj = str2num(char(answer(8,1)));
% channelnames = eval(char(['p_',data, '.text_channel(chan,:)']));
% axis_on=char(answer(9,1));
% data = eval(data);
% 
% figure
%     for i = 1:size(chan,2); % Anzahl Plots (Kanaele)
%         subplot(plotlayout(1,1),plotlayout(1,2),i); plot(linspace(time(1,1),time(1,2),size(data,2)), squeeze(data(subj,:,chan(i))),'k');
%         set(gca, 'ydir', 'reverse','color','none','xtick', x_tick); xlim([x(1) x(2)]); ylim([y(1) y(2)]); y = get(gca, 'ylim');  x = get(gca, 'xlim');
%         line([0 0], [y(1) y(2)], 'color', 'k'); text(x(1)+100, y(1), channelnames(i,1:7)); box off; 
%         line([100 100], [y(1) y(2)], 'color', [0.5 0.5 0.5], 'linestyle', '--');
%         line([300 300], [y(1) y(2)], 'color', [0.5 0.5 0.5], 'linestyle', '--');
%         line([600 600], [y(1) y(2)], 'color', [0.5 0.5 0.5], 'linestyle', '--');
%         hold on
%         if i == 1
%             title([strrep(char(answer(1,1)),'_', ' '), ' single subject overlay-plot']);
%         end
%         if i ==size(chan,2)
%             axis on
%         end
%     end; 
% files = char(['p_',char(answer(1,1)),'.filename(subj)']);
% set(gcf, 'PaperType', 'A4', 'PaperPosition', [0.63 0.63 19.72 28.41], 'PaperOrientation', 'Portrait');
% %legend(eval(files)) 
% 
% saveas(gcf, char(answer(1,1)), 'fig'); 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% answer = inputdlg({'Single subject overlay-plot: which dataset?', 'Which channels?','Plotlayout?', 'Epochsize?', 'y-axis limits', 'x-axis limits','x-ticks?','How many subjects/which subject?', 'Axis on or off'}, ...
%     'Please define:', 1, {'GAMV_unknown_reg_05to4hz_n20', '[1 2 12 13 6 7 4 5 14 15 8 9]', '[6 2]', '[-1024 1022]', ...
%         '[-9 15]', '[-1000 1000]', '[0 300 600 900]','[1:20]', 'axis on'}); 
% 
% data = char(answer(1,1)); chan = str2num(char(answer(2,1))); 
% plotlayout = str2num(char(answer(3,1))); time = str2num(char(answer(4,1))); 
% y = str2num(char(answer(5,1))); x = str2num(char(answer(6,1))); 
% x_tick=str2num(char(answer(7,1)));
% subj = str2num(char(answer(8,1)));
% channelnames = eval(char(['p_',data, '.text_channel(chan,:)']));
% axis_on=char(answer(9,1));
% data = eval(data);
% 
% figure
%     for i = 1:size(chan,2); % Anzahl Plots (Kanaele)
%         subplot(plotlayout(1,1),plotlayout(1,2),i); plot(linspace(time(1,1),time(1,2),size(data,2)), squeeze(data(subj,:,chan(i))),'k');
%         set(gca, 'ydir', 'reverse','color','none','xtick', x_tick); xlim([x(1) x(2)]); ylim([y(1) y(2)]); y = get(gca, 'ylim');  x = get(gca, 'xlim');
%         line([0 0], [y(1) y(2)], 'color', 'k'); text(x(1)+100, y(1), channelnames(i,1:7)); box off; 
%         line([100 100], [y(1) y(2)], 'color', [0.5 0.5 0.5], 'linestyle', '--');
%         line([300 300], [y(1) y(2)], 'color', [0.5 0.5 0.5], 'linestyle', '--');
%         line([600 600], [y(1) y(2)], 'color', [0.5 0.5 0.5], 'linestyle', '--');
%         hold on
%         if i == 1
%             title([strrep(char(answer(1,1)),'_', ' '), ' single subject overlay-plot']);
%         end
%         if i ==size(chan,2)
%             axis on
%         end
%     end; 
% files = char(['p_',char(answer(1,1)),'.filename(subj)']);
% set(gcf, 'PaperType', 'A4', 'PaperPosition', [0.63 0.63 19.72 28.41], 'PaperOrientation', 'Portrait');
% %legend(eval(files)) 
% saveas(gcf, char(answer(1,1)), 'fig'); 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% answer = inputdlg({'Single subject overlay-plot: which dataset?', 'Which channels?','Plotlayout?', 'Epochsize?', 'y-axis limits', 'x-axis limits','x-ticks?','How many subjects/which subject?', 'Axis on or off'}, ...
%     'Please define:', 1, {'GAMV_greysqu_reg_05to4hz_n20', '[1 2 12 13 6 7 4 5 14 15 8 9]', '[6 2]', '[-1024 1022]', ...
%         '[-9 15]', '[-1000 1000]', '[0 300 600 900]','[1:20]', 'axis on'}); 
% 
% data = char(answer(1,1)); chan = str2num(char(answer(2,1))); 
% plotlayout = str2num(char(answer(3,1))); time = str2num(char(answer(4,1))); 
% y = str2num(char(answer(5,1))); x = str2num(char(answer(6,1))); 
% x_tick=str2num(char(answer(7,1)));
% subj = str2num(char(answer(8,1)));
% channelnames = eval(char(['p_',data, '.text_channel(chan,:)']));
% axis_on=char(answer(9,1));
% data = eval(data);
% 
% figure
%     for i = 1:size(chan,2); % Anzahl Plots (Kanaele)
%         subplot(plotlayout(1,1),plotlayout(1,2),i); plot(linspace(time(1,1),time(1,2),size(data,2)), squeeze(data(subj,:,chan(i))),'k');
%         set(gca, 'ydir', 'reverse','color','none','xtick', x_tick); xlim([x(1) x(2)]); ylim([y(1) y(2)]); y = get(gca, 'ylim');  x = get(gca, 'xlim');
%         line([0 0], [y(1) y(2)], 'color', 'k'); text(x(1)+100, y(1), channelnames(i,1:7)); box off; 
%         line([100 100], [y(1) y(2)], 'color', [0.5 0.5 0.5], 'linestyle', '--');
%         line([300 300], [y(1) y(2)], 'color', [0.5 0.5 0.5], 'linestyle', '--');
%         line([600 600], [y(1) y(2)], 'color', [0.5 0.5 0.5], 'linestyle', '--');
%         hold on
%         if i == 1
%             title([strrep(char(answer(1,1)),'_', ' '), ' single subject overlay-plot']);
%         end
%         if i ==size(chan,2)
%             axis on
%         end
%     end; 
% files = char(['p_',char(answer(1,1)),'.filename(subj)']);
% set(gcf, 'PaperType', 'A4', 'PaperPosition', [0.63 0.63 19.72 28.41], 'PaperOrientation', 'Portrait');
% 
% %legend(eval(files)) 
% saveas(gcf, char(answer(1,1)), 'fig'); 
% close all