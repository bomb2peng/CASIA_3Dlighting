function greyf = weightLU(im, shp, show)
% 从 ambient 图片中 look up 每一个采样点的 RGB value，作为原Farid 方法M矩阵每一行的权重。考虑了纹理信息。
if nargin < 3
    show = 0;
end
h = 512; w = 512;     % 渲染的groundtruth pose
gamma = 15;
Rx = [1, 0, 0;...
    0, cosd(gamma), -sind(gamma);...
    0, sind(gamma), cosd(gamma)];
zflip = [1 0 0; 0 1 0; 0 0 -1];
R = zflip*Rx;
t = [0; 0; 800];
fov = 25;
f = w/2/tand(fov/2);
K = [f 0 w/2; 0 f h/2; 0 0 1];
P = K*[R t];

vt2d = (P*[shp, ones(size(shp,1), 1)]')';
vt2d = vt2d./repmat(vt2d(:,3), 1, 3);
vt2d = vt2d(:,1:2);
vt2d(:,2)=vt2d(:,2)-h;
temp= [0 1;-1 0];%转换为矩阵坐标
vt2d = round(vt2d*temp);
greyf = zeros(size(vt2d, 1), 3);
for i = 1:size(greyf, 1)
    greyf(i, :) = im(vt2d(i,1), vt2d(i,2), :);
end
if show == 1
    temp= [0 1;1 0];   % to image coord
    vt2d = round(vt2d*temp);
    figure, imshow(im); hold on;
    plot(vt2d(:, 1), vt2d(:, 2), 'g.');
end