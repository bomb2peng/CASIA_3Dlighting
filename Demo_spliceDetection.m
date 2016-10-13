% % This script is to do the splicing detection workflow on a questioned
% image. Suppose that you have a image of two persons (a image of one person can also be provided to calculate the lighting condition
% in it). Run (or do according to) this file
% section by section, following the steps.
% We recommend sticking to the folder structure in .\datasets\cases
%%
% % Step 1: We do the lighting estimation on each image separately. Use photoshop to crop your image into two. Each image includes
% only one person. Save the cropped images in separated folders as "questioned". Each folder name is the name of one person in 
% the questioned image.
thisP = pwd;
addpath(thisP);
addpath('D:\allProjects\toolBox\toolbox_graph');
folders = {'Hathaway', 'Me'};    % modify the folder names here.
imName = 'questioned.png';      % modify the extention as needed
% % Step 2: Run the "correction" function on each image to see if the face
% can be detected. If not, algorithm fails, abort here.
N = numel(folders);
for i = 1:N
    fn = fullfile(thisP, '.\datasets\cases', folders{i}, imName);
    im = read_img(fn);
    [DM,TM,option] = xx_initialize;
    [pred,pose] = xx_track_detect(DM,TM,im,[],option);
    % index2 = [20 23 26 29 15 17 19 32 38]';
%     index2=[11:14 15 17 19 20:31 32 35 38 41];
    index2 = 1:49;
    figure;
    imshow(im);
    hold on;
    plot(pred(index2,1), pred(index2,2), 'w.');%图像平面坐标,起点左上角，水平为x轴，垂直为y轴
end
%%
% % Step 3: Find one or two images from the Internet for each person. 
% 1. Use FaceGen to gernerate a 3D model.
% 2. Export as .obj in the base .\"personName"\ folder. (the .obj has skin & eyes texture, texture map in .tga format)
% 3. Export as .obj in the ".\personName\meshLab\" folder. This .obj has
% only skin texture(no eyes), texture map in .bmp format.
% 4. Convert .obj file to .ply using meshLab. we keep no texture for .ply.
%%
% % Step 4: render images under known lighting. This is for transfer coeffs
% fitting
pbrtFile = fullfile(thisP, '.\pbrtFiles\fitting.pbrt');
for i = 1:N
    disp(sprintf('rendering the %dth person...', i));
    tempP = fullfile(thisP, '.\datasets\cases', folders{i});
    pbrt4fitting(tempP, pbrtFile, 1);
end
%%
% % Step 5: lighting estimation
SHrot = sym(['[1 0 0 0 0 0 0 0 0;',...
    '0 r22 r32 r12 0 0 0 0 0;',...
    '0 r23 r33 r13 0 0 0 0 0;',...
    '0 r21 r31 r11 0 0 0 0 0;',...
    '0 0 0 0 r11*r22+r12*r21 r21*r32+r22*r31 sqrt(3)*r31*r32 r11*r32+r12*r31 r11*r12-r21*r22;',...
    '0 0 0 0 r12*r23+r13*r22 r22*r33+r23*r32 sqrt(3)*r32*r33 r12*r33+r13*r32 r12*r13-r22*r23;',...
    '0 0 0 0, -1/sqrt(3)*(r11*r21+r12*r22)+2/sqrt(3)*r13*r23, -1/sqrt(3)*(r21*r31+r22*r32)+2/sqrt(3)*r23*r33, -1/2*(r31^2+r32^2)+r33^2, -1/sqrt(3)*(r11*r31+r12*r32)+2/sqrt(3)*r13*r33, -1/2/sqrt(3)*(r11^2+r12^2)+1/sqrt(3)*r13^2+1/2/sqrt(3)*(r21^2+r22^2)-1/sqrt(3)*r23^2;',...
    '0 0 0 0 r11*r23+r13*r21 r21*r33+r23*r31 sqrt(3)*r31*r33 r11*r33+r13*r31 r11*r13-r21*r23;',...
    '0 0 0 0 r11*r21-r12*r22 r21*r31-r22*r32 sqrt(3)/2*(r31^2-r32^2) r11*r31-r12*r32 1/2*(r11^2-r12^2-r21^2+r22^2)]']);
indLandMarks = load('.\land_mark_indices.txt');
indFrontalFace = load('.\frontal_face_indices.txt');
indLandMarks = indLandMarks + 1;
indFrontalFace = indFrontalFace + 1;
for i = 1:2
    plyfile = fullfile(thisP, '.\datasets\cases', folders{i}, 'meshLab\model.ply');
    FitP = fullfile(thisP, '.\datasets\cases', folders{i}, 'fitting_textured');
    fn = fullfile(thisP, '.\datasets\cases', folders{i}, imName);
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
    TransferCoeffs{i} = brdfEstimate(FitP, shpF);
    im = read_img(fn);
    fov = 40;   % you can try some focal lenghth to get better alignment.
    landMarks = shp(indLandMarks, :);
    pose = correction(im, fov, landMarks, 1);
    showPose(im, pose, shp);
    
    zflip = [1 0 0; 0 1 0; 0 0 -1];
    RR = inv(zflip\pose.R);
    for ii = 1:3
        for jj = 1:3
            eval(['r',num2str(ii), num2str(jj), '=RR(ii, jj);']);
        end
    end
    temp = eval(SHrot)*TransferCoeffs{i}';    % rotate transfer coeffs to posed face
    M1 = temp';
    ETcoeff_1(:,:,i) = lightingEstimate(im, 1, pose, [], shpF, tlF);
    ETcoeff_2(:,:,i) = lightingEstimate(im, 0, pose, M1, shpF, tlF);
end
if N == 2
    Dist(ETcoeff_1(:,1,1), ETcoeff_1(:,1,2))
    Dist(ETcoeff_2(:,1,1), ETcoeff_2(:,1,2))
end
plotSHcoeffs(3, ETcoeff_2(:,1,1));
plotSHcoeffs(3, ETcoeff_2(:,1,2));