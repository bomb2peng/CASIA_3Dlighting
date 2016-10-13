function Lcoeff = pbrtLcoeff(theta, phi)
% % use pbrt to calc lighting SH coeffs of a distant light.
baseP = pwd();
cd('.\obj');
z = cosd(theta);
x = sind(theta)*cosd(phi);
y = sind(theta)*sind(phi);
content = readFile('Lcoeff.pbrt');
content{22} = ['  LightSource "distant" "point from" [', num2str([x y z]), '] "point to" [0 0 0] "rgb L" [2 2 2]'];
writeFile('Lcoeff.pbrt', content);
[~, ~] = system(['pbrt Lcoeff.pbrt']);
Lcoeff = SHread('Lcoeff.out');
cd(baseP);
end