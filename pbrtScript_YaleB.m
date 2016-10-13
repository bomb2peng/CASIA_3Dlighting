% % select out the images that lighting comes from front. calculate these
% % lighting's groundtruth SH coeffs using pbrt.
% % saved to D:\allProjects\3Dlighting_standalone\datasets\YaleB\GTcoeffs
finfo = '.\datasets\YaleB\images\yaleB01_P00.info';
imlist = YaleB_subset(finfo);
distantlist = zeros(numel(imlist), 2);
for i = 1:numel(imlist)
    temp = imlist{i};
    phi = str2num(temp(13:16));
    theta = str2num(temp(18:20));
    distantlist(i, :) = [-theta+90, -phi];  % 转换到的坐标系： x to out, y to right, z to up
end
R = [0 1 0; 0 0 1; 1 0 0];      % 转换到 pbrt文件中用的坐标系： x to right, y to up, z to out

currentDir = pwd;
addpath(currentDir);
exeDir = '.\pbrtFiles';
cd(exeDir);
fname = '.\YaleB-script.pbrt';
content = readFile(fname);
N = size(distantlist, 1);
for k = 1:N
    theta = distantlist(k, 1);
    phi = distantlist(k, 2);
    z = cosd(theta);
    x = sind(theta)*cosd(phi);
    y = sind(theta)*sind(phi);
    temp = R*[x;y;z];
    x = temp(1); y = temp(2); z = temp(3);
    idx = sprintf('%03d', k);
    s = sprintf('rendering %d/%d ...', k, N);
    disp(s);
    content{22} = ['  LightSource "distant" "point from" [', num2str([x y z]), '] "point to" [0 0 0] "rgb L" [2 2 2]'];
    content{14} = ['Renderer "createprobes" "string filename" ', '"../datasets/YaleB/GTcoeffs/', idx, '.out', '"'];
    writeFile(fname, content);
    % execute the altered pbrt file.
    [stat, output] = system('pbrt YaleB-script.pbrt');
end
cd(currentDir);