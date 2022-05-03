function [hFig, hAxes]= Plot_MatHeat_ante( TraceMat,marks,FrameRate )
% AIM: show the heat map for a matrix of Ca2+ traces
%
% INPUTS:
% TraceMat - matrix to show. If it is a cell array, then show all of them
% in subplots in the same figure. 
% marks - specify the frames to mark/highlight
% FrameRate - to convert to 'sec' on the xlabels
%
% OUTPUTS:
% hFig
% hAxes
%
% Chun Xu, July 05, 2016
%
% Examples
% 
% len1 = length( EventPreFramesArrays{1});
% len2 = EventSet1.postF(2) * otherinputs.FrameRate; % defined postF
% eventwindow = (len1+1) : 1 : (len1+len2);
% TraceMatSort = SortMatrix( AverageEvent_nor,'event', eventwindow);
% [hFigs(1), ~] = Plot_MatHeat( TraceMatSort, eventwindow, otherinputs.FrameRate);
% set(gcf, 'name', ['Avearge All Event - dFoF_' eventname ]);
% saveas(gcf,['Heatmap-Avearge All Event - dFoF_' eventname '.fig']);
% saveas(gcf,['Heatmap-Avearge All Event - dFoF_' eventname '.png']); 

% default
if nargin < 2; marks = [1 2]; end
if nargin < 3; FrameRate = 20; end
    
% customize colormap
[c1,~]=colorGradient(RGB('red'),RGB('darkred'),64*2); % red to black
[c2,~]=colorGradient(RGB('orange'),RGB('red'),64*0.5); % yellow to red
[c3,~]=colorGradient(RGB('white'), RGB('orange'),64*0.5); % blue to yellow
[c4,~]=colorGradient(RGB('blue'),RGB('white'),64); 
[c5,~]=colorGradient(RGB('midnightblue'),RGB('blue'),64*2); 
c = [c5;c4;c3;c2;c1];

% plot the figure
%% 
if iscell(TraceMat)
hFig = figure;
num = numel(TraceMat);
if num <=4; col = 2; else col = 3; end;
row = ceil( num/col);
% % find the cmax of whole array
cmax = zeros(num,1);
for i = 1 : num
cmax(i) = max(max(TraceMat{i}));
end
cmaxmax = max(cmax); 

% % plot in subplot
for i = 1 : num
    subplot(row,col,i)
    imagesc(TraceMat{i});
    colormap(c);  
    cmax = max(max(TraceMat{i}));
    caxis([-cmaxmax cmaxmax]); 
    % Alternative way, local <cmax> and show colorbar.
    caxis([-cmax cmax]); colorbar;
    hAxes = gca;
    set(hAxes, 'xtick',[marks(1) marks(end)]);
    set(hAxes, 'xticklabel',{'0', num2str(ceil(length(marks)/FrameRate))});
end

else
%%    
hFig = figure;
imagesc(TraceMat);
colormap(c); colorbar; 
cmax = max(max(TraceMat));
caxis([-0.15 0.15]); % set scale
hAxes = gca;
set(hAxes, 'xtick',[marks(1) marks(end)]);
set(hAxes, 'xticklabel',{'0', num2str(ceil(length(marks)/FrameRate))});
xlabel('Time (sec)')
ylabel('Trials')
title('PeriStimulus dF/F  ')    

end

end

