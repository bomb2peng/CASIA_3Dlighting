% write the result spherical harmonics to a file for pbrt to render. Note the sign difference
% between pbrt and the paper.

function SHwrite(fn, SH)
[fid, message] = fopen(fn, 'w');
if fid < 0, error(['Cannot open the file ' fn '\n' message]); end
for i = [2, 4, 6, 8]        % the sign convertion from Matlab algorithm to pbrt.
    SH(i, :) = -SH(i, :);
end
Mwrite(fid, [2,1,0; 1,1,1]);
Mwrite(fid, [-4.000000 -4.000000 -4.000000 4.000000 4.000000 4.000000]);
Mwrite(fid, SH);
fclose(fid);

function Mwrite(fid, a)
[m,n]=size(a);
 for i=1:1:m
    for j=1:1:n
       if j==n
         fprintf(fid,'%g\n',a(i,j));
      else
        fprintf(fid,'%g\t',a(i,j));
       end
    end
end