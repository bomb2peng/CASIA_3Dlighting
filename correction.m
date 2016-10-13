function result = correction(im, fov, pt, draw, pred)
% based on correction2.m, pruned to only output alignment parameters.
if nargin < 5 pred = []; end
if nargin < 4 draw = 0; end
if nargin < 2 fov = 53; end
im = im(:,:,1:3);

if isempty(pred)
    [DM,TM,option] = xx_initialize;
    [pred,pose] = xx_track_detect(DM,TM,im,[],option);  % use intraFace detector to detect 49 facial landmarks
elseif all(pred(:) == 0)
    pred = [];
end
if isempty(pred)
    result = [];
    return;
end
% % index2 = [20 23 26 29 15 17 19 32 38]';
% index2=[11:14 15 17 19 20:31 32 35 38 41];
index2 = 1:49;
if draw == 1
    figure;
    imshow(im);
    hold on;
    plot(pred(index2,1), pred(index2,2), 'r.');%图像平面坐标,起点左上角，水平为x轴，垂直为y轴
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
[P,K,R,t,mse,angle]=ComputeProjection_fix_intrinsic(X, x, K, 0.05, 500);      % R不是单纯的旋转，还包括z轴的翻转。因为世界坐标为右手系，相机坐标系为左手
% h = size(im, 1); w = size(im, 2);     % 渲染的groundtruth pose
% gamma = -15*pi/180;
% Rx = [1, 0, 0;...
%     0, cos(gamma), -sin(gamma);...
%     0, sin(gamma), cos(gamma)];
% R = Rx; R(:, 3) = -R(:, 3);
% t = [0; 0; 800];
% fov = 25;
% f = w/2/tand(fov/2);
% K = [f 0 w/2; 0 f h/2; 0 0 1];
% P = K*[R t];

result.P = P;
result.K = K;
result.R = R;
result.t = t;
result.mse = mse;
result.angle = angle;   % angle代表的是物体和相机坐标系（Cw&Cc）都是左手系时，相机坐标系转到物体坐标系依次按照x, y, z转动的角度。
% %% 迭代优化
% K0 = K
% t0 = t
% for i = 1:50
%     ff(i) = K(1,1);
%     msee(2*i-1) = mse;
%     [P,K,R,t,mse]=ComputeProjection_fix_R(X, x, K, R, t, 0.05, 500); 
%     msee(2*i) = mse;
%     [P,K,R,t,mse]=ComputeProjection_fix_intrinsic(X, x, K, 0.05, 500);
% end
% shpp=[shp,ones(size(shp,1),1)];
% im_re=reProjection(shpp,tex,im,P);     %投影点云（稀疏）显示效果，速度较快
% % [im_re,Zc_re]=Rendering(X,reshape(tex, [ 3 numel(tex)/3])',im,K,R,t,model.tl);  % dense投影显示效果，速度较慢。
% figure;
% imshow(im_re);
% figure;
% plot(ff);
% figure, plot(msee);
%% 储存ply模型
% shp_cam = R * shp';
% shp_cam(3,:)=-shp_cam(3,:); %相机坐标系是左手规则，在ply中显示时需要翻转
% plywrite('2.ply', shp_cam, tex, tl );