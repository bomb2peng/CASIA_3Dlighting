function imlist = YaleB_subset(finfo)
% % get a subset of YaleB dataset. Select the images the lighting comes
% from frontal directions.
[fid, message] = fopen(finfo, 'r');
if fid < 0, error(['Cannot open the file ' fn '\n' message]); end
i = 1;
tline = fgetl(fid);
imlist{i} = tline;
while ischar(tline)
    temp = str2num(tline(14:16));
    if temp >= 90    % skip the images with azimuth angle greater than 90 or -90
        tline = fgetl(fid);     
        continue;
    end
    temp = str2num(tline(19:20));
    if temp == 90    % skip the images with zenith angle of 90 (right above).
        tline = fgetl(fid);     
        continue;
    end
    imlist{i} = tline;
    i = i+1;
    tline = fgetl(fid);
end
fclose(fid);
imlist(1) = [];      % delete the ambient light one.
end