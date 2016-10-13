% % This file shows the visibility sphere at a point on obj.
% % First pick intristing point on 3d face plot, get the index - n.
% % renderModel(vertexR', triDown', DLcoeff2(:,1,i), transferCoeffs);
% wi = load('.\obj\visibility_wi.txt');
% vis = load('.\obj\visibility_vis.txt');
flag = 1;       % 1: show masked cos(theta) function.  0: only show visibiliy funciton
n = findVertex(vertexR, cursor_info.Position);
% n = 1;
verts = reshape(wi(n, :), 3, size(wi, 2)/3);
verts = verts';
% faces = delaunay(verts(:,1), verts(:, 2), verts(:,3));
addpath('D:\allProjects\toolBox\TriangulateSphere');
faces = TriangulateSpherePoints(verts);
c = vis(n, :);
if flag == 1
    norm = NormDirection(vertexR, triDown);
    normV = norm(:, n);
    c = c'.*(verts*normV);
end
figure, trisurf(faces, verts(:,1), verts(:,2), verts(:,3), c, 'faceColor', 'inter', 'edgeColor', 'none');
% figure, plot3(verts(:,1), verts(:,2), verts(:,3));
colormap gray
axis equal vis3d
xlabel('x'); ylabel('y'); zlabel('z');