
croppedBefore=double(imread('small-groups_cropped.png'))/65536;
croppedAfter=double(imread('small-groups_croppedAfter.png'))/255;
b=imshow(croppedBefore);

figure('Name','Cropped before depth estimation');
imhist(croppedBefore);


figure('Name','Cropped after depth estimation');
imhist(croppedAfter);

rmsB=rms(croppedBefore,GT);
rmsA=rms(croppedAfter,GT);


% imModelBefore=imagemodel(b);
% 
% imMax=getMaxIntensity(imModelBefore);
% imMin=getMinIntensity(imModelBefore);
% 
% %print(imMax);
% %print(imMin);
% afterAdjusted=imadjust(croppedAfter,[imMin imMax]);
% 
% 
% 
% figure('Name','Cropped before depth estimation');
% imhist(croppedBefore);
% 
%  
% figure('Name','Cropped after depth estimation with adjustments');
% imhist(afterAdjusted);