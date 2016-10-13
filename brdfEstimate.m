function M = brdfEstimate(baseP, shp, Gamma, show)
if nargin < 4
    show = 0;
end
if nargin < 3
   Gamma = []; 
end
if iscell(baseP)
    baseP = baseP{1};
end
[GTlist, GTcoeff] = readGT(baseP);
% estimate lighting coeff from images, and compute distant of them with
% groundtruth
h = 512; w = 512;     % 渲染的groundtruth pose
gamma = 0;
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
DLcoeff = zeros(size(GTcoeff));
align.R = R;
align.P = P;

b = zeros(size(shp, 1), numel(GTlist));  % intensity at each sample point in each image
v = zeros(numel(GTlist), 9);    % GT lighting coeff for each image
M = zeros(size(shp, 1), 9);      % reflection coeff for each sample point
for k = 1:numel(GTlist)
    im = read_img([baseP, '.\', GTlist{k}, '.tiff']);
    if ~isempty(Gamma)
        im = invGamma(im, Gamma);
    end
%     im = double(im)/255;    % scale the range
%     lightingEstimate([baseP, '.\', GTlist{k}, '.tiff'], 1, align, [], '../BMM/defaultHoles.ply');
    h = size(im, 1); w = size(im, 2);
    P = align.P;
% %     instead of using triangle centers, here we begin to use vertices.
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
    b(:, k) = greyf(:, 2);  % only take G channel
    v(k, :) = GTcoeff(:, 2, k)';
    if k == 22
        if show == 1
            temp= [0 1;1 0];   % to image coord
            vt2d = round(vt2d*temp);
            figure, imshow(im); hold on;
            plot(vt2d(:, 1), vt2d(:, 2), 'g.');
        end
    end
end
for k = 1:size(b, 1)
    temp = (v'*v)\v'*b(k, :)';
    M(k, :) = temp';
end