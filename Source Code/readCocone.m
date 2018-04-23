function [pointList] = readCocone(input)
% Title   : Read Data
% Author  : Frank Madrid
% Purpose : Math 477/490 - Research in Industrial Mathematics
%           Helper function
% Usage   : 
%       Input: 
%           input : input file name. File must be a list of two-dimensional points
%
%       Output:
%           S : The list of points read from the file
%--------------------------------------------------------------------------

    fileID = fopen(input, 'r');      % Open input file
    
    fgets(fileID); % Skip the first line of the OFF file
    
    Properties = fscanf(fileID, '%d', [3 1]);
    
    pointCount = Properties(1);
    
    % Read in the pointList
    pointList = fscanf(fileID, '%f', [3 pointCount]);
    
    fclose(fileID); % Close input file

    pointList = transpose(pointList);
    
end