
%% Heatmap and averaged trace to show emotional responses

filepath = '\Code_Data\shock_data'; % Use your local path!

datatype = 'RawF_1'; %  'RawF_1'; % ' R_1';
filetype = '.csv';
ArrayIdx = 1 : 4; % Select animals in the data folder

inputs.folder1 = filepath; % data folder
inputs.FrameRate = 30; % Hz, data sampling rate
inputs.bShowPlots = true; % whether show the result figures
inputs.bSavePlots = false; % whether save the result figures
inputs.bSaveNewFileIfExist = false; % save new file if the file name existed. Only check once!

% organize the cell array for file paths
filenames=dir([ filepath, '\#*_shock_stamp.csv']); % shock timestamps
ShockStampsArray2 = cell( size(filenames));
name = cell( size(filenames));
for n = 1 : length( filenames)
    ShockStampsArray2{n}= fullfile( filepath, filenames( n).name);    
end

filenames=dir([ filepath, '\#*_shock.csv']); % photometry data for shock stimuli
DataFileArrays2 = cell( size(filenames));
for n = 1 : length( filenames)
    DataFileArrays2{n}= fullfile( filepath, filenames( n).name);
    name{n}=filenames( n).name;
end

% Shock
PhotometryData = PhotometryDatabyStamps_ante('', DataFileArrays2, name, ArrayIdx, datatype, 'Shock', ShockStampsArray2, inputs);

%%
disp('done');

%% copy files into a single folder
% ShockStampsArray( cellfun(@isempty, ShockStampsArray)) = []; 
% DataFileArrays( cellfun(@isempty, DataFileArrays)) = []; 
% tmp2=cd;
% for i = 1 : length(ShockStampsArray)    
%     tmp1 = ShockStampsArray{i};
%     s=copyfile( tmp1,  tmp2);
%     if ~s; warning('copying %s failed!', tmp1); end
%     tmp1 = DataFileArrays{i};
%     s=copyfile( tmp1,  tmp2);
%     if ~s; warning('copying %s failed!', tmp1); end    
% end
% clear  tmp1 tmp2

