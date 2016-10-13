function im1 = invGamma(im0, gamma)
% inverse gamma conversion
if nargin < 2
    gamma = 2.2;
end
if max(im0(:)) <= 1
    im1 = im0.^gamma;
else
    temp = double(im0)/255;
    temp = temp.^gamma;
    im1 = uint8(temp*255);
end