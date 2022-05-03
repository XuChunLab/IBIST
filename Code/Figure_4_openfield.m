%% openfield_N_C (animals in tTAN+tTAC group)
% Reproduce the analyzed results of Ca2+ signals and speed
% clear,clc; % uncomment this line if you meet errors

%% (1) load the data
load('openfield.mat');
avi_filename=arena.avi_filename;

%% (2) compare behavioral acitivity in the centers vs. surroundings.
% standard center, samller one, and surroudings
% process/filer behavior coordinates
[stampCenter, stampCenterSmall, stampCenterBig, stampSurround] = deal(  cell( size( avi_filename)) );
% ratioCenter: the percent of time spent in the center
ratioCenter = deal( stampCenter);
for n=1:length(avi_filename)
    dataX=behavdata{n}.x;
    dataY=behavdata{n}.y;
    IdxCenter = find( dataX > arena.center{n}(1) & dataX < ( arena.center{n}(1)+arena.center{n}(3)) & ...
        dataY > arena.center{n}(2) & dataY < ( arena.center{n}(2)+arena.center{n}(4)) ); 
    IdxCenterSmall = find( dataX > arena.center{n}(1)+arena.center{n}(3)*0.25 & dataX < arena.center{n}(1)+arena.center{n}(3)*0.75 & ...
        dataY > arena.center{n}(2)+arena.center{n}(4)*0.25 & dataY < arena.center{n}(2)+arena.center{n}(4)*0.75 ); 
    IdxCenterBig = find( dataX > arena.center{n}(1)-arena.center{n}(3)*0.25 & dataX < arena.center{n}(1)+arena.center{n}(3)*1.25 & ...
        dataY > arena.center{n}(2)-arena.center{n}(4)*0.25 & dataY < arena.center{n}(2)+arena.center{n}(4)*1.25 );     
    IdxSurround = 1:length(dataX);
    IdxSurround( [IdxCenter; IdxCenterSmall; IdxCenterBig]) = []; % exlcude the center.    
    stampCenter{n}=IdxCenter;            
    stampCenterSmall{n}=IdxCenterSmall;    
    stampCenterBig{n}=IdxCenterBig;    
    stampSurround{n}=IdxSurround;     
    ratioCenter{n} = numel(IdxCenter)/numel(dataX);
end

% show the ROI
figure;
for n=1:length(avi_filename)
    subplot(3,ceil( length(avi_filename)/3),n)
    hold on
    %xData = behavdata{n}.x; yData=behavdata{n}.y;
    %plot(xData,yData);     
    xData= behavdata{n}.x(stampSurround{n}); yData=behavdata{n}.y(stampSurround{n});
    plot(xData,yData);         
    xData= behavdata{n}.x(stampCenterBig{n}); yData=behavdata{n}.y(stampCenterBig{n});
    plot(xData,yData,'-k');     
    xData= behavdata{n}.x(stampCenter{n}); yData=behavdata{n}.y(stampCenter{n});    
    plot(xData,yData,'-r'); 
    xData= behavdata{n}.x(stampCenterSmall{n}); yData=behavdata{n}.y(stampCenterSmall{n});
    plot(xData,yData,'-g'); 
    % xlim([0 640]);  ylim([0 480])
    axis equal;
    axis tight;
end

% compute and show the time spent in the center
figure('position',[100,150, 300,400]);

y=cell2mat( ratioCenter);
x=ones(size(y));
scatter(x,y);  % center
hold on
bar(1,mean(y), 0.4, 'facecolor', 'none');
scatter(x*2, 1-y);  % surrouding 
bar(2,mean(1-y), 0.4, 'facecolor', 'none');
title('Open field test')
ylabel('Time in the center (%)')
ylim([0 1])
yticks([0: 0.1: 1]);
yticklabels({'0'; repmat(' ',4,1);'0.5'; repmat(' ',4,1);'1'});
xlim([0.5 2.5])
xticks([1 2])
xticklabels({'Center', 'Surr.'});
ax=gca;
ax.FontSize = 18;

%% (3) find the timestamps animal entering the center, require (2)
% return the Ca2+ data and behavioral tracks enterin the center.

dur = 90; % duration for Pre and Post entry/exit, 3 sec
thr=60; % threshold for continous length in center 
thr_maxmindiff = 50; % threshold to exclude the abnormal trials with too big max-min difference
[data_matrix_entry_cell, data_matrix_exit_cell, pos_matrix_entry_cell, speed_matrix_entry_cell, ...
    pos_matrix_exit_cell, speed_matrix_exit_cell ] = deal( cell( size( avi_filename)));
