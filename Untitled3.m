outputFilename   = sprintf('Data/PointLists/sample2_geniculate_v1/right_medial_geniculate_body_Vertices.txt');
[Points, samplePointCount]  = readData(outputFilename, 3, 'exponential');

X=Points(:,1);
Y=Points(:,2);
Z=Points(:,3);

fig1 = figure;
set(fig1,'visible','off')

scatter3(X,Y,Z,4,'filled','black');
grid off;
axis off;
axis vis3d;
zoom(2)
camorbit(5,0);
print('test3','-dpng');
