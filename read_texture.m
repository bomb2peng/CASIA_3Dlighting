function tex = read_texture(objP, show)
% % Read the texture of a FaceGen model's texture image.
if nargin < 2
    show = false;
end
addpath('..\toolBox\woBJ_toolbox_Version2b\');
OBJ=read_wobj(fullfile(objP, 'model.obj'));
FV.vertices=OBJ.vertices;
FV.faces=OBJ.objects(5).data.vertices;
im = imread(fullfile(objP, 'model.jpg'));
[~, temp, ~] = unique(OBJ.objects(5).data.vertices(:));
texIdx = OBJ.objects(5).data.texture(temp);
texUV = OBJ.vertices_texture(texIdx, :);
texUV = max(min(texUV,1),0).*repmat([size(im, 2)-1, size(im, 1)-1], size(texUV, 1), 1);
texUV = round([texUV(:,2), texUV(:,1)])+1;    % in matrix coord
texUV(:,1) = size(im, 1)+1-texUV(:,1);
imIdx = sub2ind([size(im,1), size(im,2)], texUV(:,1), texUV(:,2));
tex = zeros(numel(imIdx), 3);
for i = 1:3
    temp = im(:,:,i);
    tex(:,i) = temp(imIdx);
end
tex = double(tex)/255;
if show
    FV.FaceVertexCData = tex;
    figure, patch(FV, 'facecolor', 'interp', 'edgecolor', 'interp');
    axis equal;
    axis vis3d;
end