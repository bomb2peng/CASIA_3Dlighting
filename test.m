% % Compute the ROC curves
N = 200;
DistFaridMorph = zeros(N, 1);
DistFitGreyMorph = zeros(N, 1);
for i = 1:N
    if sum(LcoeffFaridMorph(:,1,i)) == 0    % skipped ones
        continue;
    end
    DistFaridMorph(i) = Dist(LcoeffFaridMorph(:,1,i), LcoeffFaridMorph(:,2,i));
    DistFitGreyMorph(i) = Dist(LcoeffFitGreyMorph(:,1,i), LcoeffFitGreyMorph(:,2,i));
end
label = cell(N, 1);
for i = 1:100
    label{i} = 'normal';
end
for i = 101:200
    label{i} = 'splicing';
end
% subset_select = [7,9:13,54,55,58,59,78,79,90,91,93,100,...
%     106:108,117:120,123,125:129,134:136,139,140,145,148,162,164,170,171,...
%     174,187,190,];
subset_select = 1:200;
flag = zeros(200,1);
flag(subset_select) = 1;
flag = logical(flag);
flag = ~flag;
DistFaridMorph2 = DistFaridMorph;
DistFitGreyMorph2 = DistFitGreyMorph;
DistFaridMorph2(flag) = 0;
DistFitGreyMorph2(flag) = 0;
label(DistFaridMorph2 == 0) = [];

DistFaridMorphNormal = DistFaridMorph2(1:100);
DistFaridMorphNormal(DistFaridMorphNormal == 0) = [];
DistFaridMorphSplicing = DistFaridMorph2(101:200);
DistFaridMorphSplicing(DistFaridMorphSplicing == 0) = [];
DistFitGreyMorphNormal = DistFitGreyMorph2(1:100);
DistFitGreyMorphNormal(DistFitGreyMorphNormal == 0) = [];
DistFitGreyMorphSplicing = DistFitGreyMorph2(101:200);
DistFitGreyMorphSplicing(DistFitGreyMorphSplicing == 0) = [];

% % % ROC plot
[FA1,DR1,T1,AUC1] = perfcurve(label, [DistFaridMorphNormal; DistFaridMorphSplicing], 'splicing');   
[FA2,DR2,T2,AUC2] = perfcurve(label, [DistFitGreyMorphNormal; DistFitGreyMorphSplicing], 'splicing');
figure;
res = 5;
fs = 12;
plot(FA1(1:res:end), DR1(1:res:end), 'b-x', 'LineWidth', 2);
hold on;
plot(FA2(1:res:end), DR2(1:res:end), 'r-o', 'LineWidth', 2);
plot([0 1], [0 1], 'g-', 'LineWidth', 2);
legend('Kee & Farid''s', 'Proposed', 'Random Guess');
xlabel('False Alarm Rate', 'FontSize', fs); ylabel('Detection Rate', 'FontSize', fs)
title('ROC curve', 'FontSize', fs)
grid on;
set(gca, 'fontsize', fs);
[AUC1, AUC2]