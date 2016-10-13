% % This file reproduce the experiment result on YaleB dataset.

baseP = pwd();
addpath(baseP);
modelP = '.\datasets\MultiPIE\MultiPIE_FaceGen';    
temp = dir(modelP);
modelP_ID = temp(3:end);
imgP = MultiPIE_images;
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
Lcoeff1 = zeros(9, 18, numel(modelP_ID));
Lcoeff2 = zeros(9, 18, numel(modelP_ID));
Lcoeff3 = zeros(9, 18, numel(modelP_ID));
Lcoeff4 = zeros(9, 18, numel(modelP_ID));
load('.\datasets\MultiPIE\multiPIE_Aligns.mat');    % load pre-saved alignment paras estimated using detected facial landmarks.
for ID = 1:numel(modelP_ID)
    display(sprintf('%d/%d...\n', ID, numel(modelP_ID)));
    dataP = fullfile(imgP, modelP_ID(ID).name, '01\05_1');
    plyfile = fullfile(modelP, modelP_ID(ID).name, 'meshLab\model.ply');            % complete head mesh  
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
    
    disp('fitting transfer coeffs...');
%     fitting method
    M_texture = brdfEstimate(fullfile(modelP, modelP_ID(ID).name, '.\fitting_textured'), shpF);
    M_grey = brdfEstimate(fullfile(modelP, modelP_ID(ID).name, '.\fitting_untextured'), shpF);
    im = read_img(fullfile(modelP, modelP_ID(ID).name, 'ambient.tiff'));
    texture = weightLU(im, shpF, 0);
    
    imlist = dir(dataP);
    im0 = imread(fullfile(dataP, imlist(3).name));  % the ambient lighted image
    imlist(1:3) = [];
    imlist(end) = [];   % discard the two ambient lighting images
    assert(numel(imlist) == 18);

% %     estimate pose
%     imName = fullfile(dataP, imlist(7).name);
%     im = read_img(imName);
    zflip = [1 0 0; 0 1 0; 0 0 -1];     % 估计pose时，只保留这两行。
%     fov = 25;
%     landMarks = shp(indLandMarks, :);
%     align = correction(im, fov, landMarks, 0);
    for i = 1:numel(imlist) 
        imName = fullfile(dataP, imlist(i).name);
        im = read_img(imName);
% %         align = Aligns(i, ID);
        align = Aligns(7, ID);
%         showPose(im, align, shp);
        if isempty(align)
            continue;
        end
        RR = inv(zflip\align.R);
        for ii = 1:3
            for jj = 1:3
                eval(['r',num2str(ii), num2str(jj), '=RR(ii, jj);']);
            end
        end        
        temp = eval(SHrot)*M_texture';
        M2 = temp';
        temp = eval(SHrot)*M_grey';
        M3 = temp';

%         im = im - im0;  % the image with only directional light on, more prominent shadows.
%         im = im0 + 0.2*(im-im0);
        L1 = lightingEstimateAlhpha(im, shpF, tlF, align, [], false);    % Farid's
        L2 = lightingEstimateAlhpha(im, shpF, tlF, align, [], false, M2);   % fitting, textured
        L3 = lightingEstimateAlhpha(im, shpF, tlF, align, [], false, M3);   % fitting, grey
        L4 = lightingEstimateAlhpha(im, shpF, tlF, align, [], false, [], texture);  % textured, convex

        Lcoeff1(:,i,ID) = L1(:,2);     
        Lcoeff2(:,i,ID) = L2(:,2);
        Lcoeff3(:,i,ID) = L3(:,2);
        Lcoeff4(:,i,ID) = L4(:,2);
        
%         shpR = transpose(zflip*align.R * shpF');
%         renderModel(shpR, tlF, L1, [], 0);
%         renderModel(shpR, tlF, L2, M2, 0);
%         renderModel(shpR, tlF, L3, M3, 0);
%         renderModel(shpR, tlF, L5, M4, 0);
%         renderModel(shpR, tlF, L6, M5, 0);
%         plotLightC(L1);
%         renderModel(shpR, tlF, L2, M2, 0);
%         plotLightC(L2);
    end
end

% % Compute the ROC curves
N = 10000;
[FA1,DR1,T1,AUC1, LsameN1, LdiffN1, Dsame1, Ddiff1] = computeROC(Lcoeff1, N);       % false alarm and detection rate
[FA2,DR2,T2,AUC2, LsameN2, LdiffN2, Dsame2, Ddiff2] = computeROC(Lcoeff2, N);
[FA3,DR3,T3,AUC3] = computeROC(Lcoeff3, N);
[FA4,DR4,T4,AUC4] = computeROC(Lcoeff4, N);

figure;
res = N/50;
fs = 12;
plot(FA1(1:res:end), DR1(1:res:end), 'b-x', 'LineWidth', 2);
hold on;
plot(FA3(1:res:end), DR3(1:res:end), 'g-', 'LineWidth', 2);
plot(FA4(1:res:end), DR4(1:res:end), 'k-', 'LineWidth', 2);
plot(FA2(1:res:end), DR2(1:res:end), 'r-o', 'LineWidth', 2);
legend('Kee & Farid''s', 'Non-convex Untextured', 'Convex Textured', 'Non-convex Textured');
% % legend('Kee & Farid''s', 'Proposed');
xlabel('False Alarm Rate', 'FontSize', fs); ylabel('Detection Rate', 'FontSize', fs)
title('ROC curve', 'FontSize', fs)
grid on;
set(gca, 'fontsize', fs);
[AUC1, AUC3, AUC4, AUC2]

% % Error map of distinguishing 18 lights
for k = 1:2
    if k == 1
        LsameN = LsameN1;
        LdiffN = LdiffN1;
        DsameK = Dsame1;
        DdiffK = Ddiff1;
        Th = T3(abs(FA3-0.05)<1e-3);
        Th = Th(end);
    elseif k == 2
        LsameN = LsameN2;
        LdiffN = LdiffN2;
        DsameK = Dsame2;
        DdiffK = Ddiff2;
        Th = T2(abs(FA2-0.05)<1e-3);
        Th = Th(end);
    end
    temp = LsameN(DsameK > Th);
    FA_K = zeros(18, 1);  % false alarm
    for i = 1:18
        FA_K(i) = sum(temp == i)/sum(LsameN == i);
        if sum(LsameN == i) == 0
            FA_K(i) = 0;
        end
    end
%     figure, plot(1:18, FA_K);

    temp = LdiffN(DdiffK < Th);
    MD_K = zeros(18, 18);  % miss rate
    for i = 1:18
        for j = 1:18
            MD_K(i,j) = sum(temp == sub2ind([18,18],i,j))/sum(LdiffN == sub2ind([18,18],i,j));
            if sum(LdiffN == sub2ind([18,18],i,j)) == 0
                MD_K(i,j) = 0;
            end
        end
    end
    errMap = MD_K + diag(FA_K);
    figure, 
    set (gca,'position',[0.05,0.05,0.9,0.9] );
    imshow(errMap);
    colormap('jet');
    colorbar;
end