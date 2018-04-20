% Title   : Boundary Point Detection
% Author  : Frank Madrid
% Purpose : Math 477/490 - Research in Industrial Mathematics
% Usage   : run Awesome.m
%           
%           FILENAME       : File name containing original point data
%           FILENAME_NOISE : File name containing noisy point data
%           DATA_DIR       : Directory to store all results
%           MODE           : Specify algorithm implemenation
%                               1 - RKNN
%                               2 - RCOCONE
%                               3 - HYBRID
%           GENERATE_GRAPH : Generage graph data
%                               1 - YES
%                               0 - NO
%           DEBUG          : Display program debugging information    
%                               1 - ON
%                               0 - OFF
%% ---------- Parameters ----------
FILENAME_SAMPLE = 'spherical_test_data.txt';
FILENAME_NOISE  = 'noisy_version_sphere_v2.txt';
DIRECTORY       = 'Sphere3';

MODE            = 2;
GENERATE_GRAPH  = 1;
DEBUG           = 1;

K_MIN           = 1;
K_MAX           = 10;
ALPHA_MIN       = 1;
ALPHA_MAX       = 2 * K_MAX;
%% ---------- Program Execution ----------

programStart = tic; % Begin total execution time timer

% Display program parameters to the screen

switch(MODE)
    case 1
        strMode = 'RKNN';
    case 2
        strMode = 'RCOCONE';
    case 3
        strMode = 'HYBRID';
    otherwise
        fprintf('SYSTEM: Error, invalid mode.\n');
        exit;
end

fprintf('---------- Parameters ----------\n');
fprintf('FILENAME       = %s\n', FILENAME_SAMPLE);
fprintf('FILENAME_NOISE = %s\n', FILENAME_NOISE);
fprintf('MODE           = %s\n', strMode);
fprintf('K_VALUE        = %d\n', k);
fprintf('------------------------------\n');

%% ---------- Results File ----------

outputFilename = sprintf('Data/%s/%s/Results/Results.txt', DIRECTORY, strMode); % Awesome/<DATA_DIR>/MODE/K_VALUE.txt

if DEBUG == 1
    fprintf('SYSTEM: Creating outputfile %s\n', outputFilename);
end

resultOutput = fopen(outputFilename, 'w');

date = clock;
fprintf(resultOutput, 'Filename : %s\n', FILENAME_NOISE);
fprintf(resultOutput, 'Mode     : %s\n', strMode);
fprintf(resultOutput, 'K Value  : %d\n', k);
fprintf(resultOutput, 'Date     : %d/%d/%d %d:%d\n\n', date(2), date(3), date(1), date(4), date(5)); 

%% ---------- Read Point Data ----------
outputFilename   = sprintf('Data/%s', FILENAME_SAMPLE);
[~, samplePointCount]  = readData(outputFilename, 3, 'exponential');

fprintf(resultOutput, 'Sample Point Count : %d\n', samplePointCount);

outputFilename = sprintf('Data/%s', FILENAME_NOISE);
[noisePointList,noisePointCount] = readData(outputFilename, 3, 'exponential');

fprintf(resultOutput, 'Noise Point Count  : %d\n', noisePointCount);

fprintf(resultOutput, '------------------------------\n');

%% ---------- Reverse k-Nearest Neighbors ----------

% IF MODE = RKNN or HYBID, THEN run RkNN
if MODE == 1 || MODE == 3
    
    rknnStart = tic; % Begin rknn timer
    kNN = knnsearch(noisePointList, noisePointList, 'K', k + 1); % Find nearest k + 1 neighbors since each point is its own nearest neighbor
    
    kNN(:,1) = []; % Remove the first column of the knn since each point is closest to itself
    [rkNN] = rknn(noisePointList, kNN);

    % Initialize the graph results
    successCount = zeros(ALPHA_MAX,1);
    failureCount = zeros(ALPHA_MAX,1);
    
    % Run rkNN for each ALPHA value in range
    for n = ALPHA_MIN:ALPHA_MAX
        
        outputFilename = sprintf('Data/%s/%s/RKNN/k=%d,alpha=%d.DATA', DIRECTORY,strMode,k,n); % Awesome/Data/DIRECTORY/MODE/RKNN
        
        if DEBUG == 1
            fprintf('SYSTEM: Writing rkNN data to %s\n', outputFilename);
        end
        
        index = rkNN >= n; % Store indices of points which is in the knn of at least n other points
        
        dlmwrite(outputFilename, noisePointList(rkNN >= n,:), 'delimiter', ' ', 'newline', 'pc')  % Output rkNN to output file
        
        % IF MODE = RKNN, THEN output results
        if MODE == 1
            
            successCount(n) = sum(index(1:samplePointCount));
            failureCount(n) = sum(index(samplePointCount+1:noisePointCount));
            
            fprintf(resultOutput, 'Alpha   : %d\n', n);
            fprintf(resultOutput, 'Success : %4d %3.2f%%\n', successCount(n), (successCount(n) / samplePointCount) * 100);
            fprintf(resultOutput, 'Failure : %4d %3.2f%%\n', failureCount(n), (failureCount(n) / (noisePointCount-samplePointCount) * 100));

            fprintf(resultOutput, '------------------------------\n');
            
        end
           
    end
    
    if GENERATE_GRAPH == 1
        
        fig1 = figure;
        set(fig1,'visible','off')
        
        xlim([ALPHA_MIN,ALPHA_MAX]);
        ylim([0,1]);
        
        scatter(1:ALPHA_MAX, (successCount / samplePointCount) * 100,5,[0 0 1], 'filled');
        hold on
        scatter(1:ALPHA_MAX, (failureCount / noisePointCount) * 100,5,[1 0 0], 'filled');
        hold off
        
        graphTitle = sprintf('Alpha Values for a K Value of %d', k);
        title(graphTitle);
        xlabel('Alpha Values');
        ylabel('Percentages');
        legend('Sample Points', 'Noisy Points');
        
        outputFilename = sprintf('Data/%s/RKNN/Results/Graphs/k = %d.png', DIRECTORY, k); % Awesome/Data/DIRECTORY/RKNN/Results/Graph/ k = 'k'
        
        saveas(fig1, outputFilename);

        rknnTime = toc(rknnStart); % End rknn timer
        
    end 
    
    if DEBUG == 1
    
        fprintf('\n');
    
    end
    
