function showPose(im, align, shp)
im = im(:,:,1:3);
P = align.P;
R = align.R;
shpp=[shp,ones(size(shp,1),1)];
clr = [0; 255; 0];      % 控制点云颜色
tex = repmat(clr, size(shpp,1), 1);     
% tex = ones(size(shpp, 1)*3, 1)*255;     
im_re=reProjection(shpp,tex,im,P);     %投影点云（稀疏）显示效果，速度较快
% [im_re,Zc_re]=Rendering(X,reshape(tex, [ 3 numel(tex)/3])',im,K,R,t,model.tl);  % dense投影显示效果，速度较慢。
figure;
imshow(im_re);
% 画 坐标架 投影，指示pose
R1 = [1 0 0; 0 -1 0; 0 0 1];        % 这四行参考correction3.m中的相应位置
theta = 11.83;         
R2 = [1 0 0; 0 cosd(theta) -sind(theta); 0 sind(theta) cosd(theta)];    
rot = R1\R/R2;
loc    = [70 70]; % where to draw head pose
l = 60;
po = [0,0,0; l,0,0; 0,l,0; 0,0,l];
p2D = po*rot(1:2,:)';
hold on;
plot([p2D(1,1) p2D(2,1)]+loc(1),[p2D(1,2) p2D(2,2)]+loc(2), 'r');
plot([p2D(1,1) p2D(3,1)]+loc(1),[p2D(1,2) p2D(3,2)]+loc(2), 'g');
plot([p2D(1,1) p2D(4,1)]+loc(1),[p2D(1,2) p2D(4,2)]+loc(2), 'b');