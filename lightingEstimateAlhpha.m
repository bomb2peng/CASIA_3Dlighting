function v = lightingEstimateAlhpha(im, vertex, tri, align, valid_bin, draw, ...         % obligatory params
                                    Tcoeff, tex, lambda, harmonic_order, mask)    % optional params
% input im: h x w x 3 unit8 image.
% input vertex, tri: nvertex x 3, ntri x 3
% input align: structure with R,t,K,P...
% input valid_bin: nvertex x 1 logical.
% input draw: logical
% input Tcoeff: nvertex x nharmonic(default 9)
% input tex: nvertex x 3, texture.
% input lambda: regulation number.
% harmonic_order: default 2.
% mask: user specified mask image
if nargin < 7;    Tcoeff = []; end
if nargin < 8;    tex = []; end
if nargin < 9;    lambda = 0; end
if nargin < 10;    harmonic_order = 2; end
if nargin < 11;   mask = []; end

nharm = (harmonic_order+1)^2;
h = size(im, 1); w = size(im, 2);
P = align.P;
R = align.R;
% compute trangle center normals and intensity 
[normal,~] = compute_normal(vertex,tri);
R1 = R;
R1(3,:) = -R(3,:);
normal = R1*normal;   % normal vectors in a coordinate system facing to the camera.
normal = normal';

vt2d = (P*[vertex, ones(size(vertex,1), 1)]')';
if sum(P(3,:)) ~= 0
    vt2d = vt2d./repmat(vt2d(:,3), 1, 3);
    vt2d = vt2d(:,1:2);
else                        % orthogonal projection
    vt2d = vt2d(:,1:2);
end
vt2d(:,2)=vt2d(:,2)-h;
temp= [0 1;-1 0];%转换为矩阵坐标
vt2d = round(vt2d*temp);
vt2d(:,1) = min(max(vt2d(:,1),1),h);
vt2d(:,2) = min(max(vt2d(:,2),1),w);
greyf = zeros(size(vertex, 1), 3);
ind = sub2ind(size(im), vt2d(:,1), vt2d(:,2)); 
% % ind = sub2ind([h, w], vt2d(:,1), vt2d(:,2)); 
for i = 1:3
   temp = im(:,:,i);
   greyf(:,i) = temp(ind);
end

mask_pixel = 255*ones(size(ind));
if ~isempty(mask)
    temp = mask(:,:,1);
    mask_pixel = temp(ind);
    mask_pixel(mask_pixel~=255) = 0;
end
mask_pixel = logical(mask_pixel);

if isempty(valid_bin)   % if not providing the mask of z-buffer, use a simple version z-buffer dependent on normals.
    valid_bin = ones(size(vertex, 1), 1);
    flag = [];
    for i = 1:size(normal, 1)      % 找到法向量z为负数的三维点，这些点一定是被遮挡的点，看不到，删掉。可以视为除zbuffer外的另一种消隐算法。这种方法应该只对非凹的物体适用。多个物体有前后遮挡的不适用。
        if normal(i, 3) < 0
            flag = [flag; i];
        end
    end
    valid_bin(flag) = 0;
    valid_bin = logical(valid_bin);
end
valid_bin = valid_bin & mask_pixel;

normalV = normal(valid_bin, :);
vertexV = vertex(valid_bin, :);
if draw
    scale = round(log10(range(vertexV(:, 1))));
    reProjectionNormal(vertexV, normalV, 5*10^(scale-2), P, im);     %投影三角形中心以及法向量，函数里plot
end

greyfV = greyf(valid_bin, :);
if draw
    zflip = [1 0 0; 0 1 0; 0 0 -1];     % 相机坐标系和世界坐标系z轴相反
    vertexR = transpose(zflip*align.R*vertex');        % norm in the coord frame facing right to the camera.
    temp = double(greyf)/255.*repmat(valid_bin, 1, 3);
%     temp = repmat(temp(:,2), 1,3);
    figure; DrawTextureHead(vertexR', tri', temp');
    view(0, 90);
end

if isempty(Tcoeff)
    Tcoeff = Mcoeff(normalV', harmonic_order);
else
    Tcoeff = Tcoeff(valid_bin, :);
end
if ~isempty(tex)        % modulate by texture
    tex = tex(valid_bin,:);
    tex = tex(:,2);     % only use G channel
    Tcoeff = repmat(tex, 1, nharm).*Tcoeff;
end

Regular_Matrix = lambda * eye(nharm);    % regulation matrix

b = greyfV;
v = zeros(nharm, 3);    % This calculated lighting direction's coordinate system is the world coordinate attached to the head. That's x to the right, y to the up, z to outside.
for i = 1:3
    v(:, i) = (Tcoeff'*Tcoeff + Regular_Matrix)\Tcoeff'*b(:, i);
end