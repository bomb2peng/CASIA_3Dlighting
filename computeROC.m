function [FA,DR,T,AUC, LsameN, LdiffN, Dsame, Ddiff] = computeROC(Lcoeff, N)
% % compute ROC after getting the Lcoeff of each image in the Multi-PIE
% % database
% input Lcoeff: nSH x nLights x nID
% input N: number of random pairs.
LsameN = zeros(N, 1);
LdiffN = zeros(N, 1);
Dsame = zeros(N, 1);
Ddiff = zeros(N, 1);
for i = 1:N
    ID = zeros(1,2);
    while ID(1) == ID(2)
        ID = ceil(size(Lcoeff, 3)*rand(1,2));
    end
    idxSame = ceil(size(Lcoeff, 2)*rand(1));
    LsameN(i) = idxSame;
    idxDiff = zeros(1, 2);
    while idxDiff(1) == idxDiff(2)
        idxDiff = ceil(size(Lcoeff, 2)*rand(1,2));
    end
    LdiffN(i) = sub2ind([size(Lcoeff, 2),size(Lcoeff, 2)], idxDiff(1), idxDiff(2));
    Dsame(i) = Dist(Lcoeff(:, idxSame, ID(1)), Lcoeff(:, idxSame, ID(2)));
    Ddiff(i) = Dist(Lcoeff(:, idxDiff(1), ID(1)), Lcoeff(:, idxDiff(2), ID(2)));
end
label = cell(1, 2*N);
for i = 1:N
    label{i} = 'same';
end
for i = N+1:2*N
    label{i} = 'diff';
end
[FA,DR,T,AUC] = perfcurve(label, [Dsame; Ddiff], 'diff');       % false alarm and detection rate