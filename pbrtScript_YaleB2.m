% % To generate images for fitting transfer coefficients of all 10 models from YaleB:
% use different distant lights to render model and output
% groundtruth SH coeffs to .out files. generate images to
% D:\allProjects\3Dlighting_standalone\datasets\YaleB\fitting\YaleB??\tons2
% % 使用specific 模型

PYaleB = '.\datasets\YaleB\fitting';
temp = dir(PYaleB);
ls = {temp(3:end).name};
baseP = pwd;
addpath(baseP);
% % modify pbrt files and render
pbrtFile = fullfile(baseP, '.\pbrtFiles\fitting.pbrt');
for iID = 1:10
    tempP = fullfile(baseP, PYaleB, ls{iID});
    disp(sprintf('rendering untextured YaleB%02d ...', iID) );
    pbrt4fitting(tempP, pbrtFile, 0);
    disp(sprintf('rendering textured YaleB%02d ...', iID) );
    pbrt4fitting(tempP, pbrtFile, 1);
end