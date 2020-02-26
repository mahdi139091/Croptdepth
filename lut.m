clc;
clear;

datadir     = 'results/IBMS1/Depth_est_cropped';    %the directory containing the images
gtdir       = 'img/IBMS1/Depth_cropped';    %the directory containing the images
resultsdir  = 'results'; %the directory for dumping results

imglist = dir(sprintf('%s/*.png', datadir));
gtlist=dir(sprintf('%s/*.png', gtdir));


%error=[];
%mutual=[];

for i = 1%:numel(imglist)
    
    [path, imgname, dummy] = fileparts(imglist(i).name);
    img = imread(sprintf('%s/%s', datadir, imglist(i).name));
    %imgNorm=rescale(img,0,1);
    img=double(65536-img)/65536;
    
    gt=double(imread(sprintf('%s/%s', gtdir, gtlist(i).name)))%/65536;
    gtexp=2.^gt;
    g=imshow(gt);
    
    min=getMinIntensity(imagemodel(g));
    max=getMaxIntensity(imagemodel(g));
    
    minf=double(min);
    maxf=double(max);
    
    
    imgScaled=rescale(img,minf, maxf);
    
    figure
    imshow(imgScaled)
    
    diff= abs(gt-imgScaled);
    
    figure
    imshow(diff);
    
end
