function transferCoeffs = brdfEstimate2()
% % use pbrt to directly compute the transfer coeffs instead of fittign
    [~,~] = system('copy /y D:\allProjects\3Dlighting_standalone\pbrtFiles\transferCoeffs.pbrt transferCoeffs.pbrt');
    [~,~] = system('copy /y D:\allProjects\3Dlighting_standalone\pbrtFiles\pbEnv_small.exr pbEnv_small.exr');
    disp('calculating exact transfer coeffs...');
    [~,~] = system('D:\allProjects\pbrt-v2-master-copy\debugging_release\obj2pbrt.exe model.obj model.pbrt');
    [~,~] = system('D:\allProjects\pbrt-v2-master-copy\debugging_release\pbrt.exe transferCoeffs.pbrt');
    transferCoeffs = transferSHread('transferCoeffs.out');
end