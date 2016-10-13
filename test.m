for k = 1:2
    if k == 1
        LsameN = LsameN1;
        LdiffN = LdiffN1;
        DsameK = Dsame1;
        DdiffK = Ddiff1;
        Th = T3(abs(FA3-0.05)<1e-3);
        Th = Th(end);
    elseif k == 2
        LsameN = LsameN2;
        LdiffN = LdiffN2;
        DsameK = Dsame2;
        DdiffK = Ddiff2;
        Th = T2(abs(FA2-0.05)<1e-3);
        Th = Th(end);
    end
    temp = LsameN(DsameK > Th);
    FA_K = zeros(18, 1);  % false alarm
    for i = 1:18
        FA_K(i) = sum(temp == i)/sum(LsameN == i);
        if sum(LsameN == i) == 0
            FA_K(i) = 0;
        end
    end
%     figure, plot(1:18, FA_K);

    temp = LdiffN(DdiffK < Th);
    MD_K = zeros(18, 18);  % miss rate
    for i = 1:18
        for j = 1:18
            MD_K(i,j) = sum(temp == sub2ind([18,18],i,j))/sum(LdiffN == sub2ind([18,18],i,j));
            if sum(LdiffN == sub2ind([18,18],i,j)) == 0
                MD_K(i,j) = 0;
            end
        end
    end
    errMap = MD_K + diag(FA_K);
    figure, 
    set (gca,'position',[0.05,0.05,0.9,0.9] );
    imshow(errMap);
    colormap('jet');
    colorbar;
end