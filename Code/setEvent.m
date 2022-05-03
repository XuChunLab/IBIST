function [Event, EventST]= setEvent(type, TS, FrameRate)
% AIM: make customized event
%
% INPUTS: 
% type - e.g. CS10sec, CS30sec, US
% TS - timestamps for the event
% FrameRate
%
% OUTPUTS:
% Event: struct file
% FrameRate, FPS, - scalar 
% preF, preFshow, postF, postFshow, width 
% EventST: Combine the events and timestample 
%
% - Example for INPUTS. unit sec.
% CS_Stamps = [719.94085; 791.9354; 848.931125 ; 895.9276; 957.922825];
% US_Stamps = [729.9397;	801.93435;	858.92995;	905.926475;	967.921725];
% TS = [CS_Stamps US_Stamps];
%
% - Example for OUTPUTS. unit sec.
% Output-strcut-Event
% case 'US'
% preF=[0 20]; % period to calculate the baseline, absolute values
% preFshow=[0 30]; % period to show in the figure
% postF=[0 30]; % period to calculate the response
% postFshow=[0 40]; % period to show in the figure
% width=[0 30]; % shading to mark the event/stimuli
%
% Output-struct-EventST
% EventST.EventPreFramesArrays = EventPreFramesArrays; % the frames to show
% EventST.EventPostFramesArrays = EventPostFramesArrays;    % the frames to show
% EventST.EventPre = EventPre; % the time (sec) to show
% EventST.EventPost = EventPost; % the time (sec) to show
% EventST.EventFrameLength = (EventPre + EventPost)*FrameRate + 1; %take care of the OnsetFrame
% EventST.nStamps = nStamps;
% EventST.TS = TS;
% EventST.F0 % the frames for baseline
% EventST.EventPostF  % the frames to quantify post response.

% Chun Xu, July 04,2016
% Modified, Sep 07, 2016. 
%  Adapt some changes for analyzing photometry data.

if nargin <3
    FrameRate = 20; % Hz
end
%% Event
switch type
    case 'CS30sec'
        preF=[0 20]; % period to calculate the baseline
        preFshow=[0 30]; % period to show in the figure
        postF=[0 30]; % period to calculate the response
        postFshow=[0 40]; % period to show in the figure
        width=[0 30]; % shading to mark the event/stimuli
    case 'CS10sec'
        preF=[0 5]; 
        preFshow=[0 10]; 
        postF=[0 10]; 
        postFshow=[0 30]; 
        width=[0 10];
    case 'US'
        preF=[0 5]; 
        preFshow=[0 5]; 
        postF=[0 5]; 
        postFshow=[0 10]; 
        width=[0 2];
    case 'Opt2ms'
        preF=[0 2]; 
        preFshow=[0 2]; 
        postF=[0 2]; 
        postFshow=[0 2]; 
        width=[0 0.002];        
    case 'Opt2ms_delay' 
        preF=[0.2, 2]; 
        preFshow=[0 2]; 
        postF=[1, 3]; 
        postFshow=[0 3]; 
        width=[0 0.002];       
    case 'Shock' 
        preF=[0.2, 2]; 
        preFshow=[0 5]; 
        postF=[1, 3]; 
        postFshow=[0 15]; 
        width=[0 0.002];     
    case 'water' 
        preF=[0.2, 2]; 
        preFshow=[0 2]; 
        postF=[1, 3]; 
        postFshow=[0 5]; 
        width=[0 0.002]; 
end

Event.preF = preF;
Event.preFshow = preFshow;
Event.postF = postF;
Event.postFshow = postFshow;
Event.width = width;
Event.type = type;
Event.FrameRate = FrameRate;
Event.FPS=1/FrameRate; % FPS*FrameRate=1 

%% EventST

if nargin < 2
    EventST = [];
else
TS = TS(~isnan(TS)); % unit is sec
nStamps = length(TS);
EventPre = max(preF(2), preFshow(2));
EventPost = max(postF(2), postFshow(2));
[EventPreFramesArrays, EventPostFramesArrays, EventF0, EventPostF] = deal( cell(nStamps,1)); 
for kk = 1 : nStamps
    % find the frame right after(>=) the timestamps
    OnsetFrame = ceil( TS(kk) * FrameRate);
    % Note: the onset frame is the FIRST frame in PostEvent
    EventPreFramesArrays{kk} = (OnsetFrame-EventPre*FrameRate): 1 : (OnsetFrame-1); 
    EventPostFramesArrays{kk} = OnsetFrame : 1 : (OnsetFrame+EventPost*FrameRate);
    EventF0{kk} = (OnsetFrame - preF(2)*FrameRate):1:(OnsetFrame - 1);
    EventPostF{kk} = OnsetFrame : 1 : (OnsetFrame+postF(2)*FrameRate);
    
end
EventST.EventPreFramesArrays = EventPreFramesArrays;
EventST.EventPostFramesArrays = EventPostFramesArrays;
EventST.EventF0 = EventF0;
EventST.EventPostF = EventPostF;
EventST.EventPre = EventPre;
EventST.EventPost = EventPost;
EventST.EventFrameLength = (EventPre + EventPost)*FrameRate + 1; % take care of the OnsetFrame
EventST.nStamps = nStamps;
EventST.TS = TS;
end

end % function <setEvent>