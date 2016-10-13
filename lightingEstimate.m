function v = lightingEstimate(im, draw, align, M, shp, tl, Gamma)
if nargin < 7 Gamma = []; end   % Gamma correction
if nargin < 4 M = []; end
if nargin < 2 draw = 0; end

if ~isempty(Gamma)
    im = invGamma(im, Gamma);
end
h = size(im, 1); w = size(im, 2);
P = align.P;
R = align.R;
% compute trangle center normals and intensity 
[normal,~] = compute_normal(shp,tl);
R1 = R;
R1(3,:) = -R(3,:);
normal = R1*normal;   % normal vectors in a coordinate system facing right to the camera.
normal = normal';
flag = [];
for i = 1:size(normal, 1)      % 找到法向量z为负数的三维点，这些点一定是被遮挡的点，看不到，删掉。可以视为除zbuffer外的另一种消隐算法。这种方法应该只对非凹的物体适用。多个物体有前后遮挡的不适用。
    if normal(i, 3) < 0
        flag = [flag; i];
    end
end
normal(flag, :) = [];
shp(flag, :) = [];
if draw == 1
    reProjectionNormal(shp, normal, 0, P, im);     %投影三角形中心以及法向量，函数里plot
end
vt2d = (P*[shp, ones(size(shp,1), 1)]')';
vt2d = vt2d./repmat(vt2d(:,3), 1, 3);
vt2d = vt2d(:,1:2);
vt2d(:,2)=vt2d(:,2)-h;
temp= [0 1;-1 0];%转换为矩阵坐标
vt2d = round(vt2d*temp);
greyf = zeros(size(shp, 1), 3);
ind = sub2ind(size(im), vt2d(:,1), vt2d(:,2)); 
for i = 1:3
   temp = im(:,:,i);
   greyf(:,i) = temp(ind);
end
if isempty(M)
    M = Mcoeff(normal');
else
    if size(M, 2) == 9          % 传入的是拟合的 transfer coefficients
        M(flag, :) = [];
    elseif size(M, 2) == 3      % 传入的是给 Farid's 方法加权的权重，即 Farid 方法考虑纹理
        weight = M(:, 2);       % 只是用 G 通道的系数
        weight(flag, :) = [];
        M = Mcoeff(normal');
        M = repmat(weight, 1, 9).*M;
    end
end
b = greyf;
v = zeros(9, 3);    % This calculated lighting direction's coordinate system is the world coordinate attached to the head. That's x to the right, y to the up, z to outside.
for i = 1:3
    v(:, i) = (M'*M)\M'*b(:, i);
end