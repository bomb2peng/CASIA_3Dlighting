function [R] = RotationMatrix(angle_x, angle_y, angle_z)
% get rotation matrix by rotate angle

phi = angle_x;
gamma = angle_y;
theta = angle_z;

R_x = [1 0 0 ; 0 cos(phi) sin(phi); 0 -sin(phi) cos(phi)];      %pb: abnormal: according to the rotation matices, the three angles are rotated in left handness order.
R_y = [cos(gamma) 0 -sin(gamma); 0 1 0; sin(gamma) 0 cos(gamma)];
R_z = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1];

R = R_x * R_y * R_z;    %pb: abnormal: different from traditional y-x-z order of yaw, pitch, roll rotation (Ry*Rx*Rz). 
                        % I think the yaw, pitch, roll angle are physically wrong in this code, 
                        %but it does not affect the correctness of
                        %outcomes, as long as the definition is consistant.


end

