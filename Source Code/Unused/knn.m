% Title   : Reverse k-Nearest Neighbor
% Author  : Frank Madrid
% Purpose : Math 477/490 - Research in Industrial Mathematics
% Usage   : 
%       Input: 
%           S : Sample Data in [X1 Y1 Z1 ; ... ; Xn Yn Zn] format
%           k : Nearest neighbor threshold
%
%       Output:
%           I : Index of the k-nearest neighbors

function [I,pointCount] = knn(S, k)

pointCount = size(S,1); % Define the number of points
fprintf('KNN: PointCount = %d\n', pointCount);

% Calculate the distance matrix D where d(n,m) is equal to the euclidean
% distance of Xn and Xm. Since d(n,m) = d(m,n) we only need to calculate
% the upper triangle of matrix D to reduce program execution time
Distance = zeros(pointCount,pointCount);
fprintf('KNN: Calculating distance matrix\n');
for n = 1:pointCount

    A = S(n,:); % First point
    
    for m = n:pointCount
    
        B = S(m,:); % Second point
        
        Distance(n,m) = (A(1) - B(1))^2 + (A(2) - B(2))^2 + (A(3) - B(3))^2; % Calculate the distance. 
        
    end
    
end

fprintf('\n');

Distance = Distance + Distance'; % Add D to its transpose to calculate D(m,n) when D(n,m) is given

fprintf('KNN: Sorting distance matrix\n');
[~,I] = sort(Distance,2); % By sorting D, the first 'k' - columns of 'I' will be the indices of the k-nearest neighbors
fprintf('KNN: Index Count: %d\n',size(I,1));
I(:,1) = []; % We can ignore the first column since each point X_i has a distance of 0 to itself
I=I(:, [1:k]); % Get the k-nearest neighbors