for n=1:length(avi_filename)% [1:6, 8:9] % 1:length(avi_filename) % exlcude 7
    data = dff{n}; % Ca2+ data
    pos = behavdata{n}; % Behavior tracking position
    stamp=stampCenter{n}; % stamps in the center.     
    stamp3=stamp(  [true; diff(stamp)>1]);   % select multiple entry trials by picking up stamps that are not continous,      
    [data_entry_cell, data_exit_cell, pos_entry_cell,speed_entry_cell, ...
        pos_exit_cell,speed_exit_cell]=deal(cell(size(stamp3))); % data for <entry> and <exit> trials
    % //////// Entry Trials ////////////   
    [bPreInside, bPostInside]=deal(false(size(stamp3))); % whether this part pre or post timestamp is inside the center
    for i = 2 : length(stamp3) % skip first trial to avoid pre-part has too few data points
        if stamp3(i)<thr || (stamp3(i)+thr)>length(pos.x); continue; end        
        x1=pos.x(stamp3(i) + (1-thr:-1));  % pre-part 
        x2=pos.x(stamp3(i) + (1:thr-1)); % post-part 
        y1=pos.y(stamp3(i) + (1-thr:-1)); % pre-part 
        y2=pos.y(stamp3(i) + (1:thr-1)); % post-part 
        % decide whether these beahvior tracks are inside the center
        bPreInside=ismember(round(x1), arena.center{n}(1)+(1:arena.center{n}(3))) & ismember(round(y1), arena.center{n}(2)+(1:arena.center{n}(4))) ;
        bPostInside=ismember(round(x2), arena.center{n}(1)+(1:arena.center{n}(3))) & ismember(round(y2), arena.center{n}(2)+(1:arena.center{n}(4))) ;
        % only consider the trials with enough data points for Pre and Post
        if all(~bPreInside) && all(bPostInside)  % entry trials 
            data_entry_cell{i}=data(stamp3(i)+(-dur:dur));             
            % do the speed calculation 
            idx=stamp3(i)+(-dur:dur);
            pos_entry_cell{i}=[ pos.x(idx), pos.y(idx)];
            speed_entry_cell{i}=CalSpeed(pos_entry_cell{i}(:,1),pos_entry_cell{i}(:,2));
        end 
    end
    % //////// EXIT Trials ////////////
    stamp3=stamp(  [diff(stamp)>1; true]);   % select multiple exit trials by picking up stamps that are not continous,     
    for i = 2 : length(stamp3) % skip first trial to avoid pre-part has too few data points
        if stamp3(i)<thr || (stamp3(i)+thr)>length(pos.x); continue; end        
        x1=pos.x(stamp3(i) + (1-thr:-1));  % pre-part 
        x2=pos.x(stamp3(i) + (1:thr-1)); % post-part 
        y1=pos.y(stamp3(i) + (1-thr:-1)); % pre-part 
        y2=pos.y(stamp3(i) + (1:thr-1)); % post-part 
        % decide whether these beahvior tracks are inside the center
        bPreInside=ismember(round(x1), arena.center{n}(1)+(1:arena.center{n}(3))) & ismember(round(y1), arena.center{n}(2)+(1:arena.center{n}(4))) ;
        bPostInside=ismember(round(x2), arena.center{n}(1)+(1:arena.center{n}(3))) & ismember(round(y2), arena.center{n}(2)+(1:arena.center{n}(4))) ;
        % only consider the trials with enough data points for Pre and Post
        if all(bPreInside) && all(~bPostInside) % exit trials      
            data_exit_cell{i}=data(stamp3(i)+(-dur:dur)); 
            % do the speed calculation 
            idx=stamp3(i)+(-dur:dur);
            pos_exit_cell{i}=[ pos.x(idx), pos.y(idx)];
            speed_exit_cell{i}=CalSpeed(pos_exit_cell{i}(:,1),pos_exit_cell{i}(:,2));            
        end 
    end     
    
    data_entry_cell( cellfun(@isempty, data_entry_cell)) = []; % remove empty cell
    data_exit_cell( cellfun(@isempty, data_exit_cell)) = []; % remove empty cell
    pos_entry_cell( cellfun(@isempty, pos_entry_cell)) = [];
    speed_entry_cell( cellfun(@isempty, speed_entry_cell)) = [];
    pos_exit_cell( cellfun(@isempty, pos_exit_cell)) = [];
    speed_exit_cell( cellfun(@isempty, speed_exit_cell)) = [];
    
    data_matrix_entry_cell{n} = data_entry_cell;
    data_matrix_exit_cell{n} = data_exit_cell;
    pos_matrix_entry_cell{n}=pos_entry_cell;
    speed_matrix_entry_cell{n} = speed_entry_cell; 
    pos_matrix_exit_cell{n}=pos_exit_cell;
    speed_matrix_exit_cell{n} = speed_exit_cell;     
end

%% (4) retrieve data for center entry/exit ,  require (1),(2),(3).   
% require<thr><dur><data_matrix_entry_cell><speed_matrix_entry_cell>
% <data_matrix_exit_cell><speed_matrix_exit_cell>

