[S, SCOUNT]  = readData('Data/PointLists/sample3_suprachiasmatic_v1/right_suprachiasmatic_nucleus_Vertices.txt', 3, 'exponential');
%[N, NCOUNT]  = readData('Data/PointLists/sample1_sphere_v1/noisy_version_sphere_v1.txt', 3, 'exponential');
%[B, BCOUNT]  = readData('Data/Geniculate/RKNN/rknn/k=9,alpha=8.DATA', 3, 'float');
% [B, BCOUNT] = readData('Data/Nucleus/RCOCONE/Results/n=1.DATA',3, 'float');
% inS = ismemberf(B, S, 'tol', 1E-3);
% inN = ismemberf(B, N,  'tol', 1E-3);

% T = sum(transpose(inS));
% T = transpose((T == 3));
% R = ((T ~= 1));
% S = B(T,:);
% N = B(R,:);

%N = N(2563:3010,:);
%h = figure;
scatter3(S(:,1),S(:,2),S(:,3),3,'filled','black');
hold all;
grid off;
%axis equal;
%hold all;
%scatter3(N(:,1),N(:,2),N(:,3),20,'filled','red');