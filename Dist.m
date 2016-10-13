function D = Dist(v1, v2)
% the distance between two lighting coeffs. v1, v2 should be coloumn
% vectors;
if v1'*v2 == 0
    D = -1;
    return;
end
Q = zeros(9, 9);
Q(1,1) = 0; Q(2,2) = pi/9; Q(3,3) = pi/36; Q(4,4) = pi/9; Q(5,5) = pi/64;
Q(6,6) = pi/64; Q(7,7) = pi/64; Q(8,8) = pi/64; Q(9,9) = pi/64;
Q(2,6) = sqrt(5)*pi/64; Q(3,7) = sqrt(5)*pi/64/sqrt(3); Q(4,8) = sqrt(5)*pi/64;
Q(6,2) = sqrt(5)*pi/64; Q(7,3) = sqrt(5)*pi/64/sqrt(3); Q(8,4) = sqrt(5)*pi/64;
corr = v1'*Q*v2/(sqrt(v1'*Q*v1)*sqrt(v2'*Q*v2));
D = 1/2*(1-corr);