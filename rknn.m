% Title   : Reverse k-Nearest Neighbor
% Author  : Frank Madrid
% Purpose : Math 477/490 - Research in Industrial Mathematics
%           Returns a matrix of values which represent the reverse
%           k-nearest neighbor count for each index
% Usage   : 
%       Input: 
%           Points : Sample Data in [X1 Y1 Z1 ; ... ; Xn Yn Zn] format
%           kNN    : Indexed list of k-nearest neighbors
%
%       Output:
%           rkNN : rkNN values

function [alphaCount] = rknn(Points, kNN)

pointCount = size(Points,1); % Define the number of points

% Count the number of times a point is another point's nearest neighbor
alphaCount = zeros(1, pointCount);
for n = 1:pointCount
    
    alphaCount(n) = sum(sum(kNN == n));
    
end