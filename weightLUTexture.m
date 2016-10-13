% % get the texture from an ambient illuminated face.
addpath('D:\allProjects\toolBox\toolbox_graph');
baseP = fullfile(pwd, '.\datasets\TIFS_synthetic\TexturedFace');
dataP = fullfile(baseP, '.\dataset_textured');
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
for j = indFrontalFace'
    temp(j) = sum(frontalMask(1:j));
end
tlF = temp(tlF0);   % triangle list of frontal face, indexed using shpF
im = read_img(fullfile(baseP, 'ambient.tiff'));
texture = weightLU(im, shpF, 1);