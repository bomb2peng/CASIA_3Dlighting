function shading = renderModel(vv, ff, Lcoeff, transferCoeffs, flag)
% % render a 3D model using given lighting and transfer SH coeffs.
% % input: vv, ff: nx3, vertices and faces of the obj mesh.
% % input: Lcoeff: nCoeffs x nChan, lighting SH coeffs.
% % input: transferCoeffs: [] or n x nCoeffs, transfer coeffs.
% % input: flag: 1 to scale the range, 0 not to.
if nargin <5
    flag =0;
end
rho = 1;  %reflectance rate
if isempty(transferCoeffs)
    norm = NormDirection(vv', ff');
%     [norm,~] = compute_normal(vv,ff);
    order = sqrt(size(Lcoeff, 1)) - 1;
    M = Mcoeff(norm, order);   % coeffs matrix£¬ M*v=b
else
    M = transferCoeffs;
end
shading = rho*M*Lcoeff;
shading = shading/255;
if size(shading, 2) == 1
    shading = repmat(shading, 1, 3);%.*texDown';
end
if flag == 1
    shading = (shading-min(shading(:)))/(max(shading(:))-min(shading(:)));
end
shading = min(1, max(shading', 0));
figure, DrawTextureHead(vv', ff', double(shading));
view(0, 90);