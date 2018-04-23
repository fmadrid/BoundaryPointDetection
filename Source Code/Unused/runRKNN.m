function runRKNN(noisePointList, samplePointCount, noisePointCount, K_MIN, K_MAX, ALPHA_MIN, ALPHA_MAX)

for k = K_MIN:K_MAX
        
    rknnStart = tic; % Begin rknn timer
    
    KNN = knnsearch(noisePointList, noisePointList, 'K', k + 1); % Find nearest k + 1 neighbors since each point is its own nearest neighbor

    KNN(:,1) = []; % Remove the first column of the knn since each point is closest to itself
    RKNN = rknn(noisePointList, KNN);

    % Initialize the graph results
    successCount = zeros(ALPHA_MAX,1);
    failureCount = zeros(ALPHA_MAX,1);

    for n = ALPHA_MIN:ALPHA_MAX

        knnData = sprintf('Data/%s/RKNN/k=%d,alpha=%d.DATA', DIRECTORY,k,n);

        index = RKNN >= n; % Store indices of points which is in the knn of at least n other points

        dlmwrite(knnData, noisePointList(RKNN >= n,:), 'delimiter', ' ', 'newline', 'pc')  % Output rkNN to output file

        successCount(n) = sum(index(1:samplePointCount));
        failureCount(n) = sum(index(samplePointCount+1:noisePointCount));

        fprintf(resultOutput, 'Alpha   : %d\n', n);
        fprintf(resultOutput, 'Success : %4d %3.2f%%\n', successCount(n), (successCount(n) / samplePointCount) * 100);
        fprintf(resultOutput, 'Failure : %4d %3.2f%%\n', failureCount(n), (failureCount(n) / (noisePointCount-samplePointCount) * 100));

        fprintf(resultOutput, '------------------------------\n');
        
    end
    
end

