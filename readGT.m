function [GTlist, GTcoeff] = readGT(p)
% read all .out files in a path.
% read ground truth SH coeffs of pbrt's output(e.g. pisa_latlongGT.out), from a path p.
Dir = dir(p);
GTlist = {};
for i = 3:numel(Dir)
    if Dir(i).name(end-3:end) == '.out'
        var = Dir(i).name(1:end-4);
        GTlist = [GTlist; var];
    end
end
N = numel(GTlist);
for i = 1:N
    GTcoeff(:,:,i) = SHread([p, '\', GTlist{i}, '.out']); 
end