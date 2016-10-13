function renderModel(vv, ff, Lcoeff, transferCoeffs, flag)
% % render a 3D model using given lighting and transfer SH coeffs.
% % input: vv, ff: nx3, vertices and faces of the obj mesh.
% % input: Lcoeff: 9x1 or 1x9, lighting SH coeffs.
% % input: transferCoeffs: [] or nx9, transfer coeffs.
% % input: flag: 1 to scale the range, 0 not to.
if nargin <5
    flag =0;
end
rho = 1;  %reflectance rate
if isempty(transferCoeffs)
    [norm, ~] = compute_normal(vv, ff);
    M = Mcoeff(norm);   % coeffs matrix， M*v=b
else
    if size(transferCoeffs, 2) == 9          % 传入的是拟合的 transfer coefficients
        M = transferCoeffs;
    elseif size(transferCoeffs, 2) == 3      % 传入的texture用于加权
        [norm, ~] = compute_normal(vv, ff);
        M = Mcoeff(norm); 
        weight = transferCoeffs(:, 2);       % 只是用 G 通道的系数
        M = repmat(weight, 1, 9).*M;
    end
end
shading = rho*M*Lcoeff;
shading = repmat(shading, 1, 3);%.*texDown';
if flag == 1
    shading = (shading)/max(shading(:));
end
shading = shading/255;
shading = min(1, max(shading', 0));
figure, DrawTextureHead(vv', ff', double(shading));
view(0, 90);