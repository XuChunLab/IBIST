function [PhotometryData, TimeStampsArray, EventDataArray, EventDataNorArray, PreMeanArray, PostNorPeakArray]  =  PhotometryDatabyStamps_ante(Data1, DataFileArrays, name, ArrayIdx, datatype, Prefix, TimeStampFileArray, inputs)
% useful for scripts based on fun_1_haoshan_photometry_3_4

    folder1 = inputs.folder1;
    FrameRate = inputs.FrameRate ; % Hz
    bShowPlots = inputs.bShowPlots;
    bSavePlots = inputs.bSavePlots;
    bSaveNewFileIfExist = inputs.bSaveNewFileIfExist; % save new file the file name existed. Only check once!

    nAnimals = numel( ArrayIdx);  % animal numbers
    bReadData1 = true;
    % check variable <PhotometryData>
    if isempty( Data1)
        PhotometryData = cell(1,nAnimals); 
    else
        if ( ~iscell( Data1))
            error('PhotometryData varaible is not class <cell>');
        end
        PhotometryData = Data1;
        bReadData1 = false;
    end
    % analyze photometry data based on timestamps
    [TimeStampsArray, EventDataArray, ...
         EventDataNorArray, PreMeanArray, PostNorPeakArray, ...
         ] = deal( cell(1,nAnimals)); 

    for k =  ArrayIdx
    % read photometry Ca2+ data if <PhotometryData> not valid.
    if bReadData1
        fprintf('%s need to read the photometry data\n',  name{k} ); % % Debug
        [num,txt,~] = xlsread(DataFileArrays{k}); 
        PhotometryData{k} = GetDataColumn(num,txt, datatype) ;  % ' R_1', 'RawF_1'
    end
    if isempty(PhotometryData{k}); error('no PhotometryData [ %s ]\n', name{k}); end 
    eventtype = 'Opt2ms_delay';
% ------------------------TimeStamps Creation ----------------------
    % If the user specify which type of timestamps, then we generated the
    % stamps as requested, otherwise, read from the csv file.
    switch Prefix
        case 'Shock'
            % read timestamps for opto laser stim before Conditioning.
            [num,txt,~] = xlsread(TimeStampFileArray{k}); 
            TimeStampsArray{k} = GetDataColumn(num,txt,'Time(ms)')/1000; % get data and convert unit from 'ms' to 'sec'      
            eventtype = 'Shock';
              
        case 'Tone'
            [num,txt,~] = xlsread(TimeStampFileArray{k}); 
            TimeStampsArray{k} = GetDataColumn(num,txt,'Time(ms)')/1000; % get data and convert unit from 'ms' to 'sec', Tone response.    
        case 'LED'
            [num,txt,~] = xlsread(TimeStampFileArray{k}); 
            TimeStampsArray{k} = GetDataColumn(num,txt,'Time(ms)')/1000; % get data and convert unit from 'ms' to 'sec', LED response.            
        otherwise            
            [num,txt,~] = xlsread(TimeStampFileArray{k}); % read timestamps for opto laser stim before Conditioning. 
            TimeStampsArray{k} = GetDataColumn(num,txt,'Time(ms)')/1000; % get data and convert unit from 'ms' to 'sec'         
    end
