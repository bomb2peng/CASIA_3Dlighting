% read spherical harmonics from pbrt output file. Note the sign difference
% between pbrt and the paper.

function SH = SHread(fn)
[fid, message] = fopen(fn, 'r');
if fid < 0, error(['Cannot open the file ' fn '\n' message]); end
for i = 1:3
    temp = fgetl(fid);
end
SH = [];
for i = 1:9
    temp = fgetl(fid);
    SH = [SH; str2num(temp)];
end
for i = [2, 4, 6, 8]        % the sign convertion from pbrt to Matlab algorithm.
    SH(i, :) = -SH(i, :);
end
fclose(fid);