% % expriment on Carvolho's DSO-1 dataset

% % % Load Model
% load('Model_Shape.mat'); % only need to be loaded once.
% load('Model_Expression.mat'); % only need to be loaded once.
% load('Modelplus_parallel.mat');
% load('Modelplus_face_bin');
% load('Modelplus_nose_hole');
% load('idxDown.mat');
% idxTrim = load('idxEye&Eyebrow&Lip.txt');
% % idxTrim = load('idxEye.txt');
% idxTrim = idxTrim + 1;
% addpath('..\toolBox\toolbox_graph\');
tic;

close all;
% % get the landmarks for these faces
load('.\CarvolhoDataset_results\DSO-1_landmarks2.mat');
select = load('.\CarvolhoDataset_results\DSO-1_select2.txt');
dataDir = 'D:\dataset\tifs-database\DSO-1';
renderDir = 'G:\DSO-1_3DMM';
maskDir = 'D:\dataset\tifs-database\DSO-1-Masks';
imNames = dir(dataDir);
imNames = imNames(3:end);
maskNames = dir(maskDir);
maskNames = maskNames(3:end);
maskNamesArray = cell(numel(maskNames), 1);
for i = 1:numel(maskNames)
    maskNamesArray{i} = maskNames(i).name;
end
order = 2;          % SH order
nCoeffs = (order+1)^2;
LcoeffFaridMorph = zeros(nCoeffs, 2, numel(imNames));
LcoeffFitGreyMorph = zeros(nCoeffs, 2, numel(imNames)); 
transferCoeffs = zeros(numel(idxVdown), nCoeffs, 2, numel(imNames));
load('./CarvolhoDataset_results/DSO_transferCoeffs2.mat');  % pre-saved Tcoeffs
baseDir = pwd();
addpath(baseDir);
SHrot = sym(['[1 0 0 0 0 0 0 0 0;',...
    '0 r22 r32 r12 0 0 0 0 0;',...
    '0 r23 r33 r13 0 0 0 0 0;',...
    '0 r21 r31 r11 0 0 0 0 0;',...
    '0 0 0 0 r11*r22+r12*r21 r21*r32+r22*r31 sqrt(3)*r31*r32 r11*r32+r12*r31 r11*r12-r21*r22;',...
    '0 0 0 0 r12*r23+r13*r22 r22*r33+r23*r32 sqrt(3)*r32*r33 r12*r33+r13*r32 r12*r13-r22*r23;',...
    '0 0 0 0, -1/sqrt(3)*(r11*r21+r12*r22)+2/sqrt(3)*r13*r23, -1/sqrt(3)*(r21*r31+r22*r32)+2/sqrt(3)*r23*r33, -1/2*(r31^2+r32^2)+r33^2, -1/sqrt(3)*(r11*r31+r12*r32)+2/sqrt(3)*r13*r33, -1/2/sqrt(3)*(r11^2+r12^2)+1/sqrt(3)*r13^2+1/2/sqrt(3)*(r21^2+r22^2)-1/sqrt(3)*r23^2;',...
    '0 0 0 0 r11*r23+r13*r21 r21*r33+r23*r31 sqrt(3)*r31*r33 r11*r33+r13*r31 r11*r13-r21*r23;',...
    '0 0 0 0 r11*r21-r12*r22 r21*r31-r22*r32 sqrt(3)/2*(r31^2-r32^2) r11*r31-r12*r32 1/2*(r11^2-r12^2-r21^2+r22^2)]']);
for i = 50%1:numel(imNames)
    disp([num2str(i), '/', num2str(numel(imNames)), '...']);
    if sum(select(i, :)) == 0       % skip these images, becauseof landmark detection failure.
        continue;
    end
    img = imread(fullfile(dataDir, imNames(i).name));
    [height, width, nChannels] = size(img);
    if sum(strcmp(maskNamesArray, imNames(i).name)) ~= 0
        mask = imread(fullfile(maskDir, imNames(i).name));
%         mask = [];
    else
        mask = [];
    end
    for k = 1:2     % exactly 2 faces selected in each image
        iFace = select(i, k);
        pts = landmarks{i}(:,:,iFace);
        pts = squeeze(pts);
        pts = pts';
    %     figure; showImageWithPoints(img, box, landmarks);
        pt2d = pts;
        pt2d(2,:) = height + 1 - pt2d(2,:);     % matlab plot's up-left corner is (1,1). "pt2d" coordinate origin at bottom-left corner.
        
        w_low = w;
        sigma_low = sigma;
        w_exp_low = w_exp;
        sigma_exp_low = sigma_exp;
        [f, phi, gamma, theta, t3d, alpha, alpha_exp, ~, LMind3d] = FittingModel(pt2d, mu_shape + mu_exp, ...
            w_low, sigma_low, w_exp_low, sigma_exp_low, tri, parallel, keypoints, img);
        R = RotationMatrix(phi, gamma, theta);
        zflip = [1 0 0; 0 1 0; 0 0 -1];     % 相机坐标系和世界坐标系z轴相反
        align.R = zflip*R;
        align.K = [f 0 0; 0 f 0; 0 0 0];
        align.t = 1/f*t3d;      % the t3d para is actually 2d translation in pixels.
        align.P = align.K * [align.R align.t];
        express3d = mu_exp + w_exp_low * alpha_exp; express3d = reshape(express3d, 3, length(express3d)/3);
        shape3d = mu_shape + w_low* alpha; shape3d = reshape(shape3d, 3, length(shape3d)/3);
        vertex3d = shape3d + express3d;     %pb: BFM has 53490 vertex. The inside mouth mesh is trimed, and there are 53215 left.
        % % down sample the mesh for efficiency
        vertex3dDown = vertex3d(:, idxVdown);
        triDown = idxTdown;   
        face_front_bin_down = face_front_bin(idxVdown);
        nose_hole_bin = logical(zeros(1, size(vertex3d, 2)));
        nose_hole_bin(nose_hole) = 1;
        nose_hole_bin_down = nose_hole_bin(idxVdown);
        trim_bin = logical(zeros(1, size(vertex3d, 2)));    % trimed areas that have different albedo, such as eyes, eye brows, lips.
        trim_bin(idxTrim) = 1;
        trim_bin_down = trim_bin(idxVdown);

        % % Visibility analysis
        vertexR = R * vertex3dDown;
        vertexR = vertexR/1e5;
        opentime = 2;
        [visibility] = VisibilityEstimation(vertexR, triDown, opentime);    % pb: visibility of each vertex
        visibility = visibility & ~nose_hole_bin_down' & face_front_bin_down' & ~trim_bin_down';

%         cd(renderDir);
%         tempDir = sprintf('%s_%d', imNames(i).name(1:end-4), k);    % omit .png
%         [~,~] = system(['mkdir ', tempDir]);
%         cd(tempDir);
%         disp('writing .obj file...');
%         write_obj(vertex3dDown/1e5, triDown, 'BFM.obj');
%         disp('fitting transfer coeffs...');
%         [~,~] = system('D:\allProjects\pbrt-v2-master-copy\debugging_release\obj2pbrt.exe BFM.obj BFM.pbrt');
%         cd(baseDir);
%         pbrtRenderFittingImgsAlpha(fullfile(renderDir, tempDir));
%         transferCoeffs(:,:,k,i) = brdfEstimateOrth(fullfile(renderDir, tempDir, 'BFM_fitting_imgs'),...
%             vertex3dDown/1e5, [], 0);
        RR = inv(R);
        for ii = 1:3
            for jj = 1:3
                eval(['r',num2str(ii), num2str(jj), '=RR(ii, jj);']);
            end
        end
        M1 = eval(SHrot)*transpose(transferCoeffs(:,:,k,i));
        M1 = M1';

        lightCoeff1 = lightingEstimateAlhpha(img, vertex3dDown', triDown', align, visibility, true, [], [], 0, 2, mask);
        lightCoeff2 = lightingEstimateAlhpha(img, vertex3dDown', triDown', align, visibility, false, M1, [], 0, 2, mask);
        LcoeffFaridMorph(:, k, i) = lightCoeff1(:,2);
        LcoeffFitGreyMorph(:, k, i) = lightCoeff2(:,2);
%         outSigma = 50/255;
%         lightCoeff1 = lightingEstimateOutlier(vertex3dDown, triDown,[], visibility, img, 0, [], false, ...
%             order, align, outSigma, mask);
%         lightCoeff2 = lightingEstimateOutlier(vertex3dDown, triDown,[], visibility, img, 0, M1, false, ...
%             order, align, outSigma, mask);
%         LcoeffFaridMorph(:, k, i) = lightCoeff1;
%         LcoeffFitGreyMorph(:, k, i) = lightCoeff2;
        
%         renderModel(vertexR', triDown', lightCoeff1, [], 0);
%         plotLitSphere(LcoeffFaridMorph(:,k,i));
%         renderModel(vertexR', triDown', lightCoeff2, transferCoeffs(:,:,k,i), 0);
%         plotLitSphere(LcoeffFitGreyMorph(:,k,i));
    end
end
% % % % save('.\CarvolhoDataset_results\DSO_archive.mat');
toc
% % 
% % % Compute the ROC curves
% DistFaridMorph = zeros(numel(imNames), 1);
% DistFitGreyMorph = zeros(numel(imNames), 1);
% for i = 1:numel(imNames)
%     if sum(LcoeffFaridMorph(:,1,i)) == 0    % skipped ones
%         continue;
%     end
%     DistFaridMorph(i) = Dist(LcoeffFaridMorph(:,1,i), LcoeffFaridMorph(:,2,i));
%     DistFitGreyMorph(i) = Dist(LcoeffFitGreyMorph(:,1,i), LcoeffFitGreyMorph(:,2,i));
% end
% label = cell(numel(imNames), 1);
% for i = 1:100
%     label{i} = 'normal';
% end
% for i = 101:200
%     label{i} = 'splicing';
% end
% % subset_select = [7,9:13,54,55,58,59,78,79,90,91,93,100,...
% %     106:108,117:120,123,125:129,134:136,139,140,145,148,162,164,170,171,...
% %     174,187,190,];
% subset_select = 1:200;
% flag = zeros(200,1);
% flag(subset_select) = 1;
% flag = logical(flag);
% flag = ~flag;
% DistFaridMorph2 = DistFaridMorph;
% DistFitGreyMorph2 = DistFitGreyMorph;
% DistFaridMorph2(flag) = 0;
% DistFitGreyMorph2(flag) = 0;
% label(DistFaridMorph2 == 0) = [];
% 
% DistFaridMorphNormal = DistFaridMorph2(1:100);
% DistFaridMorphNormal(DistFaridMorphNormal == 0) = [];
% DistFaridMorphSplicing = DistFaridMorph2(101:200);
% DistFaridMorphSplicing(DistFaridMorphSplicing == 0) = [];
% DistFitGreyMorphNormal = DistFitGreyMorph2(1:100);
% DistFitGreyMorphNormal(DistFitGreyMorphNormal == 0) = [];
% DistFitGreyMorphSplicing = DistFitGreyMorph2(101:200);
% DistFitGreyMorphSplicing(DistFitGreyMorphSplicing == 0) = [];

% % % % error distribution plot
% % edge = 0:0.05:1;
% % [count1, center1] = hist(DistFaridMorphNormal, edge);
% % [count2, center2] = hist(DistFaridMorphSplicing, edge);
% % [count3, center3] = hist(DistFitGreyMorphNormal, edge);
% % [count4, center4] = hist(DistFitGreyMorphSplicing, edge);
% % figure;
% % fs = 12;    % fontsize
% % plot(center1, count1/numel(DistFaridMorphNormal), 'b', 'marker', 'o', 'LineWidth', 2); hold on;
% % plot(center2, count2/numel(DistFaridMorphSplicing), 'b', 'marker', 'x', 'LineWidth', 2);
% % plot(center3, count3/numel(DistFitGreyMorphNormal), 'r', 'marker', 'o', 'LineWidth', 2);
% % plot(center4, count4/numel(DistFitGreyMorphSplicing), 'r', 'marker', 'x', 'LineWidth', 2);
% % ylabel('Persentage', 'fontsize', fs);
% % xlabel('Error', 'fontsize', fs);
% % title('Comparison of error distributions', 'fontsize', fs);
% % set(gca, 'fontsize', fs);
% % grid on;

% % % % ROC plot
% [FA1,DR1,T1,AUC1] = perfcurve(label, [DistFaridMorphNormal; DistFaridMorphSplicing], 'splicing');   
% [FA2,DR2,T2,AUC2] = perfcurve(label, [DistFitGreyMorphNormal; DistFitGreyMorphSplicing], 'splicing');
% figure;
% res = 5;
% fs = 12;
% plot(FA1(1:res:end), DR1(1:res:end), 'b-x', 'LineWidth', 2);
% hold on;
% plot(FA2(1:res:end), DR2(1:res:end), 'r-o', 'LineWidth', 2);
% plot([0 1], [0 1], 'g-', 'LineWidth', 2);
% legend('Kee & Farid''s', 'Proposed', 'Random Guess');
% xlabel('False Alarm Rate', 'FontSize', fs); ylabel('Detection Rate', 'FontSize', fs)
% title('ROC curve', 'FontSize', fs)
% grid on;
% set(gca, 'fontsize', fs);
% [AUC1, AUC2]

% % % inspect the results
% close all;
% temp = sort(DistFitGreyMorphNormal, 1, 'descend');
% for i = numel(temp)-4
%     idx = find(DistFitGreyMorph == temp(i));
%     assert(numel(idx) == 1);
%     im = imread(fullfile(dataDir, imNames(idx).name));
%     figure('Name', num2str(temp(i)));
%     imshow(im);
%     lm = landmarks{idx};
%     s = select(idx, :);
%     c = zeros(2,2);
%     for j = 1:2
%         width = range(lm(:,1,s(j)));
%         height = range(lm(:,2,s(j)));
%         xmin = min(lm(:,1,s(j)));
%         ymin = min(lm(:,2,s(j)));
%         c(j, :) = mean(lm(:,:,s(j)), 1);
%         rectangle('Position', [xmin-width/3, ymin-height/3, 5/3*width, 5/3*height], 'EdgeColor', 'g');
%         text(xmin-width/3, ymin-height/3, num2str(j), 'Color', [0 1 0], 'FontSize', 12);
%     end
%     center = mean(c, 1);
%     text(center(1), center(2), sprintf('%0.3f', temp(i)), 'Color', [1 0 0], 'FontSize', 20);
%     set(gca,'position',[0 0 1 1],'units','normalized');
%     for j = 1:2
%         plotLitSphere2(LcoeffFitGreyMorph(:,j,idx), 4, true);
%         set(gca,'position',[0 0 1 1],'units','normalized');
%     end
% end