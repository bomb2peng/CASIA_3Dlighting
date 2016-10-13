function [im_re]=reProjection(X3d,T3d,im,P)
    xx=(P*X3d')';
    xx=xx./repmat(xx(:,3),1,3);
    T3d = reshape(T3d, [ 3 numel(T3d)/3 ])';
    [XX,te,xx]=zbuffer(X3d,T3d,round(xx));
    h=size(im,1);
    %将图像平面坐标系转换到matlab矩阵坐标
    xx(:,2)=xx(:,2)-h;
    M= [0 1;-1 0];%转换为矩阵坐标
    xx = xx(:,1:2)*M;
    xx = round(xx);
    im_re = im;    
    for i=1:size(xx,1)
        im_re(xx(i,1)+1,xx(i,2)+1,:)=te(i,:);
    end
end