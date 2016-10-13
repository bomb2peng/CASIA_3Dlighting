function pbrt4fitting(tempP, pbrtFile, flag)
% % This function generate rendered face images in a single distant
% lighting. These images are used to estimate the transfer coeffs.
if iscell(tempP)
    tempP = tempP{1};
end
baseP = pwd();
cd(tempP);
[~, ~] = system(['obj2pbrt model.obj model.pbrt']);    % convert obj to pbrt file.
[~, ~] = system(['copy /Y ', pbrtFile, ' fitting.pbrt']);
if flag == 0
    saveP = 'fitting_untextured';    % folder name to save the rendered images.
    [~, ~] = system(['md ', saveP]);
    [~,~] = system(['rename model_eyeL_hi.tga model_eyeL_hi_hide.tga ']);  % so that pbrt cannot find the texture map, and will get grey face images.
    [~,~] = system(['rename model_eyeR_hi.tga model_eyeR_hi_hide.tga ']);
    [~,~] = system(['rename model_skin_hi.tga model_skin_hi_hide.tga ']);
elseif flag == 1
    saveP = 'fitting_textured';
    [~, ~] = system(['md ', saveP]);
    [~,~] = system(['rename model_eyeL_hi_hide.tga model_eyeL_hi.tga ']);  % so that pbrt can find the texture map, and will get textured face images.
    [~,~] = system(['rename model_eyeR_hi_hide.tga model_eyeR_hi.tga ']);
    [~,~] = system(['rename model_skin_hi_hide.tga model_skin_hi.tga ']);
end
temp = icosphere(1);
distantlist = temp.Vertices;
N = size(distantlist, 1);
content = readFile('fitting.pbrt');
for k = 1:N
    x = distantlist(k, 1);
    y = distantlist(k, 2);
    z = distantlist(k, 3);
    idx = sprintf('%03d', k);
    s = sprintf('rendering %d/%d ...', k, N);
    disp(s);
    content{16} = ['  LightSource "distant" "point from" [', num2str([x y z]), '] "point to" [0 0 0] "rgb L" [2 2 2]'];   % initial intensity [2 2 2]
    content{50} = content{16};
    content{4} = ['"string filename" "./', saveP, '/', idx, '.exr"'];
    content{42} = ['Renderer "createprobes" "string filename" ', '"./', saveP, '/' idx, '.out', '"'];
    content{25} = 'Include "model.pbrt"';
    content{59} = content{25};
    writeFile('fitting.pbrt', content);
    % execute the altered pbrt file and create tiff images.
    [~, ~] = system('pbrt fitting.pbrt');
    s = ['exrtotiff ./', saveP, '/', idx, '.exr ./', saveP, '/', idx, '.tiff'];
    [~, ~] = system(s);
end
cd(baseP);
end