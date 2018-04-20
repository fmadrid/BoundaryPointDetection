[S, SCOUNT]  = readData('Data/PointLists/sample5_geniculate_v2/right_medial_geniculate_body_Vertices.txt', 3, 'exponential');
[N, NCOUNT]  = readData('Data/PointLists/sample5_geniculate_v2/noisy_version_geniculate_v2.txt', 3, 'exponential');
[P, PCOUNT]  = readData('Data/Geniculate2/RKNN/rknn/k=26,alpha=23.DATA', 3, 'float');
%[N2, N2COUNT]  = readData('Data/Nucleus/RCOCONE/Results/n=1.DATA',3, 'float');
inS = ismemberf(P, S, 'tol', 1E-3);
inN = ismemberf(P, N,  'tol', 1E-3);

T = sum(transpose(inS));
T = transpose((T == 3));
R = ((T ~= 1));
%S = P(T,:);
N = P(R,:);

%N = N([687:917],:);
figure
%set(findall(gcf,'type','text'),'FontSize',30,'fontWeight','bold')
%axis equal
axis([-19 -11 -79 -72 1538 1550]);
hold on
scatter3(S(:,1),S(:,2),S(:,3),3,'filled','black');
%scatter3(N(:,1),N(:,2),N(:,3),10,'filled','red');
print('test','-dpng');