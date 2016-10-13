% % To generate images for fitting transfer coefficients of Hathaway model:
% use different distant lights to render Hathaway model and output
% groundtruth SH coeffs to .out files. generate images
baseP = pwd;
addpath(baseP);
exeDir = fullfile(baseP, '.\datasets\TIFS_synthetic\TexturedFace');
pbrtFile = fullfile(baseP, '.\pbrtFiles\fitting.pbrt');     % use directional distant light to render
disp('rendering untextured Hathaway ...' );
pbrt4fitting(exeDir, pbrtFile, 0)                           % this function is for distant light rendering
disp('rendering textured Hathaway ...' );
pbrt4fitting(exeDir, pbrtFile, 1)