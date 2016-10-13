function reProjectionNormal(tc, normalf, nlen, P, im, ptstyle)
% % input tc: nx3, vertices
% % input normalf: nx3, normals at verts
% % input P: 3x4, projection matrix.
    if nargin <6
        ptstyle = 'gx';
    end
    nend = tc + nlen*normalf;     % normal end point
    tc2d = (P*[tc, ones(size(tc,1), 1)]')';
    nend2d = (P*[nend, ones(size(nend,1), 1)]')'; 
    if sum(P(3,:)) ~= 0
        tc2d = tc2d./repmat(tc2d(:, 3), 1, 3);
        nend2d = nend2d./repmat(nend2d(:,3), 1, 3);
    else                        % orthogonal projection
        tc2d = tc2d;
        nend2d = nend2d;
    end   
    h=size(im,1);
    %将像平面坐标系转换到plot画图坐标
    tc2d(:,2)=h-tc2d(:,2);
    nend2d(:,2)=h-nend2d(:,2);
    tc2d = tc2d(:,1:2); nend2d = nend2d(:, 1:2);
    figure, imshow(im); hold on;
    for i=1:size(tc2d,1)
        plot([tc2d(i,1), nend2d(i,1)], [tc2d(i,2), nend2d(i,2)], 'b');
        plot([tc2d(i,1)], [tc2d(i,2)], ptstyle, 'MarkerSize',2);
    end
end