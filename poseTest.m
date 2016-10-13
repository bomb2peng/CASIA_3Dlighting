close all;
load('D:\allProjects\3Dlighting_standalone\datasets\Hathaway\model\dataset_textured\archive.mat');
baseP = 'D:\allProjects\3Dlighting_standalone\datasets\Hathaway\model\dataset_textured';
% % read groundtruth .out files and file name list in tons2/
[GTlist, GTcoeff] = readGT(baseP);
h = 512; w = 512;
plyfile = '.\datasets\Hathaway\model\meshLab\model.ply';           % complete head mesh
addpath('D:\allProjects\toolBox\toolbox_graph');
[shp, tl] = read_ply(plyfile);
indLandMarks = load('.\land_mark_indices.txt');
indLandMarks = indLandMarks + 1;
for i = 1
    display(sprintf('%d/%d...\n', i, numel(GTlist)));
    idx = GTlist{i};
    imName = [baseP, '\', idx, '.tiff'];
    im = imread(imName);
    im = im(:,:,1:3);
    
    zflip = [1 0 0; 0 1 0; 0 0 -1];     % 相机坐标系和世界坐标系z轴相反
    fov = 25;
%  GT 的外参矩阵   
    alpha = poselist(i, 1);
    Ry = [cosd(alpha), 0, sind(alpha);...
        0, 1, 0;...
        -sind(alpha), 0, cosd(alpha)];
    beta = 15+poselist(i, 2);   % 15°的偏置
    Rx = [1, 0, 0;...
        0, cosd(beta), -sind(beta);...
        0, sind(beta), cosd(beta)];
    R = zflip*Ry*Rx;        % （这里应该是 Rx*Ry， 不要弄错顺序。）15.7.9:应该是 Ry*Rx, 之前弄错了。
    t = [0; 0; 800];
    f = w/2/tand(fov/2);
    K = [f 0 w/2; 0 f h/2; 0 0 1];
    P = K*[R t];
    Galign.R = R;
    Galign.P = P;
    showPose(im, Galign, shp);
%   Estimate 的外参矩阵     
    landMarks = shp(indLandMarks, :);
    align = correction(im, fov, landMarks, 1);
    if isempty(align)
        continue;
    end
    showPose(im, align, shp);
end