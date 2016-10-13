function M = brdfEstimateOrth(baseP, shp, Gamma, show)
% % 正交投影
% % input shp: 3xn, vertices
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
s = w/3.6;        % orthoganal projection scale
projectM = [s, 0 w/2;
            0, s, w/2];
vertexP = projectM*[shp(1:2, :); ones(1, size(shp, 2))];
vertexP(2, :) = w - vertexP(2,:);

b = zeros(size(shp, 2), numel(GTlist));  % intensity at each sample point in each image.
v = zeros(numel(GTlist), 9);    % GT lighting coeff for each image
M = zeros(size(shp, 2), 9);      % reflection coeff for each sample point
for k = 1:numel(GTlist)
    im = read_img([baseP, '.\', GTlist{k}, '.tiff']);
%     im = double(im)/255;
    if ~isempty(Gamma)
        im = invGamma(im, Gamma);
    end
    temp= [0 1;1 0];%转换为矩阵坐标
    vt2d = round(vertexP'*temp);
    temp = sub2ind([h, w], vt2d(:,1), vt2d(:,2));
    greyf = im(:, :, 2);
    b(:, k) = greyf(temp);  % only take G channel
    v(k, :) = GTcoeff(:, 2, k)';
    if k == 22
        if show == 1
            figure, imshow(im); hold on;
            temp= [0 1;1 0]; % to image coord
            vt2d = vt2d*temp;
            plot(vt2d(:,1), vt2d(:,2), 'g.');
        end
    end
end
for k = 1:size(b, 1)
    temp = (v'*v)\v'*b(k, :)';
    M(k, :) = temp';
end