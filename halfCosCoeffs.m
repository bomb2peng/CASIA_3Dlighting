function coeff = halfCosCoeffs(order)
% % output coeff: 1xnCoeffs,  SH coeffs of half-cosine function.
nCoeffs = (order + 1)^2;
coeff = zeros(1, nCoeffs);
for i = 0:order
    idx = (i+1)^2 - i;
    if i == 0
        coeff(idx) = sqrt(pi)/2;
    elseif i == 1
        coeff(idx) = sqrt(pi/3);
    elseif mod(i, 2) == 0
        coeff(idx) = (-1)^(i/2+1)* sqrt((2*i+1)*pi)/(2^i*(i-1)*(i+2))*nchoosek(i, i/2);
    else
        coeff(idx) = 0;
    end
end
end