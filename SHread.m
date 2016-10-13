% read spherical harmonics from pbrt output file. Note the sign difference
% between pbrt and the paper.

function SH = SHread(fn)
[fid, message] = fopen(fn, 'r');
if fid < 0, error(['Cannot open the file ' fn '\n' message]); end
temp = fgetl(fid);
split = regexp(temp, ' ', 'split');
order = str2double(split{1});      % order of SH coeffs
nCoeffs = (order+1)^2;      % number of SH coeffs
for i = 1:2
    [~] = fgetl(fid);
end
SH = zeros(nCoeffs, 3);
for i = 1:nCoeffs
    temp = fgetl(fid);
    SH(i, :) = str2num(temp);
end
i = 2:2:nCoeffs;
SH(i, :, :) = -SH(i, :, :);     % the sign convertion from pbrt to Matlab algorithm.
fclose(fid);