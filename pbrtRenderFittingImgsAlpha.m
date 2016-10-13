function pbrtRenderFittingImgsAlpha(exeDir)
% % This is going to replace the old version: pbrtRenderFittignImgs.m
baseP = pwd;
addpath(baseP);
pbrtFile0 = fullfile(baseP, 'pbrtFiles', 'fittingBFM.pbrt');
disp('rendering untextured BFM ...' );
cd(exeDir);
temp = icosphere(1);
distantlist = temp.Vertices;
N = size(distantlist, 1);
[~,~] = system(['copy /Y ', pbrtFile0, ' fittingBFM.pbrt']);
pbrtFile = './fittingBFM.pbrt';
content = readFile(pbrtFile);
[~,~] = system('mkdir BFM_fitting_imgs');
for k = 1:N
    x = distantlist(k, 1);
    y = distantlist(k, 2);
    z = distantlist(k, 3);
    idx = sprintf('%03d', k);
    s = sprintf('rendering %d/%d ...', k, N);
    disp(s);
    content{16} = ['  LightSource "distant" "point from" [', num2str([x y z]), '] "point to" [0 0 0] "rgb L" [1 1 1]'];   % initial intensity [2 2 2]
    content{46} = content{16};
    content{4} = ['"string filename" "./BFM_fitting_imgs/', idx, '.exr"'];
    content{38} = ['Renderer "createprobes" "string filename" ', '"./BFM_fitting_imgs/' idx, '.out', '"'];
    writeFile(pbrtFile, content);
    % execute the altered pbrt file and create tiff images.
    [~, ~] = system(['pbrt ', pbrtFile]);
    s = ['exrtotiff ./BFM_fitting_imgs/', idx, '.exr ./BFM_fitting_imgs/', idx, '.tiff'];
    [~, ~] = system(s);
end
cd(baseP);
end