%% Title   : Boundary Point Estimator
%  Author  : Frank Madrid
%  Purpose : Math 477/490 - Research in Industrial Mathematics
%  Usage   : run BoundaryPointEstimator.m
%           
%            FILENAME       : File name containing original point data
%            FILENAME_NOISE : File name containing noisy point data
%            DIRECTORY      : Location of experimental results
%            FORMAT         : Data format of the point data
%                                1 - Exponential (123E-3)
%                                2 - Decimal (0.123)
%
%            MODE           : Specify algorithm implemenation
%                                1 - RKNN
%                                2 - RCOCONE
%                                3 - HYBRID
%
%            GENERATE_TABLE : Generate table data for RKNN method
%                                1 - YES
%                                2 - NO
%
%            GENERATE_GRAPH : Generage graph data
%                                1 - YES
%                                0 - NO
%
%            DEBUG          : Display program debugging information    
%                                1 - ON
%                                0 - OFF
%
%            THRESHOLD : Minimum sample point percentage required
%
%            K_MIN     : k-nearest neighbors minimum
%            K_MAX     : k-nearest neighbors maximum
%
%            ALPHA_MIN : reverse k-nearest neighbor minimum
%            ALPHA_MAX : reverse k-nearest neighbor maximum
%
%            SAMPLE    : Number of iterations to run rCocone
%           
%            BBR_MIN  : 
%            BBR_MAX  :
%            THIF_MIN :
%            THIF_MAX :
%            THFF_MIN :
%            THFF_MAX :

%% ---------- Program Parameters ----------
FILENAME_SAMPLE = 'sample3_suprachiasmatic_v1/right_suprachiasmatic_nucleus_Vertices.txt';
FILENAME_NOISE  = 'sample3_suprachiasmatic_v1/noisy_version_suprachiasmatic_v1.txt';
FORMAT          = 'exponential';
DIRECTORY       = 'Nucleus';

MODE            = 2;
GENERATE_TABLE  = 1;
GENERATE_GRAPH  = 1;
DEBUG           = 1;
HIDE = 1;
THRESHOLD = 0.90;
K_MIN     = 1;
K_MAX     = 100;
ALPHA_MIN = 1;
ALPHA_MAX = K_MAX;

SAMPLE    = 1;
BBR_MIN   = 15;
BBR_MAX   = 50;
THIF_MIN  = 1;
THIF_MAX  = 10;
THFF_MIN  = 8;
THFF_MAX  = 20;

%% ---------- Begin Program Execution ----------
programStart = tic;

switch(MODE)
    case 1
        STRMODE = 'RKNN';
    case 2
        STRMODE = 'RCOCONE';
    case 3
        STRMODE = 'HYBRID';
end

fprintf('---------- Parameters ----------\n');
fprintf('FILENAME       = %s\n', FILENAME_SAMPLE);
fprintf('FILENAME_NOISE = %s\n', FILENAME_NOISE);
fprintf('MODE           = %s\n', STRMODE);
fprintf('GENERATE GRAPH = %d\n\n', GENERATE_GRAPH);

fprintf('THRESHOLD = %2.0f%%\n', THRESHOLD * 100);
fprintf('K_MIN     = %d\n', K_MIN);
fprintf('K_MAX     = %d\n', K_MAX);
fprintf('ALPHA_MIN = %d\n', ALPHA_MIN);
fprintf('ALPHA_MAX = %d\n', ALPHA_MAX);
fprintf('------------------------------\n');

%% ---------- Read Point Data ----------
inputSample   = sprintf('Data/PointLists/%s', FILENAME_SAMPLE); %Data/PointLists/FILENAME_SAMPLE

if DEBUG
    fprintf('SYSTEM: Reading sample data from %s\n', FILENAME_SAMPLE);
end

[samplePointList, samplePointCount]  = readData(inputSample, 3, FORMAT); %Read sample point data

inputNoise = sprintf('Data/PointLists/%s', FILENAME_NOISE);         % Data/PointLists/FILENAME_NOISE

if DEBUG
    fprintf('Sysetm: Reading noisy data from %s\n', FILENAME_NOISE);
end

[noisePointList,noisePointCount] = readData(inputNoise, 3, FORMAT); % Read noise + sample point data

