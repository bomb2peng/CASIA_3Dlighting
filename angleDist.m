function c = angleDist(a, b)
    c = acos(dot(a, b)/(norm(a)*norm(b)));
    c = c/pi;
end