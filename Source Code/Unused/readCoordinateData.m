function [S] = readData(input)
% Title   : Read Data
% Author  : Frank Madrid
% Purpose : Math 477/490 - Research in Industrial Mathematics
%           Helper function to Awesome.m
% Usage   : 
%       Input: 
%           input : input file name. File must be a list of two-dimensional points
%
%       Output:
%           S : The list of points read from the file
%--------------------------------------------------------------------------

    fileID = fopen(input, 'r');      % Open input file
    
    A = fscanf(fileID, '%e', [3 Inf]); % Read numbers in exp notation

    fclose(fileID); % Close input file

    S = transpose(A); % Reshape matrix into a column of points

end