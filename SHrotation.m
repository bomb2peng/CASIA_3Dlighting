% % relation between old and new SH coeffs when SH is rotated.

syms x y z x1 y1 z1 theta phi
z = cos(theta);
x = sin(theta)*cos(phi);
y = sin(theta)*sin(phi);
r = sym('r', 3);
temp = r*[x; y; z];
x1 = temp(1);
y1 = temp(2);
z1 = temp(3);
Y = sym('Y', [9,1]);
Y(1) = 1/sqrt(4*pi);
Y(2) = sqrt(3/4/pi)*y;
Y(3) = sqrt(3/4/pi)*z;
Y(4) = sqrt(3/4/pi)*x;
Y(5) = 3*sqrt(5/12/pi)*x*y;
Y(6) = 3*sqrt(5/12/pi)*y*z;
Y(7) = 1/2*sqrt(5/4/pi)*(3*z^2-1);
Y(8) = 3*sqrt(5/12/pi)*x*z;
Y(9) = 3/2*sqrt(5/12/pi)*(x^2 - y^2);
Y1 = sym('Y1', [9,1]);
Y1(1) = 1/sqrt(4*pi);
Y1(2) = sqrt(3/4/pi)*y1;
Y1(3) = sqrt(3/4/pi)*z1;
Y1(4) = sqrt(3/4/pi)*x1;
Y1(5) = 3*sqrt(5/12/pi)*x1*y1;
Y1(6) = 3*sqrt(5/12/pi)*y1*z1;
Y1(7) = 1/2*sqrt(5/4/pi)*(3*z1^2-1);
Y1(8) = 3*sqrt(5/12/pi)*x1*z1;
Y1(9) = 3/2*sqrt(5/12/pi)*(x1^2 - y1^2);
c = sym('c', [9 1]);
f1 = c'*Y1;
cc = sym('cc', [9 1]);
for i = 1:9
    cc(i) = int(int(f1*Y(i)*sin(theta), 'theta', 0, pi), 'phi', 0, 2*pi);
end