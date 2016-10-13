% % This file is a single test and show on a synthetic image.
% close all;
addpath('D:\allProjects\toolBox\toolbox_graph');
% baseP = fullfile(pwd, '.\datasets\Hathaway\model');
baseP = fullfile(pwd, '.\datasets\TIFS_synthetic\TexturedFace');
dataP = fullfile(baseP, '.\dataset_textured');
load(fullfile(dataP, 'archive.mat'));
% % read groundtruth .out files
disp('loading groundtruth lighting coeffs...');
[GTlist, GTcoeff] = readGT(dataP);
SHrot = sym(['[1 0 0 0 0 0 0 0 0;',...
    '0 r22 r32 r12 0 0 0 0 0;',...
    '0 r23 r33 r13 0 0 0 0 0;',...
    '0 r21 r31 r11 0 0 0 0 0;',...
    '0 0 0 0 r11*r22+r12*r21 r21*r32+r22*r31 sqrt(3)*r31*r32 r11*r32+r12*r31 r11*r12-r21*r22;',...
    '0 0 0 0 r12*r23+r13*r22 r22*r33+r23*r32 sqrt(3)*r32*r33 r12*r33+r13*r32 r12*r13-r22*r23;',...
    '0 0 0 0, -1/sqrt(3)*(r11*r21+r12*r22)+2/sqrt(3)*r13*r23, -1/sqrt(3)*(r21*r31+r22*r32)+2/sqrt(3)*r23*r33, -1/2*(r31^2+r32^2)+r33^2, -1/sqrt(3)*(r11*r31+r12*r32)+2/sqrt(3)*r13*r33, -1/2/sqrt(3)*(r11^2+r12^2)+1/sqrt(3)*r13^2+1/2/sqrt(3)*(r21^2+r22^2)-1/sqrt(3)*r23^2;',...
    '0 0 0 0 r11*r23+r13*r21 r21*r33+r23*r31 sqrt(3)*r31*r33 r11*r33+r13*r31 r11*r13-r21*r23;',...
    '0 0 0 0 r11*r21-r12*r22 r21*r31-r22*r32 sqrt(3)/2*(r31^2-r32^2) r11*r31-r12*r32 1/2*(r11^2-r12^2-r21^2+r22^2)]']);
h = 512; w = 512;
plyfile = fullfile(baseP, '.\meshLab\model.ply');            % complete head mesh
indLandMarks = load('.\land_mark_indices.txt');
indFrontalFace = load('.\frontal_face_indices.txt');
indLandMarks = indLandMarks + 1;
indFrontalFace = indFrontalFace + 1;
[shp, tl] = read_ply(plyfile);
frontalMask = zeros(size(shp, 1), 1);
frontalMask(indFrontalFace) = 1;
frontalMask = logical(frontalMask);
shpF = shp(frontalMask, :); % vertices of frontal face
temp = frontalMask(tl);
temp = temp(:,1)&temp(:,2)&temp(:,3);
tlF0 = tl(temp, :);  % triangle list of frontal face, indexed using shp
temp = zeros(size(shp, 1), 1);
for i = indFrontalFace'
    temp(i) = sum(frontalMask(1:i));
end
tlF = temp(tlF0);   % triangle list of frontal face, indexed using shpF

DLcoeff1 = zeros(size(GTcoeff));
DLcoeff2 = zeros(size(GTcoeff));
DLcoeff3 = zeros(size(GTcoeff));
DLcoeff4 = zeros(size(GTcoeff));
distDL1 = zeros(numel(GTlist), 1);
distDL2 = zeros(numel(GTlist), 1);
distDL3 = zeros(numel(GTlist), 1);
distDL4 = zeros(numel(GTlist), 1);
disp('fitting transfer coeffs...');
M_grey = brdfEstimate(fullfile(baseP, '.\fitting_untextured'), shpF, [], 0);
M_texture = brdfEstimate(fullfile(baseP, '.\fitting_textured'), shpF);
im = read_img(fullfile(baseP, 'ambient.tiff'));
texture = weightLU(im, shpF, 0);
for i = 1
    display(sprintf('%d/%d...\n', i, numel(GTlist)));
    idx = GTlist{i};
    imName = [dataP, '\', idx, '.tiff'];
    im = read_img(imName);
    
     %  GT 的外参矩阵 
    [height, width, nChannels] = size(im);
    zflip = [1 0 0; 0 1 0; 0 0 -1];     % 相机坐标系和世界坐标系z轴相反
    fov = 25;
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
    f = width/2/tand(fov/2);
    K = [f 0 width/2; 0 f height/2; 0 0 1];
    P = K*[R t];
    Galign.R = R;
    Galign.P = P;
    align = Galign;

%     zflip = [1 0 0; 0 1 0; 0 0 -1];     % 估计pose时，只保留这两行。
%     fov = 25;
%     landMarks = shp(indLandMarks, :);
%     align = correction(im, fov, landMarks, 0);

%     showPose(im, align, shp);
    if isempty(align)
        continue;
    end
    RR = inv(zflip\align.R);
    
    for ii = 1:3
        for jj = 1:3
            eval(['r',num2str(ii), num2str(jj), '=RR(ii, jj);']);
        end
    end
    temp = eval(SHrot)*M_grey';
    M1 = temp';
    temp = eval(SHrot)*M_texture';
    M2 = temp';
    DLcoeff1(:,:,i) = lightingEstimate(im, 1, align, [], shpF, tlF, 1);     
    DLcoeff2(:,:,i) = lightingEstimate(im, 0, align, M1, shpF, tlF);
    DLcoeff3(:,:,i) = lightingEstimate(im, 0, align, texture, shpF, tlF);
    DLcoeff4(:,:,i) = lightingEstimate(im, 0, align, M2, shpF, tlF);
    distDL1(i) = Dist(DLcoeff1(:,1,i), GTcoeff(:,1,i));      % DLcoeff与GTcoeff中的排序方式不同
    distDL2(i) = Dist(DLcoeff2(:,1,i), GTcoeff(:,1,i));
    distDL3(i) = Dist(DLcoeff3(:,1,i), GTcoeff(:,1,i));
    distDL4(i) = Dist(DLcoeff4(:,1,i), GTcoeff(:,1,i));
    distDL1(i)
    distDL2(i)
    distDL3(i)
    distDL4(i)
    shpFR = transpose(zflip*align.R*shpF');
    renderModel(shpFR, tlF, DLcoeff1(:,1,i), [], 0);
%     renderModel(shpFR, tlF, DLcoeff2(:,1,i), M1);
%     renderModel(shpFR, tlF, DLcoeff3(:,1,i), texture);
    renderModel(shpFR, tlF, DLcoeff4(:,1,i), M2);
    plotSHcoeffs(3, GTcoeff(:,1,i));
    plotSHcoeffs(3, DLcoeff1(:,1,i));
%     plotSHcoeffs(3, DLcoeff2(:,1,i));
%     plotSHcoeffs(3, DLcoeff3(:,1,i));
    plotSHcoeffs(3, DLcoeff4(:,1,i));
end
