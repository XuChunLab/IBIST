function DataColumn = GetDataColumn(num,txt,ColumnLabel)
% GetMatrixData from specific Column defined by the txt label
% Note: ColumnLabel should be unique.
idx = strcmp( ColumnLabel, txt);
DataColumn = num( :, idx);
DataColumn = DataColumn( ~isnan(DataColumn)); 
end % GetDataRow END