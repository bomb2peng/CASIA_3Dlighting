% % read transfer coeffs from pbrt output file. Note the sign difference
% % between pbrt and the paper.
% % This version is specifically designed for this specific problem.

function SH = transferSHread(fn)
[fid, message] = fopen(fn, 'r');
if fid < 0, error(['Cannot open the file ' fn '\n' message]); end
temp = fgetl(fid);
split = regexp(temp, ' ', 'split');
order = str2double(split{1});      % order of SH coeffs
nCoeffs = (order+1)^2;      % number of SH coeffs
for i = 1:2
    temp = fgetl(fid);
end
temp = fgetl(fid);  % get the number of sampling points from the 4th line.
split = regexp(temp, ':', 'split');
N = str2double(split{2});
SH = zeros(nCoeffs, 3, N);
for k = 1:N
    for i = 1:nCoeffs
        temp = fgetl(fid);
        temp = str2num(temp);
        if isempty(temp)        % tolerate the bug that little amount of sampling points has #INF coeffs.
            temp = [0 0 0];
        end
        SH(i, :, k) = temp;
    end
    temp = fgetl(fid);  % skip one space line in between.
end
i = 2:2:nCoeffs;
SH(i, :, :) = -SH(i, :, :);     % the sign convertion from pbrt to Matlab algorithm.
fclose(fid);

% % first read in all the file is slower than read and process line after
% % line, shockingly...

% function SH = SHread(fn)
% content = readFile(fn);
% split = regexp(content{4}, ':', 'split'); % get the number of sampling points from the 4th line.
% N = str2double(split{2});
% SH = zeros(9, 3, N);
% line = 5; % starting line of coeffs data
% for k = 1:N
%     for i = 1:9
%         temp = content{line};
%         temp = str2num(temp);
%         if isempty(temp)        % tolerate the bug that little amount of sampling points has #INF coeffs.
%             temp = [0 0 0];
%         end
%         SH(i, :, k) = temp;
%         line = line + 1 ;
%     end
%     line = line + 1;  % skip one space line in between.
% end
% i = [2, 4, 6, 8];
% SH(i, :, :) = -SH(i, :, :);     % the sign convertion from pbrt to Matlab algorithm.