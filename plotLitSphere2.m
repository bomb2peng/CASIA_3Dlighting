function shading = plotLitSphere2(coeff, sz, show)
% % plot what a Lambertian sphere looks like under the given lighting
% % coeffs. Minor difference from "plotLitSphere.m". This function uses
% % uniform sampled sphere.
% % input coeff: 9x1 SH coeff.
% % input sz: resolution of the sphere
% % input show: logic

if nargin < 2
  sz = 4;
end
if nargin < 3
  show = false;
end
rho = 1;

[vertices, faces] = icosphere(sz);
x = vertices(:, 1);
y = vertices(:, 2);
z = vertices(:, 3);

L = sqrt(size(coeff, 1)) - 1; % order of SH coeffs
assert(round(L) == L);
norm = [x(:), y(:), z(:)]';
M = Mcoeff(norm, L);   % coeffs matrix£¬ M*v=b
shading = rho*M*coeff;
shading = 1*(shading-min(shading))/range(shading);
shading = max(0, min(1, shading));

if show
    figure;
    trisurf(faces,vertices(:,1),vertices(:,2),vertices(:,3), shading,...
        'edgecolor', 'none', 'facecolor', 'interp');
    colormap gray;
    axis('equal', 'vis3d');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view(0, 90);
    axis off;
end