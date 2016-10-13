function M = Mcoeff(normal, order)
% % input normal: 3xn
% % input order: SH order to be used
% % output M: nx9
    if nargin < 2
        order = 2;
    end
    coeff = halfCosCoeffs(order);
    nCoeffs = (order+1)^2;
    picoeff = zeros(1, nCoeffs);
    for i = 0:order
%       picoeff((i^2+1):(i+1)^2) = sqrt(4*pi/(2*order+1))*coeff(i^2+i+1); %Damn Bug!!!
        picoeff((i^2+1):(i+1)^2) = sqrt(4*pi/(2*i+1))*coeff(i^2+i+1);
    end
%     picoeff = [pi, 2/3*pi, 2/3*pi, 2/3*pi, pi/4, pi/4, pi/4, pi/4, pi/4];
    Ycoeff = zeros(size(normal, 2), numel(picoeff));
    L = sqrt(numel(picoeff)) - 1;
    assert(round(L) == L);
    for l = 0:L
        for m = -l:l
            temp = SHeval(normal, l, m);
            Ycoeff(:, l^2+m+l+1) = temp';
        end
    end
    M = repmat(picoeff, size(Ycoeff, 1), 1).*Ycoeff;
end