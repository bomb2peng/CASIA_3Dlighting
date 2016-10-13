function v = lightingEstimateRANSAC(vertex, tri, tex, valid_bin, img, lambda, M, show, harmonic_order, align, RANSACpara)
% % input vertex, tex, tri: 3xn, 3xm
% % input M: n x 9
% % input align: structure with projection matrix P and rotation matrix R
% % The input mesh model is in its own object coord, not world coord.
if nargin < 7
    M = [];
end
if nargin < 8
    show = false;
end
if nargin < 9
    harmonic_order = 2;
end
if isempty(valid_bin)
    valid_bin = 1;
end
harmonic_dim = (harmonic_order+1)^2;
chann = 2;  % only use G channel for estimation
[height, width, nChannels] = size(img);
pt2d = align.P*[vertex; ones(1, size(vertex, 2))];
if sum(align.P(3,:)) ~= 0
    pt2d = pt2d(1:2, :)./repmat(pt2d(3, :), 2, 1);
else                        % orthogonal projection
    pt2d = pt2d(1:2, :);
end
pt2d(2,:) = height-pt2d(2,:);     % projected vertex coords in image frame.
pt2d(1,:) = min(max(pt2d(1,:),1),width);
pt2d(2,:) = min(max(pt2d(2,:),1),height);
pt2d = round(pt2d);
ind = sub2ind([height,width], pt2d(2,:), pt2d(1,:));

tex_pixel = zeros(size(vertex));
for i = 1:nChannels
    temp = img(:,:,i);
    tex_pixel(i,:) = double(temp(ind));     %pb: tex_pixel is each vertex's texture in the image.
end

M0 = M;
norm = NormDirection(vertex, tri); 
% [norm,normalf] = compute_normal(vertex',tri');
zflip = [1 0 0; 0 1 0; 0 0 -1];     % 相机坐标系和世界坐标系z轴相反
normR = zflip*align.R*norm;        % norm in the coord frame facing right to the camera.
flag = ones(size(normR, 2), 1);
for i = 1:size(normR, 2)      % 找到法向量z为负数的三维点，这些点一定是被遮挡的点，看不到，删掉。可以视为除zbuffer外的另一种消隐算法。这种方法应该只对非凹的物体适用。多个物体有前后遮挡的不适用。
    if normR(3, i) < 0
        flag(i) = 0;
    end
end
flag = logical(flag);
valid_bin = valid_bin & flag;
normR = normR(:, valid_bin);
vertex0 = vertex;
vertex = vertex(:, valid_bin);
norm = norm(:, valid_bin);
if isempty(M0)
    M = Mcoeff(normR, harmonic_order);   % coeffs matrix， M*v=b
    if show
        scale = round(log10(range(vertex(1,:))));
        reProjectionNormal(vertex', norm', 8*10^(scale-2), align.P, img)
    end
else
    M = M(valid_bin, :);
end
if isempty(tex)
    texModulate = ones(size(vertex, 2), harmonic_dim);      % use uniform texture.
else
    texModulate = repmat(tex(chann,:)', 1, harmonic_dim);  % use mean texture to modulate transfer coeffs.
end
M = M.*texModulate;
b = tex_pixel(chann,valid_bin)';
Regular_Matrix = lambda * eye(harmonic_dim);   
idx = [];
if isempty(M0) && harmonic_order >= 3 && lambda == 0
    for i = 3:2:harmonic_order      % these orders are all 0 in the half consine SH coeffs.
        idx = [idx, (i^2+1):(i+1)^2];
    end
    for i = 1:numel(idx)
        Regular_Matrix(idx(i), idx(i)) = 1;     % to prevent singular matrix
    end
end

% % RANSAC
% set RANSAC options
options.epsilon = 1e-6;
options.P_inlier = 0.99;
options.sigma = RANSACpara.sigma;
options.est_fun = @estimate_light_RANSAC;
options.man_fun = @error_light_RANSAC;
% options.mode = 'MSAC';
options.mode = 'RANSAC';
options.min_iters = 500;
options.fix_seed = false;
options.reestimate = true;
options.stabilize = false;
if ~isempty(RANSACpara.verbose)
    options.verbose = RANSACpara.verbose;
else
    options.verbose = true;
end
options.parameters = RANSACpara.parameters;
% form the input data pairs
X = [b'; M'];         % only green channel
% run RANSAC
[result, options] = RANSAC(X, options);
v = result.Theta;
% % re-estimate again
b(result.CS == 0, :) = [];
M(result.CS == 0, :) = [];
v = (M'*M)\M'*b;

if v(1) > 0      %可能要加 光照的非负约束。
    v = v./v(1);
elseif v(1) < 0
    v = -v./v(1);
    disp('ATTENTION NEGTIVE V!');
end

if show
    valid_idx = find(valid_bin);
    valid_bin(valid_idx(result.CS == 0)) = false;
    zflip = [1 0 0; 0 1 0; 0 0 -1];     % 相机坐标系和世界坐标系z轴相反
    vertexR = zflip*align.R*vertex0;        % norm in the coord frame facing right to the camera.
    figure; DrawTextureHead(vertexR, tri, tex_pixel.*repmat(valid_bin', 3, 1));
    view(0, 90);
    
    scale = round(log10(range(vertex(1,:))));
    vertex = vertex(:, result.CS == 1);
    norm = norm(:, result.CS == 1);
    reProjectionNormal(vertex', norm', 8*10^(scale-2), align.P, img)
end

end