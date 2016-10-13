function D = DistShading(s1, s2, sz)
% % This function computes the distance of two shadings on a hemi-sphere.
% % This can be used together with plotLitSphere2.m to approximate the
% % lighting coeff distance by discrete calculation.
% % input: s1, s2, nx1, shading on vertices
% % input: sz, the resolution of the sphere in "visSH_3d.m"
addpath('../../3Dlighting_standalone/');
if nargin < 3
    sz = 4;
end
[vertices, faces] = icosphere(sz);
valid = (vertices(:, 3) > 0);
s1 = s1(valid);
s2 = s2(valid);
s1 = s1 - mean(s1);
s2 = s2 - mean(s2);
corr = s1'*s2/(norm(s1)*norm(s2));
D = 1/2*(1-corr);