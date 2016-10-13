function plotLightC(coeff)
% % plot the lighting function represented by SH coeff on a sphere. 
% % input coeff: 9x3 SH coeff.
[x, y, z] = sphere(100);
figure;
L = sqrt(size(coeff, 1)) - 1; % order of SH coeffs
assert(round(L) == L);
SH = zeros(numel(x), size(coeff, 1));
for l = 0:L
    for m = -l:l
        temp = SHeval([x(:), y(:), z(:)]', l, m);
        SH(:, l^2+m+l+1) = temp';
    end
end
lighting = SH*coeff;
lighting = (lighting-min(lighting(:)))/(max(lighting(:))-min(lighting(:)));
temp = reshape(1:size(lighting, 1), size(z,1), size(z,2));
surf(x,y,z, temp, 'edgecolor', 'none', 'facecolor', 'interp');
colormap(lighting);
axis('equal', 'vis3d');
xlabel('x');
ylabel('y');
zlabel('z');
view(0, 90);