function Ycoeff = SHeval(normal, l, m)
% % evaluate the spherical harmonic at given directions.
% % input normal: 3xn
% % input l: order of SH
% % input m: m'th SH in order l, -l<= m <=l
% % output Ycoeff: 1xn
% % based on spharm.m
    if m < 0
        flag = 0;
    else
        flag = 1;
    end
    m = abs(m);
    assert(m <= l);
    [phi, theta, ~] = cart2sph(normal(1,:), normal(2,:), normal(3,:));
    theta = pi/2 - theta;
    Llm=legendre(l,cos(theta));
    Llm = Llm(m+1,:);
    a1=((2*l+1)/(4*pi));
    a2=factorial(l-m)/factorial(l+m);
    C = (-1)^m * (sqrt(2))^(m~=0) * sqrt(a1*a2);
    Ymn = C*Llm.*exp(1i*m*phi);
    if flag == 0
        Ycoeff = imag(Ymn);
    elseif flag == 1
        Ycoeff = real(Ymn);
    end
end