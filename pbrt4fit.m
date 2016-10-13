function pbrt4fit(exeDir, outFile, geoFile, outDir)
% function pbrt4fit(exeDir, outFile, geoFile, outDir)
% usage:
% -exeDir: the directory to run pbrt. Absolute Path (AP)
% -outDir: the directory to save rendered images. Relative Path (RP), as
% pbrt only take linux like pathes.
% -outFile: the pbrt file used for rendering. AP
% -geoFile: the geometry pbrt file. RP
%
% use different distant lights to render a model and output
% groundtruth SH coeffs to .out files. The rendered images are for fitting
% transfer coefficients.
system(['copy D:\allProjects\pbrt-v2-master-copy\scenes\Hathaway\Hathaway-script3.pbrt ', outFile]);
temp = icosphere(1);
distantlist = temp.Vertices;
N = size(distantlist, 1);

currentD = pwd;
cd(exeDir);
% Read txt into cell A
[fid, message] = fopen(outFile, 'r');
if fid < 0, error(['Cannot open the file ' fn '\n' message]); end
i = 1;
tline = fgetl(fid);
A{i} = tline;
while ischar(tline)
    i = i+1;
    tline = fgetl(fid);
    A{i} = tline;
end
fclose(fid);

for k = 1:N
    x = distantlist(k, 1);
    y = distantlist(k, 2);
    z = distantlist(k, 3);
    idx = sprintf('%03d', k);
    s = sprintf('%d/%d', k, N);
    disp(['pbrt4fit.m rendering images to ', outDir, ': ', s, '...']);
    % alter the '.pbrt' file. Change cell A
    A{16} = ['  LightSource "distant" "point from" [', num2str([x y z]), '] "point to" [0 0 0] "rgb L" [2 2 2]'];
    A{50} = A{16};
    A{4} = ['"string filename" ', '"', outDir, '/', idx, '.exr"'];
    A{42} = ['Renderer "createprobes" "string filename" ', '"', outDir, '/', idx, '.out', '"'];
    A{25} = ['Include "', geoFile, '"'];
    A{59} = A{25};
    % Write cell A into txt
    [fid, message] = fopen(outFile, 'w');
    if fid < 0, error(['Cannot open the file ' fn '\n' message]); end
    for i = 1:numel(A)
        if A{i+1} == -1
            fprintf(fid,'%s', A{i});
            break
        else
            fprintf(fid,'%s\n', A{i});
        end
    end
    fclose(fid);
    % execute the altered pbrt file and create tiff images.
    [~, ~] = system(['pbrt ', outFile]);
    s = ['exrtotiff ', outDir, '/', idx, '.exr ',outDir, '/', idx, '.tiff'];
    system(s);
end
cd(currentD);