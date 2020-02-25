clc;
clear;

%% cropping input images

visualize=true;

select=1;
datasets=["RedWeb","DeepLens","IBMS1"];

datadir_cropped     = sprintf('results/%s/Depth_est_cropped',datasets(select)); 
cropped_datadir     = sprintf('results/%s/Cropped_Estimation',datasets(select));
gtdir       = sprintf('img/%s/Depth_cropped',datasets(select)); 

DeepLens_datadir_cropped     = 'results/DeepLens/Depth_est_cropped';  
DeepLens_cropped_datadir     = 'results/DeepLens/Cropped_Estimation';
DeepLens_gtdir       = 'img/DeepLens/Depth_cropped'; 

resultsdir  = 'results'; %the directory for dumping results

gtlist=dir(sprintf('%s/*.png', gtdir));
img_croppedlist = dir(sprintf('%s/*.png', datadir_cropped));
cropped_imagelist=dir(sprintf('%s/*.png', cropped_datadir));

DeepLens_gtlist=dir(sprintf('%s/*.png', DeepLens_gtdir));
DeepLens_img_croppedlist = dir(sprintf('%s/*.png', DeepLens_datadir_cropped));
DeepLens_cropped_imagelist = dir(sprintf('%s/*.png', DeepLens_cropped_datadir));

RMSE_error_cropped=[];
RMSE_cropped_error=[];
PSNR_error_cropped=[];
PSNR_cropped_error=[];
SSIM_error_cropped=[];
SSIM_cropped_error=[];
MI_error_cropped=[];
MI_cropped_error=[];

%% IBMS1
for i = 1:numel(gtlist)
    
    % IBMS1 Load Data
    gt = double(imread(sprintf('%s/%s', gtdir, gtlist(i).name)));
    
    if select==1 %% redWeb is uint8
        gtNorm =gt*256;
    end
    gtNorm = 65535 - gtNorm;
    %%gtNorm = rescale(gtNorm,0,65535);
    
    est_cropped = double(imread(sprintf('%s/%s', datadir_cropped, img_croppedlist(i).name)));
    est_cropped_Norm = est_cropped;
    %est_cropped_Norm = rescale(est_cropped_Norm,0,65535);
    %est_cropped_Norm = mapper(est_cropped_Norm,gtNorm);
    gtNorm = mapper(gtNorm,est_cropped_Norm);

    cropped_est = double(imread(sprintf('%s/%s', cropped_datadir, cropped_imagelist(i).name)));
    cropped_est_Norm = cropped_est;
    %cropped_est_Norm = rescale(cropped_est_Norm,0,65535);
    cropped_est_Norm = mapper(cropped_est_Norm,est_cropped_Norm);
    
    % IBMS1 Error
    
    % RMSE
    est_cropped_RMSE_error=immse(est_cropped_Norm,gtNorm);
    cropped_est_RMSE_error=immse(cropped_est_Norm,gtNorm);
    
    est_cropped_RMSE_error_image=est_cropped_Norm-gtNorm;
    cropped_est_RMSE_error_image=cropped_est_Norm-gtNorm;

    RMSE_error_cropped =[RMSE_error_cropped,abs(est_cropped_RMSE_error)];
    RMSE_cropped_error =[RMSE_cropped_error,abs(cropped_est_RMSE_error)];
    
    %PSNR
    
    est_cropped_PSNR_error = psnr(est_cropped_Norm,gtNorm);
    cropped_est_PSNR_error = psnr(cropped_est_Norm,gtNorm);
    
    PSNR_error_cropped=[PSNR_error_cropped,abs(est_cropped_PSNR_error)];
    PSNR_cropped_error=[PSNR_cropped_error,abs(cropped_est_PSNR_error)];

    % SSIM
    
    [est_cropped_SSIM_error,est_cropped_SSIM_map] = ssim(est_cropped_Norm,gtNorm);
    [cropped_est_SSIM_error,cropped_est_SSIM_map] = ssim(cropped_est_Norm,gtNorm);
    
    SSIM_error_cropped=[SSIM_error_cropped,est_cropped_SSIM_error];
    SSIM_cropped_error=[SSIM_cropped_error,cropped_est_SSIM_error];
    %MI 
    
    est_cropped_MI_error = mutInfo(round(est_cropped_Norm),round(gtNorm));
    cropped_est_MI_error = mutInfo(round(cropped_est_Norm),round(gtNorm));
    

    MI_error_cropped=[MI_error_cropped,est_cropped_MI_error];
    MI_cropped_error=[MI_cropped_error,cropped_est_MI_error];
    
    % IBMS1 Visualization
    if visualize && i==3
        figure('Name',sprintf('%s Middle outputs',datasets(select)))
        montage({uint16(gtNorm),uint16(est_cropped_Norm), uint16(cropped_est_Norm),uint16(gt),uint16(abs(est_cropped_RMSE_error_image)),uint16(abs(cropped_est_RMSE_error_image)),uint16(est_cropped),est_cropped_SSIM_map,cropped_est_SSIM_map},'Size',[3 3]);
%         figure('name','Histogram Gt')
%         histogram(gtNorm)
%         figure('name','Histogram Cropped Depth')
%         histogram(cropped_est)
%         figure('name','Histogram Depth of Cropped')
%         histogram(est_cropped)
    end
      
end

%% IBMS1 ERROR VISUALIZATION
figure('Name',sprintf('%s',datasets(select)))
subplot(2,2,1);
bar(1:length(RMSE_error_cropped),RMSE_error_cropped,'g');
hold on
bar(1:length(RMSE_cropped_error),RMSE_cropped_error, 'r');
title(sprintf('RMSE Performance: %0.1f',length(find(RMSE_error_cropped < RMSE_cropped_error))/length(gtlist)*100));

subplot(2,2,2);
bar(1:length(PSNR_error_cropped),PSNR_error_cropped,'g');
hold on
bar(1:length(PSNR_cropped_error),PSNR_cropped_error, 'r');
title(sprintf('PSNR Performance: %0.1f',length(find(PSNR_error_cropped < PSNR_cropped_error))/length(gtlist)*100));

subplot(2,2,3);
bar(1:length(SSIM_error_cropped),SSIM_error_cropped,'g');
hold on
bar(1:length(SSIM_cropped_error),SSIM_cropped_error, 'r');
title(sprintf('SSIM Performance: %0.1f',length(find(SSIM_error_cropped > SSIM_cropped_error))/length(gtlist)*100));

subplot(2,2,4);
bar(1:length(MI_error_cropped),MI_error_cropped,'g');
hold on
bar(1:length(MI_cropped_error),MI_cropped_error, 'r');
title(sprintf('MI Performance: %0.1f',length(find(MI_error_cropped > MI_cropped_error))/length(gtlist)*100));




    