%% ---------- Reverse k-Nearest Neighbor ----------
if MODE == 1
    
    % Run knn on the noisy + sample data
    if DEBUG
        fprintf('SYSTEM: Running knnsearch on noisy data');
    end
    
    KNN = knnsearch(noisePointList, noisePointList, 'K', K_MAX + 1); % Find nearest k + 1 neighbors since each point is its own nearest neighbor
    KNN(:,1) = [];                                                   % Remove the first column of the knn since each point is closest to itself
    
    % Intialize Results file for RKNN
    output = sprintf('Data/%s/RKNN/Results/Results.txt', DIRECTORY);
    
    if DEBUG
        fprintf('SYSTEM: Opening results file %s\n', output);
    end
    
    resultFile   = fopen(output, 'w');

    date = clock;
    
    fprintf(resultFile, 'Filename    : %s\n', FILENAME_NOISE);
    fprintf(resultFile, 'Mode        : RKNN\n');
    fprintf(resultFile, 'Date        : %d/%d/%d %d:%d\n', date(2), date(3), date(1), date(4), date(5));
    fprintf(resultFile, 'Description : Displays the k values, alpha values, and failure percentages where \n');
    fprintf(resultFile, '              the success percentage is greater than or equal to the threshold\n');
    fprintf(resultFile, '--------------------\n');
    fprintf(resultFile, 'THRESHOLD    = %0.2f%%\n', THRESHOLD * 100);
    fprintf(resultFile, 'K_MIN        = %d\n', K_MIN);
    fprintf(resultFile, 'K_MAX        = %d\n', K_MAX);
    fprintf(resultFile, 'ALPHA_MIN    = %d\n', ALPHA_MIN);
    fprintf(resultFile, 'ALPHA_MAX    = %d\n', ALPHA_MAX);
    fprintf(resultFile, 'Sample Count = %d\n', samplePointCount);
    fprintf(resultFile, 'Noise Count  = %d\n', noisePointCount);
    fprintf(resultFile, '--------------------\n');
    
    startK = tic;
    
    minFail = (noisePointCount - samplePointCount);
    % For each k in range, run the RKNN algorithm
    for k = K_MIN:K_MAX
        
        if HIDE
            fprintf('k = %d\n',k);
        end
        if DEBUG
            fprintf('k = %d ',k);
        end
        
        % Output the current k value
        fprintf(resultFile, 'K-Value: %3d\n', k);
        
        if GENERATE_TABLE
            
            % Initalize the k-unique tables
            outputTable = sprintf('Data/%s/RKNN/Results/Tables/k=%d.txt\n', DIRECTORY, k);

            if DEBUG
                fprintf('SYSTEM: Opening table file %s\n', outputTable);
            end

            tableFile   = fopen(outputTable, 'w');
            
            date = clock;
            fprintf(tableFile, 'Filename    : %s\n', FILENAME_NOISE);
            fprintf(tableFile, 'Mode        : RKNN\n');
            fprintf(tableFile, 'K Value     : %d\n', k);
            fprintf(tableFile, 'Date        : %d/%d/%d %d:%d\n', date(2), date(3), date(1), date(4), date(5));
            fprintf(tableFile, 'Description : Displays the success and failure percentages for each k-value and\n');
            fprintf(tableFile, '              alpha value pair\n');
            fprintf(tableFile, '--------------------\n');
            fprintf(tableFile,'ALPHA_MIN = %d\n', ALPHA_MIN);
            fprintf(tableFile,'ALPHA_MAX = %d\n', ALPHA_MAX);
            fprintf(tableFile, '--------------------\n');
        
        end
        
        % Run the RKNN algorithm on the first k neighbors
        tempKNN = KNN(:, 1:k);
        RKNN    = rknn(noisePointList, tempKNN);

        % Initialize the graph results
        successCount = zeros(ALPHA_MAX,1);
        failureCount = zeros(ALPHA_MAX,1);
        vLineCutOff  = 0;
        
        startAlpha = tic;
        
        for alpha = ALPHA_MIN:ALPHA_MAX

            knnData = sprintf('Data/%s/RKNN/rknn/k=%d,alpha=%d.DATA', DIRECTORY, k, alpha);

            index = RKNN >= alpha; % Store indices of points which is in the knn of at least n other points

            if DEBUG
                fprintf('SYSTEM: Outputting the rknn data to %s\n', knnData);
            end
            
            dlmwrite(knnData, noisePointList(RKNN >= alpha,:), 'delimiter', ' ', 'newline', 'pc')  % Output rkNN to output file

            successCount(alpha) = sum(index(1:samplePointCount));                 % Count the number of sample points
            failureCount(alpha) = sum(index(samplePointCount+1:noisePointCount)); % Count the list of noisy points assuming the noisy points have been
                                                                                  % appended to the sample data

            if GENERATE_TABLE
                
                fprintf(tableFile, 'Alpha   : %d\n', alpha);
                fprintf(tableFile, 'Success : %4d %3.2f%%\n', successCount(alpha), (successCount(alpha) / samplePointCount) * 100);
                fprintf(tableFile, 'Failure : %4d %3.2f%%\n', failureCount(alpha), (failureCount(alpha) / (noisePointCount - samplePointCount) * 100));
                fprintf(tableFile, '------------------------------\n');
                
            end

            % If the success percentage is greater then or equal to the specified threshold, store the respective alpha 
            % and failure percentage within the results file
            
            
            if (successCount(alpha) / samplePointCount) >= THRESHOLD
                
                fprintf(resultFile, '\tAlpha = %2d : %3.2f %%\n', alpha, (failureCount(alpha) / (noisePointCount - samplePointCount) * 100));
                vLineCutOff = alpha;
                
            end
             
        end
        
        % Output the progarm execution time
        elapsedAlpha = toc(startAlpha);
        
        if GENERATE_TABLE
            
            fprintf(tableFile, 'Execution Time : %0.2f\n', elapsedAlpha);
            fprintf(tableFile, 'Average Time   : %0.2f\n', elapsedAlpha / (ALPHA_MAX - ALPHA_MIN));
        
        end
        
        % Generate the graphs associating the alpha values and the success/failure percentages for each k-value
        if GENERATE_GRAPH
            
            fig1 = figure;
            set(fig1,'visible','off')

            scatter(1:ALPHA_MAX, (failureCount / (noisePointCount - samplePointCount)) * 100, 10, [1 0 0], 'filled');
            hold on
            scatter(1:ALPHA_MAX, (successCount / samplePointCount) * 100, 10, [0 0 1], 'filled');
            hold off
            
            if vLineCutOff ~= 0;
            
                if failureCount(vLineCutOff) < minFail && ((successCount(vLineCutOff) / samplePointCount) > THRESHOLD)
                    minFail = failureCount(vLineCutOff);
                end
                