end

%% ---------- rCocone ----------

% IF MODE = RKNN or MODE = HYBRID, then run rCocone
if MODE == 2 || MODE == 3
    
    rCoconeStart = tic; % Begin rCocone timer
    
    if MODE == 2
        
        inputFilename  = sprintf('Data/%s', FILENAME_NOISE); % Awesome/Data/FILENAME_NOISE
        outputFilename = sprintf('Data/%s/RCOCONE/rcocone/output', DIRECTORY); % Awesome/Data/DIRECTORY/RCOCONE/rcocone/output

        if DEBUG == 1
            fprintf('\nSYSTEM: Running rCocone on %s\n', inputFilename);
        end
        
        str = sprintf('rcocone-win.exe %s %s', inputFilename, outputFilename);
        [~,~] = system(str); % Ignore outputs to suppress executable output

        if DEBUG == 1
            fprintf('SYSTEM: Reading from rCocone/output.surf\n');
        end
        
        
        input = sprintf('Data/%s/RCOCONE/rCocone/output.surf',DIRECTORY);
        P = readCocone(input);

        outputFilename = sprintf('Data/%s/RCOCONE/Results/pointList.txt', DIRECTORY);

        fprintf('SYSTEM: Writing to file %s\n', outputFilename);
        dlmwrite(outputFilename, P, 'delimiter', ' ', 'newline', 'pc');
       
        return;
    end
    
    if MODE == 3
        
        % For each rknn iteration, run rCocone on the RKNN_i.DATA file
        for n = 1:n
            inputFilename = sprintf('%s/%s/RKNN/k=%d,alpha=%d.DATA', DIRECTORY,strMode,k,n); %Awesome/DATAR_DIR/strMode/k=k,alpha=n
            outputFilename = sprintf('%s/%s/rCocone/output_%d', DIRECTORY,strMode,n);        %Awesome/DATA_DIR/strMODE/output_n
            
            if DEBUG == 1
                fprintf('\nSYSTEM: Running rCocone on %s\n', inputFilename);
                fprintf('SYSTEM: rCocone writing to %s\n', outputFilename);
            end
            str1 = sprintf('rcocone-win.exe %s %s', inputFilename, outputFilename);
            [~,~]=system(str1); % Ignore outputs to suppress executable output
            if DEBUG == 1
                fprintf('\nSYSTEM: Reading from %s.surf\n', outputFilename);
            end
            input = sprintf('%s.surf', outputFilename); %Awesome/DATA_DIR/strMODE/output_n.surf
            [P] = readCocone(input);
            
            outputFilename1 = sprintf('%s/%s/rCocone/alpha=%d.txt', DIRECTORY,strMode,n); %Awesome/DATAR_DIR/strMODE/rCocone/apha=n
            if DEBUG == 1
                fprintf('SYSTEM: Writing to file %s\n', outputFilename1);
            end
            dlmwrite(outputFilename1, P, 'delimiter', ' ', 'newline', 'pc');
            
            % Compare the first 5 digits of each element
            nTemp = round(noisePointList * 10000);
            pTemp = round(P * 10000);
            [~,index] = ismember(pTemp, nTemp,'rows'); % Returns a column of index locations of pTemp rows in nTemp rows

            successCount = sum(index<=samplePointCount); % Number of elements with index <= samplePointCount
            failureCount = size(P,1) - successCount;     % Otherwise

            % Output results to file
            fprintf(resultOutput, 'Alpha   : %d\n', n);
            fprintf(resultOutput, 'Points  : %d\n', size(index,1));
            fprintf(resultOutput, 'Success : %0.2f%%\n', (successCount / samplePointCount) * 100);
            fprintf(resultOutput, 'Failure : %0.2f%%\n', (failureCount / (successCount + failureCount)) * 100);

            fprintf(resultOutput, '------------------------------\n');

      
        end
        
    end
    
    rCoconeTime = toc(rCoconeStart); % End rCocone timer
    
end

%% ---------- Output Execution Times ----------
programTime = toc(programStart);

fprintf(resultOutput,'\n---------- Execution Time ----------\n');
fprintf(resultOutput,'Program Time : %0.2f seconds\n', programTime);

if MODE == 1 || MODE == 3
    
    fprintf(resultOutput,'RKNN         : %0.2f seconds\n', rknnTime);
    
end

if MODE == 2 || MODE == 3

    fprintf(resultOutput,'rCocone      : %0.2f seconds\n', rCoconeTime);

end

%% Cleanup

fclose('all');