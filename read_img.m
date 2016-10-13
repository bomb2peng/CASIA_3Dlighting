function im =  read_img(fname)
temp = findstr(fname, '.');
temp = temp(end); 
if strcmp(fname(temp+1:end), 'exr')
    addpath('D:\allProjects\toolBox\HDRITools-matlab');
    im = exrread(fname);
else
    im = imread(fname);
end
if size(im, 3) == 1
    im = repmat(im, 1, 1, 3);
end
im = im(:,:,1:3);
end