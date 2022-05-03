function [EventData, EventData_nor, eventwindow, PreMeanArray, PostNorPeakArray, otheroutputs] =  PeriStimuliEvent(timestamps, type, Data, FrameRate)
% AIM:
% Analyze Prei Stimuli Event from continous data
% require <setEvent> function
% Chun XU, Feb 24, 2019
%
% INPUTS:
%   timestamps
%   type: type for timestamps to generate
%   FrameRate:
%
% OUTPUTS
%   EventData:
%   EventData_nor: normalized based on PreF
%   PostPeak: Peak value in Post Stimuli Event
%   otheroutputs: struct array for all stamps.
%     otheroutputs.tracePreArray = tracePreArray;
%     otheroutputs.tracePostArray = tracePostArray;
%     otheroutputs.len1 = len1;
%     otheroutputs.len2 = len2;
% EXAMPLE
%     otherinputs.FrameRate = 30; % Hz
%     otherinputs.savedir = [folder1, name{k},'\'];    % where to save the figures.
%     if ~exist( otherinputs.savedir, 'dir'); mkdir( otherinputs.savedir); end % create the folder if non-exist!
%     [EventData, EventData_nor, eventwindow, PreMeanArray, PostNorPeakArray, ~] = PeriStimuliEvent(timestamps_opto_before{k}, 'Opt2ms_delay', PhotometryData{k}, otherinputs.FrameRate);
%     EventDataPreMean = mean( PreMeanArray);

[EventSet1, EventTS] = setEvent(type, timestamps, FrameRate);
EventPreFramesArrays = EventTS.EventPreFramesArrays;
EventPostFramesArrays = EventTS.EventPostFramesArrays;
EventFrameLength = EventTS.EventFrameLength;
nStamps = EventTS.nStamps;
len1 = length( EventPreFramesArrays{1});
len2 = EventSet1.postF(2) *FrameRate; % defined postF
eventwindow = (len1+1) : 1 : (len1+len2);

[EventData, EventData_nor] = deal( NaN(nStamps, EventFrameLength));
PreMeanArray = NaN( nStamps, 1); % Pre mean for each trial
PostNorPeakArray = NaN( nStamps, 1); % Post Peak after normalization
[ tracePreArray, tracePostArray] = deal( cell( nStamps, 1));

for ii = 1 : nStamps
    tracePre = Data( EventPreFramesArrays{ii});
    PreMeanArray(ii,1) = mean( tracePre);
    tracePost = Data( EventPostFramesArrays{ii});
    trace = [tracePre', tracePost']; % because of tracePre(1,n).
    EventData(ii, :) = trace;
    % do the dF/F caluclation.   
    F0 = Data( EventTS.EventF0{ii}); 
    PostF = Data( EventTS.EventPostF{ii}); 
    PostNorPeakArray( ii, 1) = max( -1 + PostF/mean(F0));    
    % normalize the trace
    trace_nor = -1 + trace/mean(F0);
    EventData_nor(ii, :) = trace_nor;    
    tracePreArray{ii} = tracePre;
    tracePostArray{ii} = tracePost;    
end

otheroutputs.tracePreArray = tracePreArray;
otheroutputs.tracePostArray = tracePostArray;
otheroutputs.len1 = len1;
otheroutputs.len2 = len2;

end % END PeriStimuliEvent
 
