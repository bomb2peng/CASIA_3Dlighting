function transferFunc = plotSHcoeffs(flag, coeff, order)
% % when flag = 3, plot the function defined by SH coeffs on sphere suface
% % when flag = 1, plot Lambertian transfer func
% % when flag = 2, plot first 2 order SH approximation of Lambertian transfer func.
% % input coeff: 9x1 or 1x9 SH coeff.
% % input order: valid only when flag = 2; order of SH to approxiamte Lamb
% % output transferFunc: the sperical surface function.
[x, y, z] = sphere(100);
figure;
if flag == 1
    % % exact Lambertian convex
    transferFunc = (z>0).*z;
else
    if flag == 2
    % % SH approximation of Lambertian convex
        coeff = halfCosCoeffs(order);
    elseif flag == 3
        coeff = coeff;
    end
    L = sqrt(numel(coeff)) - 1; % order of SH coeffs
    assert(round(L) == L);
    SH = zeros(numel(x), numel(coeff));
    for l = 0:L
        for m = -l:l
            temp = SHeval([x(:), y(:), z(:)]', l, m);
            SH(:, l^2+m+l+1) = temp';
        end
    end
    transferFunc = 0;
    for i = 1:numel(coeff)
        SHresh = reshape(SH(:, i), size(x));
        transferFunc = transferFunc + coeff(i)*SHresh;
    end
end
% transferFunc = max(transferFunc, 0);
surf(x,y,z, transferFunc, 'edgecolor', 'none', 'facecolor', 'interp');
colormap gray;
axis('equal', 'vis3d');
xlabel('x');
ylabel('y');
zlabel('z');
view(0, 90);