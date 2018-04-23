% Title   : Read Data
% Author  : Frank Madrid
% Purpose : Math 477/490 - Research in Industrial Mathematics
%           Returns a list of coordinates of the specified dimension
% Usage   : 
%       Input: 
%           inputFile : input file name. File must be a list of two-dimensional points
%           dimension : Size of the coordinates
%           type      : Indicates the number format of the data file
%                           - exponential
%
%       Output:
%           Points     : List of points read from the file
%           pointCount : Read points count
%--------------------------------------------------------------------------
function [Points, pointCount] = readData(inputFile, dimension, type)
    fileID = fopen(inputFile, 'r');      % Open input file
    
    if strcmp(type, 'exponential') == 1
    
        Points = fscanf(fileID, '%f', [dimension Inf]);  % Read numbers in float notation

    end
	 
	 if strcmp(type, 'float') == 1
    
        Points = fscanf(fileID, '%f', [dimension Inf]);  % Read numbers in float notation

    end
    
    fclose(fileID); % Close input file

    Points = transpose(Points); % Reshape matrix into a column of points
    
    pointCount = size(Points,1);

end