% ------------------------TimeStamps Created ----------------------    
    
    
    
    
    if isempty(TimeStampsArray{k});error('no Time(ms) [ %s ]', name{k}); end 

    otherinputs.FrameRate = FrameRate; 
    otherinputs.savedir = [folder1, name{k},'\'];    % where to save the figures.
    if ~exist( otherinputs.savedir, 'dir'); mkdir( otherinputs.savedir); end % create the folder if non-exist!

     [EventData, EventData_nor, eventwindow, PreMean, PostNorPeak, outputs] = PeriStimuliEvent(TimeStampsArray{k}, eventtype, PhotometryData{k}, otherinputs.FrameRate);

    % save specific  variable
    EventDataArray{ k} = EventData;
    EventDataNorArray{ k} = EventData_nor;
    PreMeanArray{ k} = PreMean;
    PostNorPeakArray{ k} = PostNorPeak;

    if bShowPlots
         EventDataPreMean = mean( PreMean);
         len1 = outputs.len1;

         % Plot the results
        [hFig1, ~] = Plot_MatHeat_ante( EventData_nor, eventwindow, otherinputs.FrameRate); 
        filename = [datatype, Prefix, ' Heatmap dFoF nor  ' name{k} '.png'];
        set(hFig1, 'name', filename); figure(hFig1); title( filename);
        saveas(hFig1,[otherinputs.savedir, filename]);

        [hFig2, hFig3, ~] = Plot_MatLine_ante( EventData_nor, eventwindow, otherinputs.FrameRate); 
        filename = [datatype, Prefix, ' Mean dFoF nor  ' name{k} '.png'];
        set(hFig2, 'name', filename); figure(hFig2); title( filename);
        line( xlim, [0, 0], 'LineStyle','-.'); % plot the average line
        line( [len1+1, len1+1], ylim,  'LineStyle','-.'); % plot the vertical zero line
        if bSavePlots; saveas(hFig2,[otherinputs.savedir, filename]); end

        filename = [datatype, Prefix, ' All Lines dFoF nor ' name{k} '.png'];
        set(hFig3, 'name', filename); figure(hFig3); title( filename);
        line( xlim, [0, 0], 'LineStyle','-.'); % plot the average line
        line( [len1+1, len1+1], ylim,  'LineStyle','-.'); % plot the vertical zero line
        saveas(hFig3,[otherinputs.savedir, filename]);
    % -Save outputs array for individual case.
    fprintf('%s Saving %s data...\n', name{k}, Prefix);
    Var_Info{1} = sprintf(['photometry data analysis - ', name{k}]);   
    Var_Info{2} = 'Each column is one trial~';
    Var_Info{3} = 'in case RAW, CSV file for normalize results ~';
    Var_Info{4} = 'in case R, CSV file for results with additional normalization ~';
    OutputArray.EventDataArray = EventDataArray{ k};
    OutputArray.EventDataNorArray = EventDataNorArray{ k};
    OutputArray.PreMeanArray = PreMeanArray{ k};
    OutputArray.PostNorPeakArray = PostNorPeakArray{ k};
    TimeWindowOutputs = outputs;
    tmpfile1 = fullfile( otherinputs.savedir,[name{k}, '_', Prefix, '_', datatype, '_OutputArray.mat']);
    tmpfile2 = fullfile( otherinputs.savedir, [name{k}, '_', Prefix, '_', datatype, '_OutputArray.csv']);
    % if file existed, either delete it or save with new name
    if exist( tmpfile1, 'file') 
        if bSaveNewFileIfExist
            tmpfile1 = [ tmpfile1, '_new.mat']; 
        else
            delete tmpfile1
        end
    end
    if exist( tmpfile2, 'file') && bSaveNewFileIfExist
        if bSaveNewFileIfExist
            tmpfile2 = [tmpfile2, '_new.csv']; 
        else
            delete tmpfile2
        end
    end

    save( tmpfile1, 'OutputArray','Var_Info', 'otherinputs', 'TimeWindowOutputs');
    % save results in EXCEL for further use. import into clampfit for further analysis
    % xlswrite(  fullfile( otherinputs.savedir, [name{k}, '_', Prefix, '_',  datatype, '_OutputArray.xlsx']),  cellstr( Var_Info), 'Info');
    switch datatype
        case 'R_1'
            csvwrite(  tmpfile2,  (  EventDataArray{ k})'); %  'Each column is one trial~'
        otherwise
            csvwrite(  tmpfile2,  (  EventDataNorArray{ k})'); %  'Each column is one trial~'
    end
    clear tmpfile1 tmpfile2 
    end %/// for k = ArrayIdx
end
