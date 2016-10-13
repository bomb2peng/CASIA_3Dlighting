% % To generate the synthetic dataset.
% use different distant lights and an ambient light to render Hathaway model and output
% groundtruth SH coeffs to .out files. generate images to D:\allProjects\3Dlighting_standalone\datasets\Hathaway\tons
N = 500;     % number of different directions
baseP = pwd;
addpath(baseP);
exeDir = fullfile(baseP, '.\datasets\Hathaway\model');
pbrtFile = fullfile(baseP, '.\pbrtFiles\dataset.pbrt');
pbrt4dataset(exeDir, pbrtFile, 1, N);