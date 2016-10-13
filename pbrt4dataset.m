function pbrt4dataset(tempP, pbrtFile, flag, N)
% % This function generate synthetic dataset. The faces are in random pose
% and random lighting.
baseP = pwd();
cd(tempP);
[~, ~] = system(['obj2pbrt model.obj model.pbrt']);    % convert obj to pbrt file.
[~, ~] = system(['copy /Y ', pbrtFile, ' dataset.pbrt']);
if flag == 0
    saveP = 'dataset_untextured';    % folder name to save the rendered images.
    [~, ~] = system(['md ', saveP]);
    [~,~] = system(['rename model_eyeL_hi.tga model_eyeL_hi_hide.tga ']);  % so that pbrt cannot find the texture map, and will get grey face images.
    [~,~] = system(['rename model_eyeR_hi.tga model_eyeR_hi_hide.tga ']);
    [~,~] = system(['rename model_skin_hi.tga model_skin_hi_hide.tga ']);
elseif flag == 1
    saveP = 'dataset_textured';
    [~, ~] = system(['md ', saveP]);
    [~,~] = system(['rename model_eyeL_hi_hide.tga model_eyeL_hi.tga ']);  % so that pbrt can find the texture map, and will get textured face images.
    [~,~] = system(['rename model_eyeR_hi_hide.tga model_eyeR_hi.tga ']);
    [~,~] = system(['rename model_skin_hi_hide.tga model_skin_hi.tga ']);
end
distantlist = rand(N, 2);
distantlist(:,1) = 70*distantlist(:,1);     % theta, clap the light to the front of objects
distantlist(:,2) = 360*distantlist(:,2);    % phi, 0-360бу
poselist = rand(N, 2);
poselist(:, 1) = 40*poselist(:, 1) - 20;    % Ry, head rotation around y-axis
poselist(:, 2) = 40*poselist(:, 2) - 20;    % Rx, head rotation around x-axis
% poselist = zeros(N, 2);     % no pose.
save([saveP, '/', 'archive.mat'], 'distantlist', 'poselist');
content = readFile('dataset.pbrt');
for k = 1:N
    theta = distantlist(k, 1);
    phi = distantlist(k, 2);
    Ry = poselist(k, 1);
    Rx = poselist(k, 2);
    z = cosd(theta);
    x = sind(theta)*cosd(phi);
    y = sind(theta)*sind(phi);
    idx = sprintf('%03d', k);
    s = sprintf('rendering %d/%d ...', k, N);
    disp(s);
    content{22} = ['Rotate ', num2str(Ry), ' 0 1 0'];
    content{57} = content{22};
    content{24} = ['Rotate ', num2str(Rx), ' 1 0 0'];
    content{59} = content{24};
    content{16} = ['  LightSource "distant" "point from" [', num2str([x y z]), '] "point to" [0 0 0] "rgb L" [2 2 2]'];
    content{51} = content{16};
    content{4} = ['"string filename" "./', saveP, '/', idx, '.exr"'];
    content{43} = ['Renderer "createprobes" "string filename" ', '"./', saveP, '/', idx, '.out', '"'];
    writeFile('dataset.pbrt', content);
    % execute the altered pbrt file and create tiff images.
    [~, ~] = system(['pbrt dataset.pbrt']);
    s = ['exrtotiff ./', saveP, '/', idx, '.exr ./', saveP, '/', idx, '.tiff'];
    [~, ~] = system(s);
end
cd(baseP);
end