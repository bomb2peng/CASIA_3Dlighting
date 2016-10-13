function plotLitSphere(coeff)
% % plot what a Lambertian sphere looks like under the given lighting
% % coeffs
% % input coeff: 9x1 SH coeff.
rho = 1;
[x, y, z] = sphere(100);
figure;
L = sqrt(size(coeff, 1)) - 1; % order of SH coeffs
assert(round(L) == L);
norm = [x(:), y(:), z(:)]';
M = Mcoeff(norm, L);   % coeffs matrix£¬ M*v=b
shading = rho*M*coeff;
shading = (shading-min(shading))/range(shading);
temp = 1:size(shading, 1);
temp = reshape(temp, size(x,1), size(x,2));
surf(x,y,z, temp, 'edgecolor', 'none', 'facecolor', 'interp');
colormap(repmat(shading, 1, 3));
axis('equal', 'vis3d');
xlabel('x');
ylabel('y');
zlabel('z');
view(0, 90);