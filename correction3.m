function result = correction3(im, draw, fov)
% 不同于correction2.m fix intrinsic, estimate both R, t。在
% correction3.m这里，利用了IntraFace提供的pose中的rot，fix了intrinsic & rotation,
% 只estimate t。感觉这种方法对齐的效果也很好，或者更好
% clc;
% clear all;
% close all;
if nargin == 1
    draw = 0; 
    fov = 53;   % equal to f = max(size(im));
end
if nargin == 2
    fov = 53;
end
addpath('D:\allProjects\toolBox\toolbox_graph');
addpath('D:\allProjects\toolBox\xml_io_tools');
im = im(:,:,1:3);

[DM,TM,option] = xx_initialize;
[pred,pose] = xx_track_detect(DM,TM,im,[],option);
if isempty(pred)
    result = [];
    return;
end

% index2 = [20 23 26 29 15 17 19 32 38]';
index2=[11:14 15 17 19 20:31 32 35 38 41];
% index2 = 1:49;
if draw == 1
    figure;
    imshow(im);
    hold on;
    plot(pred(index2,1), pred(index2,2), 'r.');%图像平面坐标,起点左上角，水平为x轴，垂直为y轴
end
plyfile = 'D:\allProjects\3D from Image ww\BMM\default.ply';
ppfile = 'D:\allProjects\3D from Image ww\BMM\11_feature_points\default_picked_points.pp';
[shp, tl] = read_ply(plyfile);
xml = xml_read(ppfile);
pt = zeros(size(xml.point, 1), 3);      %没有3d点的序号这一项
for i = 1:size(pt, 1)
    pt(i, 1) = xml.point(i).ATTRIBUTE.x;
    pt(i, 2) = xml.point(i).ATTRIBUTE.y;
    pt(i, 3) = xml.point(i).ATTRIBUTE.z;
end
X = pt(index2, :);
h=size(im,1);
M = [1 0;0 -1];
% pred = marker;   % Hathaway_marked1493.jpg 上的准确关键点位置，即Hathaway_picked_marker对应的2d点。
pred = pred*M; %plot坐标->图像物理坐标
pred(:,2)=pred(:,2)+h;%原点左下角，水平x轴，垂直y轴

%http://blog.csdn.net/b5w2p0/article/details/8804216
x=[pred(index2,:),ones(length(index2),1)];
X=[X,ones(size(X,1),1)];
%已知内参数矩阵
% f = max(size(im)); 
% f = 1067;
f = max(size(im))/2/tand(fov/2);
u0 = size(im, 2)/2;
v0 = size(im, 1)/2;
K = [f 0 u0; 0 f v0; 0 0 1];
R1 = [1 0 0; 0 -1 0; 0 0 1];        % R1 是从IntraFace定义的旋转参考坐标（见 xx_track_detect 中我的注释）到相机坐标系的变
theta = 11.83;          % 这个角是测量的经验值，在pbrt中俯仰人头，让IntraFace测出的pose为正冲前
R2 = [1 0 0; 0 cosd(theta) -sind(theta); 0 sind(theta) cosd(theta)];    % R2 是Face Gen的坐标到IntraFace定义的物体坐标见的变换，FaceGen的人头总是微微抬起的。。。
R = R1*pose.rot*R2;        % pose.rot是IntraFace定义的物体坐标系到IntraFace定义的参考坐标的变换

[P,K,R,t,mse]=ComputeProjection_fix_R_intrisic(X, x, K, R, 0.05, 500);      % R不是单纯的旋转，还包括z轴的翻转。因为世界坐标为右手系，相机坐标系为左手

result.P = P;
result.K = K;
result.R = R;
result.t = t;
result.mse = mse;
%%
if draw == 1
    shpp=[shp,ones(size(shp,1),1)];
    clr = [0; 255; 0];      % 控制点云颜色
    tex = repmat(clr, size(shpp,1), 1);     
    % tex = ones(size(shpp, 1)*3, 1)*255;     
    im_re=reProjection(shpp,tex,im,P);     %投影点云（稀疏）显示效果，速度较快
    % [im_re,Zc_re]=Rendering(X,reshape(tex, [ 3 numel(tex)/3])',im,K,R,t,model.tl);  % dense投影显示效果，速度较慢。
    figure;
    imshow(im_re);
    loc    = [70 70]; % where to draw head pose
    l = 60;
    po = [0,0,0; l,0,0; 0,l,0; 0,0,l];
    p2D = po*pose.rot(1:2,:)';
    hold on;
    plot([p2D(1,1) p2D(2,1)]+loc(1),[p2D(1,2) p2D(2,2)]+loc(2), 'r');
    plot([p2D(1,1) p2D(3,1)]+loc(1),[p2D(1,2) p2D(3,2)]+loc(2), 'g');
    plot([p2D(1,1) p2D(4,1)]+loc(1),[p2D(1,2) p2D(4,2)]+loc(2), 'b');
end