%                 str0 = sprintf('Threshold = %d%%', THRESHOLD * 100);
%                 str1 = sprintf('Maximum Alpha = %d', vLineCutOff);
%                 str2 = sprintf('Success = %.2f%%', (successCount(vLineCutOff) / samplePointCount) * 100);
%                 str3 = sprintf('Minimum Failure = %.2f%%', failureCount(vLineCutOff) / (noisePointCount - samplePointCount) * 100); 
                vline(vLineCutOff,'k', '');
                hline((successCount(vLineCutOff) / samplePointCount) * 100, 'k', '');
                hline(failureCount(vLineCutOff) / (noisePointCount - samplePointCount) * 100, 'k', '');
                hline(minFail / (noisePointCount - samplePointCount) * 100, 'b', '');
                
            end
            
            graphTitle = sprintf('Alpha Values vs Percentages for K-Value %d', k);
            title(graphTitle);
            xlabel('Alpha Values');
            ylabel('Percentages');
            xlim([ALPHA_MIN,ALPHA_MAX]);
            ylim([0,100]);
            xlim manual;
            ylim manual;
            grid on;
            

            outputFilename = sprintf('Data/%s/RKNN/Results/Graphs/k=%d.png', DIRECTORY, k); % Awesome/Data/DIRECTORY/RKNN/Results/Graph/ k = 'k'

            if DEBUG
                fprintf('SYSTEM: Creating graph %s\n', outputFilename);
            end
            
            saveas(fig1, outputFilename);
            
        end
        
    end
    
    elapsedK = toc(startK);
    fprintf(resultFile, 'Execution Time: %0.2f\n', elapsedK);
    fprintf(resultFile, 'Average Time  : %0.2f\n', elapsedK / (K_MAX - K_MIN));
       
end

