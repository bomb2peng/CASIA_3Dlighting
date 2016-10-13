function M = McoeffOld(normal)
% % input normal: 3xn
% % output M: nx9
    x = normal(1, :)';
    y = normal(2, :)';
    z = normal(3, :)';
    picoeff = [pi, 2/3*pi, 2/3*pi, 2/3*pi, pi/4, pi/4, pi/4, pi/4, pi/4];
    Ycoeff = [repmat(1/sqrt(4*pi), size(x, 1), 1), sqrt(3/4/pi)*y, sqrt(3/4/pi)*z, sqrt(3/4/pi)*x,...
        3*sqrt(5/12/pi)*x.*y, 3*sqrt(5/12/pi)*y.*z, 1/2*sqrt(5/4/pi)*(3*z.^2-1),...
        3*sqrt(5/12/pi)*x.*z, 3/2*sqrt(5/12/pi)*(x.^2-y.^2)];
    M = repmat(picoeff, size(Ycoeff, 1), 1).*Ycoeff;
end