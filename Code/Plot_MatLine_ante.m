function [hFig, hFig2, hAxes]= Plot_MatLine_ante( TraceMat,marks,FrameRate )
% AIM: show the line with s.e.m. for a matrix of Ca2+ traces
%
% INPUTS:
% TraceMat - matrix to show. If it is a cell array, then show all of them
% in subplots in the same figure. 
% marks - specify the frames to mark/highlight
% FrameRate - to convert to 'sec' on the xlabels
%
% OUTPUTS:
% hFig, hAxes - mean and SEM
% hFig2 - individual lines
%
%
% Chun Xu, July 05, 2016
%
% Examples
%
% AverageEvent_nor_mean = nanmean(AverageEvent_nor,1);
% AverageEvent_nor_sem = nanstd(AverageEvent_nor,1)/sqrt(nStamps);
% 
% EventTrace.TraceMatrixEvent = TraceMatrixEvent;
% EventTrace.TraceMatrixEvent_nor = TraceMatrixEvent_nor;
% EventTrace.AverageEvent_nor_mean = AverageEvent_nor_mean;
% EventTrace.AverageEvent_nor_sem = AverageEvent_nor_sem;
%  
% % plot the lines
% [hFigs(numel(hFigs)+1), ~] = Plot_MatLine( AverageEvent_nor, eventwindow, otherinputs.FrameRate);
% set(gcf, 'name', ['Avearge All Event - dFoF_' eventname ]);
% currentDir = cd; cd(otherinputs.savedir);
% saveas(gcf,['Line-Avearge All Event - dFoF_' eventname '.fig']);
% saveas(gcf,['Line-Avearge All Event - dFoF_' eventname '.png']); 
% cd(currentDir);


% plot the figure
%% 
if iscell(TraceMat)
hFig = figure;
num = numel(TraceMat);
if num <=4; col = 2; else col = 3; end;
row = ceil( num/col);

% % plot in subplot
for i = 1 : num
    subplot(row,col,i)
    
    aver = mean(TraceMat{i},1);
    sem = std(TraceMat{i},1)/sqrt(size(TraceMat{i},1));
    myeb(aver,sem);
    hAxes = gca;
    set(hAxes, 'xtick',[marks(1) marks(end)]);
    set(hAxes, 'xticklabel',{'0', num2str(ceil(length(marks)/FrameRate))});
end

else
%%  average files  
hFig = figure;
aver = mean(TraceMat,1);
sem = std(TraceMat,1)/sqrt(size(TraceMat,1));
myeb(aver,sem);
hAxes = gca;
set(hAxes, 'xtick',[marks(1) marks(end)]);
set(hAxes, 'xticklabel',{'0', num2str(ceil(length(marks)/FrameRate))});
set(hAxes, 'YLim',[-0.06 0.18]); % set scale
xlabel('time (sec)')
ylabel('dF/F')
title('PeriStimulus dF/F  ')    

%% multiple lines 
hFig2 = figure; hold on;
plot((TraceMat'), 'color', [0.5 0.5 0.5]);
plot(mean(TraceMat,1), '.-','color','red','linewidth',1);
hAxes2 = gca;
set(hAxes2, 'xtick',[marks(1) ceil((marks(end)-marks(1))*0.5+marks(1)) marks(end)]);
set(hAxes2, 'xticklabel',{'0','', num2str(ceil(length(marks)/FrameRate))});
set(hAxes2, 'YLim',[-0.06 0.18]);  % set scale
xlabel('time (sec)')
ylabel('dF/F')
title('PeriStimulus dF/F, multiple lines ');
hold off;


end

end