%% ---------- Robust Cocone ----------
if MODE == 2
    
    rCoconeStart = tic;
    
    % Intialize Results file for RKNN
    output = sprintf('Data/%s/RCOCONE/Results/Results.txt', DIRECTORY);
    
    if DEBUG
        fprintf('SYSTEM: Opening %s\n', output);
    end
    
    resultFile   = fopen(output, 'w');

    date = clock;
    fprintf(resultFile, 'Filename    : %s\n', FILENAME_NOISE);
    fprintf(resultFile, 'Mode        : RCocone\n');
    fprintf(resultFile, 'Date        : %d/%d/%d %d:%d\n', date(2), date(3), date(1), date(4), date(5));
    fprintf(resultFile, 'Description : Displays the average success and failure ratios for SAMPLE\n');
    fprintf(resultFile, '              randomly picked values of BFF, THIF, and THFF\n');
    fprintf(resultFile, '--------------------\n');
    fprintf(resultFile, 'THRESHOLD    = %.2f%%\n', THRESHOLD * 100);
    fprintf(resultFile, 'BBR_MIN      = %d\n', BBR_MIN);
    fprintf(resultFile, 'BBR_MAX      = %d\n', BBR_MAX);
    fprintf(resultFile, 'THIF_MIN     = %d\n', THIF_MIN);
    fprintf(resultFile, 'THIF_MAX     = %d\n', THIF_MAX);
    fprintf(resultFile, 'THFF_MIN     = %d\n', THFF_MIN);
    fprintf(resultFile, 'THFF_MAX     = %d\n', THFF_MAX);
    fprintf(resultFile, 'Sample Count = %d\n', samplePointCount);
    fprintf(resultFile, 'Noise Count  = %d\n', noisePointCount);
    fprintf(resultFile, '--------------------\n');

    output = sprintf('Data/%s/RCOCONE/rCocone/output', DIRECTORY);
    
    successCount = zeros(1,SAMPLE);
    failureCount = zeros(1,SAMPLE);
    
    for n = 1:SAMPLE
        
        a = (BBR_MAX  - BBR_MIN)  * rand() + BBR_MIN;
        b = (THIF_MAX - THIF_MIN) * rand() + THIF_MIN;
        c = (THFF_MAX - THFF_MIN) * rand() + THFF_MIN;
        
        %input = sprintf('-bbr %0.2f -thif %0.2f -thff %02.f Data/PointLists/%s', a / 100, b, c, FILENAME_NOISE);
        input = sprintf('-bbr %0.2f -thif %0.2f -thff %02.f Data/Geniculate/RKNN/rknn/k=9,alpha=8.txt', a / 100, b, c);
        if DEBUG
             
            fprintf('SYSTEM: Running rcocone on %s\n', input);
            
        end
        
        str = sprintf('rcocone-win.exe %s %s', input, output);

        if DEBUG
             
            fprintf('SYSTEM: Calling rcocone %s\n', str);
         
        end
        
        [~,~] = system(str); % Ignore outputs to suppress executable output

        if DEBUG
            
             fprintf('SYSTEM: Reading surf file %s\n', output);
             
        end
        
        input = sprintf('%s.surf', output); %Awesome/DATA_DIR/strMODE/output_n.surf
        RCOCONE = readCocone(input);

        inS = ismemberf(RCOCONE, samplePointList, 'tol', 1E-3);
        inN = ismemberf(RCOCONE, noisePointList,  'tol', 1E-3);
        successCount(n) = sum(sum(transpose(inS)) == 3);
        failureCount(n) = sum(sum(transpose(inN)) == 3) - successCount(n);

        rCoconeData = sprintf('Data/%s/RCOCONE/Results/n=%d.DATA', DIRECTORY, n);

        
            fprintf('SYSTEM: Outputting the rknn data to %s\n', rCoconeData);
        

        dlmwrite(rCoconeData, RCOCONE, 'delimiter', ' ', 'newline', 'pc');  % Output rkNN to output file
    end

    successPercent = successCount / samplePointCount;
    failurePercent = failureCount / (noisePointCount - samplePointCount);
    fprintf(resultFile, 'Sample Count    = %d\n', SAMPLE);
    fprintf(resultFile, 'Threshold Hit   = %d\n', sum(successPercent >= THRESHOLD));
    fprintf(resultFile, 'Minimum Percent = %3.2f %3.2f\n', min(successPercent)  * 100, min(failurePercent)  * 100);
    fprintf(resultFile, 'Maximum Percent = %3.2f %3.2f\n', max(successPercent)  * 100, max(failurePercent)  * 100);
    fprintf(resultFile, 'Average Value   = %3.2f %3.2f\n', mean(successPercent) * 100, mean(failurePercent) * 100);
    fprintf(resultFile, 'Standard Dev.   = %3.2f %3.2f\n', std2(successPercent) * 100, std2(failurePercent) * 100);
    fprintf(resultFile, '--------------------\n');
    
    rCoconeElapsed = toc(rCoconeStart);
    fprintf(resultFile, 'Execution Time: %0.2f\n', rCoconeElapsed);
    fprintf(resultFile, 'Average Time  : %0.2f\n', rCoconeElapsed / SAMPLE);
    