%======== ENTRY ==========
[ymean_cell, yspeed_mean_cell] = deal( cell( size(avi_filename)));
for n= 1:length(avi_filename)
    data_entry_cell = data_matrix_entry_cell{n};    
    if isempty(data_entry_cell); continue; end
    data_matrix=cell2mat( data_entry_cell'); %[data points, ntrials]         
    data_pre=mean( data_matrix(1:dur,:), 1); % compute mean of <pre_entry> in each trial    
    data_matrix = data_matrix./data_pre - 1; % normalized by <pre_entry> for each trial        
    trial2remove=find( max(data_matrix(1:dur,:),[],1)-min(data_matrix(1:dur,:),[],1)>thr_maxmindiff); % exclude the trial if the trace is too variable % most are below 3
    data_matrix(:,trial2remove)=[]; % remove the trial accordingly    
    data_post_entry=mean( data_matrix(1+dur:dur+dur,:), 1); % compute mean of <post_entry> in each trial after normalization  
    
    speed_entry_cell=speed_matrix_entry_cell{n};
    if isempty(speed_entry_cell); continue; end
    speed_matrix=cell2mat( speed_entry_cell');
    speed_pre=mean( speed_matrix(1:dur,:), 1); % compute mean 
    speed_matrix = speed_matrix./speed_pre - 1; % normalized for each trial    
        
    ymean_cell{n}=mean(data_matrix,2);    
    yspeed_mean_cell{n}=mean(speed_matrix,2);    
end
ymean_entry_cell = ymean_cell;
yspeed_mean_entry_cell = yspeed_mean_cell;

%======== EXIT ==========
[ymean_cell, yspeed_mean_cell] = deal( cell( size(avi_filename)));
for n= 1:length(avi_filename)
    data_entry_cell = data_matrix_exit_cell{n};    
    if isempty(data_entry_cell); continue; end
    data_matrix=cell2mat( data_entry_cell'); %[data points, ntrials]         
    data_pre=mean( data_matrix(1:dur,:), 1); % compute mean of <pre_entry> in each trial    
    data_matrix = data_matrix./data_pre - 1; % normalized by <pre_entry> for each trial        
    trial2remove=find( max(data_matrix(1:dur,:),[],1)-min(data_matrix(1:dur,:),[],1)>thr_maxmindiff); % exclude the trial if the trace is too variable % most are below 3
    data_matrix(:,trial2remove)=[]; % remove the trial accordingly    
    data_post_entry=mean( data_matrix(1+dur:dur+dur,:), 1); % compute mean of <post_entry> in each trial after normalization  
    
    speed_entry_cell=speed_matrix_exit_cell{n};
    if isempty(speed_entry_cell); continue; end
    speed_matrix=cell2mat( speed_entry_cell');
    speed_pre=mean( speed_matrix(1:dur,:), 1); % compute mean 
    speed_matrix = speed_matrix./speed_pre - 1; % normalized for each trial    
        
    ymean_cell{n}=mean(data_matrix,2);    
    yspeed_mean_cell{n}=mean(speed_matrix,2);    
end
ymean_exit_cell = ymean_cell;
yspeed_mean_exit_cell = yspeed_mean_cell;

%% plot the Ca2+ traces and speed 
% ==== plot the avearged Ca2+ traces, select animals ====
figure; hold on
title('Ca activity upon center entry/exit (N+C)')
n=1:4; % select animals
% Ca2+ data for exit
y = cell2mat( ymean_exit_cell(n)');
ydata=mean(y,2);
sem=std(y,0,2)./sqrt(size(y,2));
xdata=(-dur:dur)/30; % sec
shadedErrorBar(xdata,ydata,sem,'lineprops','-b','transparent',1);
% Ca2+ data for entry
y = cell2mat( ymean_entry_cell(n)');
ydata=mean(y,2);
sem=std(y,0,2)./sqrt(size(y,2));
xdata=(-dur:dur)/30; % sec
shadedErrorBar(xdata,ydata,sem,'lineprops','-r','transparent',1);

xlabel( 'Center Entry (s)');
ylabel('Activity (dF/F)');
ylim([-1,4]); % set ylim
xlim([-2 3]);
yline(0,'--');
xline(0,'--');
legend('Exit','Entry','Location','northwest')

% === plot the averaged Speed, select animals ====
figure; hold on
title('Animal speed upon center entry/exit (N+C)')
% Speed data, exit
y = cell2mat( yspeed_mean_exit_cell(n)');
ydata=mean(y,2);
sem=std(y,0,2)./sqrt(size(y,2));
xdata=(-dur:dur)/30; % sec
shadedErrorBar(xdata,ydata,sem,'lineprops','-b','transparent',1);

% Speed data, entry
y = cell2mat( yspeed_mean_entry_cell(n)');
ydata=mean(y,2);
sem=std(y,0,2)./sqrt(size(y,2));
xdata=(-dur:dur)/30; % sec
shadedErrorBar(xdata,ydata,sem,'lineprops','-r','transparent',1);

ylabel('Speed (a.u)', 'color', 'k');
xlim([-2 3]);
yline(0,'--');
xline(0,'--');
legend('Exit','Entry','Location','northwest')

%%
disp('Done');