end

%% ---------- HYBRID ----------
if MODE == 3
    
    hybridStart = tic;
    
    % Intialize Results file for RKNN
    output = sprintf('Data/%s/HYBRID/Results/Results.txt', DIRECTORY);
    
    if DEBUG
        fprintf('SYSTEM: Opening %s\n', output);
    end
    
    resultFile   = fopen(output, 'w');

    date = clock;
    fprintf(resultFile, 'Filename    : %s\n', FILENAME_NOISE);
    fprintf(resultFile, 'Mode        : HYBRID\n');
    fprintf(resultFile, 'Date        : %d/%d/%d %d:%d\n', date(2), date(3), date(1), date(4), date(5));
    fprintf(resultFile, 'Description : Displays the average success and failure ratios for SAMPLE\n');
    fprintf(resultFile, '              randomly picked values of BFF, THIF, and THFF\n');
    fprintf(resultFile, '--------------------\n');
    fprintf(resultFile, 'THRESHOLD    = %.2f%%\n', THRESHOLD * 100);
    fprintf(resultFile, 'K_MIN        = %d\n', K_MIN);
    fprintf(resultFile, 'K_MAX        = %d\n', K_MAX);
    fprintf(resultFile, 'ALPHA_MIN    = %d\n', ALPHA_MIN);
    fprintf(resultFile, 'ALPHA_MAX    = %d\n', ALPHA_MAX);
    fprintf(resultFile, 'SAMPLING     = %d\n', SAMPLE);
    fprintf(resultFile, 'BBR_MIN      = %d\n', BBR_MIN);
    fprintf(resultFile, 'BBR_MAX      = %d\n', BBR_MAX);
    fprintf(resultFile, 'THIF_MIN     = %d\n', THIF_MIN);
    fprintf(resultFile, 'THIF_MAX     = %d\n', THIF_MAX);
    fprintf(resultFile, 'THFF_MIN     = %d\n', THFF_MIN);
    fprintf(resultFile, 'THFF_MAX     = %d\n', THFF_MAX);
    fprintf(resultFile, 'Sample Count = %d\n', samplePointCount);
    fprintf(resultFile, 'Noise Count  = %d\n', noisePointCount);
    fprintf(resultFile, '--------------------\n');
    
    output = sprintf('Data/%s/RCOCONE/rCocone/output', DIRECTORY);
    
    P = zeros(SAMPLE,3);
    for n = 1:SAMPLE
        
        a = (BBR_MAX  - BBR_MIN)  * rand() + BBR_MIN;
        b = (THIF_MAX - THIF_MIN) * rand() + THIF_MIN;
        c = (THFF_MAX - THFF_MIN) * rand() + THFF_MIN;
        
        P(n,:) = [a b c];
        
    end
    
    for k = K_MIN:K_MAX
        
        successCount = zeros(ALPHA_MAX,1);
        failureCount = zeros(ALPHA_MAX,1);
        vLineCutOff = 0;
        
        for alpha = ALPHA_MIN:ALPHA_MAX
            
            filename = sprintf('Data/%s/RKNN/rknn/k=%d,alpha=%d.DATA', DIRECTORY, k, alpha);
            
            tempSuccessCount = zeros(1,SAMPLE);
            tempFailureCount = zeros(1,SAMPLE);
            
            inS = 0;
            inN = 0;
            
            for n = 1:SAMPLE
        
                input = sprintf('-bbr %.2f -thif %.0f -thff %.0f %s', P(n,1) / 100, P(n,2), P(n,3), filename);

                if DEBUG

                    fprintf('SYSTEM: Running rcocone on %s\n', input);

                end

                str = sprintf('rcocone-win.exe %s %s', input, output);

                if DEBUG

                    fprintf('SYSTEM: Calling rcocone %s\n', str);

                end

                [~,~] = system(str); % Ignore outputs to suppress executable output

                if DEBUG

                     fprintf('SYSTEM: Reading surf file %s\n', output);

                end

                input = sprintf('%s.surf', output); %Awesome/DATA_DIR/strMODE/output_n.surf
                RCOCONE = readCocone(input);
                
                inS = ismemberf(RCOCONE, samplePointList, 'tol', 1E-3);
                inN = ismemberf(RCOCONE, noisePointList,  'tol', 1E-3);
                tempSuccessCount(n) = sum(sum(transpose(inS)) == 3);
                tempFailureCount(n) = sum(sum(transpose(inN)) == 3) - tempSuccessCount(n);
                return
            end
            
            successPercent = tempSuccessCount / samplePointCount;
            failurePercent = tempFailureCount / (noisePointCount - samplePointCount);
            
            fprintf(resultFile, 'k-Value = %3d alpha = %3d\n', k, alpha);
            fprintf(resultFile, 'Minimum Percent = %3.2f %3.2f\n', min(successPercent(:))  * 100, min(failurePercent(:)) * 100);
            fprintf(resultFile, 'Maximum Percent = %3.2f %3.2f\n', max(successPercent(:))  * 100, max(failurePercent(:)) * 100);
            fprintf(resultFile, 'Average Value   = %3.2f %3.2f\n', mean(successPercent) * 100, mean(failurePercent) * 100);
            fprintf(resultFile, 'Standard Dev.   = %3.2f %3.2f\n', std2(successPercent) * 100, std2(failurePercent) * 100);
            fprintf(resultFile, '--------------------\n');

        end 
        
        successCount(alpha) = mean(successPercent) * samplePointCount;
        failureCount(alpha) = mean(failurePercent) * (noisePointCount - samplePointCount);
    
        % Generate the graphs associating the alpha values and the success/failure percentages for each k-value
        if GENERATE_GRAPH

            fig1 = figure;
            set(fig1,'visible','off')

            scatter(1:ALPHA_MAX, (failureCount / (noisePointCount - samplePointCount)) * 100, 10, [1 0 0], 'filled');
            hold on
            scatter(1:ALPHA_MAX, (successCount / samplePointCount) * 100, 10, [0 0 1], 'filled');
            hold off

            if vLineCutOff ~= 0;

                str0 = sprintf('Threshold = %0.2f%%', THRESHOLD * 100);
                str1 = sprintf('Maximum Alpha = %d', vLineCutOff);
                str2 = sprintf('Success = %.2f%%', (successCount(vLineCutOff) / samplePointCount) * 100);
                str3 = sprintf('Minimum Failure = %.2f%%', failureCount(vLineCutOff) / (noisePointCount - samplePointCount) * 100); 
                vline(vLineCutOff,'k', '');
                hline((successCount(vLineCutOff) / samplePointCount) * 100, 'k', '');
                hline(failureCount(vLineCutOff) / (noisePointCount - samplePointCount) * 100, 'k', '');

                text(70,80,str0);
                text(70,75,str1);
                text(70,70,str2);
                text(70,65,str3);

            end

            graphTitle = sprintf('Alpha Values vs Percentages for K-Value %d', k);
            title(graphTitle);
            xlabel('Alpha Values');
            ylabel('Percentages');
            xlim([ALPHA_MIN,ALPHA_MAX]);
            ylim([0,100]);
            xlim manual;
            ylim manual;
            legend('Sample Points', 'Noisy Points');
            grid on;


            outputFilename = sprintf('Data/%s/HYBRID/Results/Graphs/k=%d.png', DIRECTORY, k); % Awesome/Data/DIRECTORY/RKNN/Results/Graph/ k = 'k'

            if DEBUG
                fprintf('SYSTEM: Creating graph %s\n', outputFilename);
            end

            saveas(fig1, outputFilename);

        end
        
    end
    
    elapsedK = toc(hybridStart);
    fprintf(resultFile, 'Execution Time: %0.2f\n', elapsedK);
    fprintf(resultFile, 'Average Time  : %0.2f\n', elapsedK / (K_MAX - K_MIN));
    
end

%%
fclose('all');