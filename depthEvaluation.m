clc;
clear;

%% cropping input images

visualize=true;

select=3;
datasets=["RedWeb","DeepLens","IBMS1","Tau"];

datadir_cropped     = sprintf('results/%s/Depth_est_cropped',datasets(select)); 
cropped_datadir     = sprintf('results/%s/Cropped_Estimation',datasets(select));
gtdir       = sprintf('img/%s/Depth_cropped',datasets(select)); 
cropped_imgdir       = sprintf('img/%s/Images_cropped',datasets(select)); 

resultsdir  = 'results'; %the directory for dumping results

gtlist=dir(sprintf('%s/*.png', gtdir));
depth_cropped_list = dir(sprintf('%s/*.png', datadir_cropped));
cropped_depth_list=dir(sprintf('%s/*.png', cropped_datadir));
cropped_image_list=dir(sprintf('%s/*.png', cropped_imgdir));


RMSE_error_cropped=[];
RMSE_cropped_error=[];
PSNR_error_cropped=[];
PSNR_cropped_error=[];
SSIM_error_cropped=[];
SSIM_cropped_error=[];
MI_error_cropped=[];
MI_cropped_error=[];

RMSE_diff=[];
PSNR_diff=[];
SSIM_diff=[];
MI_diff=[];
gmsd_est_cropped=[];
gmsd_cropped_est=[];

%% IBMS1
for i = 1:numel(gtlist)
    
    % IBMS1 Load Data
    
     image = im2double(imread(sprintf('%s/%s', cropped_imgdir, cropped_image_list(i).name)));
    
     gt = im2double(imread(sprintf('%s/%s', gtdir, gtlist(i).name))); 
    
     est_cropped = im2double(imread(sprintf('%s/%s', datadir_cropped, depth_cropped_list(i).name)));
     
     cropped_est = im2double(imread(sprintf('%s/%s', cropped_datadir, cropped_depth_list(i).name)));
   
%      gt=rescale(gt,0,1)
%     est_cropped=rescale(est_cropped,0,1)
%     cropped_est=rescale(cropped_est,0,1)
     
     [gt_mag,gt_dir]=imgradient(gt)
     [est_cropped_mag, est_cropped_dir]=imgradient(est_cropped)
     [cropped_est_mag,cropped_est_dir]=imgradient(cropped_est)
     
    
     
     gtNorm=(gt_mag-min(gt_mag(:)))/(max(gt_mag(:))-min(gt_mag(:)))
     est_cropped_Norm=(est_cropped_mag-min(est_cropped_mag(:)))/(max(est_cropped_mag(:))-min(est_cropped_mag(:)))
     cropped_est_Norm=(cropped_est_mag-min(cropped_est_mag(:)))/(max(cropped_est_mag(:))-min(cropped_est_mag(:)))
     
     gtNorm(isnan(gtNorm))=0
     est_cropped_Norm(isnan(est_cropped_Norm))=0
     cropped_est_Norm(isnan(cropped_est_Norm))=0
     
     gtNorm=rescale(gt_mag,0,1)
     est_cropped_Norm=rescale(est_cropped_mag,0,1)
     cropped_est_Norm=rescale(cropped_est_mag,0,1)
     
     
%     est_cropped_Norm = est_cropped;
%      est_cropped_Norm = mapper(est_cropped_Norm,gtNorm);
%     %est_cropped_Norm =
%     double(imhistmatch(uint16(est_cropped_Norm),uint16(gtNorm))); 
     gtNorm = mapper(gtNorm,est_cropped_Norm);
%     gtNorm = double(imhistmatch(uint16(gtNorm),uint16(est_cropped_Norm)));
% 
%     cropped_est = double(imread(sprintf('%s/%s', cropped_datadir, cropped_depth_list(i).name)));
%     cropped_est_Norm = cropped_est;
     cropped_est_Norm = mapper(cropped_est_Norm,est_cropped_Norm);
%     cropped_est_Norm = double(imhistmatch(uint16(cropped_est_Norm),uint16(est_cropped_Norm)));



    % GMSD
    e=gmsd(est_cropped,gt);
    c=gmsd(cropped_est,gt);
    
    gmsd_est_cropped =[gmsd_est_cropped,e];
    gmsd_cropped_est =[gmsd_cropped_est,c];
    

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
    
%     pts_gt  =                detectSURFFeatures(uint16(gtNorm),'MetricThreshold',0,'NumOctaves',3,'NumScaleLevels',10);
%     pts_estimation_cropped = detectSURFFeatures(uint16(est_cropped_Norm),'MetricThreshold',0,'NumOctaves',3,'NumScaleLevels',10);
%     pts_cropped_estimation = detectSURFFeatures(uint16(cropped_est_Norm),'MetricThreshold',0,'NumOctaves',3,'NumScaleLevels',10);
%     
%     [features_gt,  validPts_gt]  = extractFeatures(uint16(gtNorm),  pts_gt);
%     [features_estimation_cropped, validPts_estimation_cropped] = extractFeatures(uint16(est_cropped_Norm),pts_estimation_cropped);
%     [features_cropped_estimation, validPts_cropped_estimation] = extractFeatures(uint16(cropped_est_Norm),pts_cropped_estimation);
%     
%     indexPairs_estimation_cropped = matchFeatures(features_gt, features_estimation_cropped);
%     indexPairs_cropped_estimation = matchFeatures(features_gt, features_cropped_estimation);
%     
%     matched_gt_est_cropped  =  validPts_gt(indexPairs_estimation_cropped(:,1));
%     matched_est_cropped = validPts_estimation_cropped(indexPairs_estimation_cropped(:,2));
% 
%     matched_gt_cropped_est  = validPts_gt(indexPairs_cropped_estimation(:,1));
%     matched_cropped_est =  validPts_cropped_estimation(indexPairs_cropped_estimation(:,2));
%     
%     if visualize && i==10
%         figure;
%         showMatchedFeatures(uint16(gtNorm),uint16(est_cropped_Norm),matched_gt_est_cropped,matched_est_cropped,'montage');
% 
%         figure;
%         showMatchedFeatures(uint16(gtNorm),uint16(cropped_est_Norm),matched_gt_cropped_est,matched_cropped_est,'montage');
%     end
    

    [est_cropped_SSIM_error,est_cropped_SSIM_map] = ssim(est_cropped_Norm,gtNorm);
    [cropped_est_SSIM_error,cropped_est_SSIM_map] = ssim(cropped_est_Norm,gtNorm);
    
    %[est_cropped_SSIM_error, cropped_est_SSIM_error]= DDR(gtNorm,est_cropped_Norm,cropped_est_Norm,image);

    SSIM_error_cropped=[SSIM_error_cropped,est_cropped_SSIM_error];
    SSIM_cropped_error=[SSIM_cropped_error,cropped_est_SSIM_error];
    %MI 
    
    
    est_cropped_MI_error = mutInfo(round(est_cropped_Norm*65536),round(gtNorm*65536));
    cropped_est_MI_error = mutInfo(round(cropped_est_Norm*65536),round(gtNorm*65536));
    

    MI_error_cropped=[MI_error_cropped,est_cropped_MI_error];
    MI_cropped_error=[MI_cropped_error,cropped_est_MI_error];

    
% %    IBMS1 Visualization
%     if est_cropped_SSIM_error>cropped_est_SSIM_error
%         figure('Name',sprintf('%s Middle outputs',datasets(select)))
%         montage({gtNorm,est_cropped_Norm,cropped_est_Norm, gt,abs(est_cropped_RMSE_error_image),abs(cropped_est_RMSE_error_image),est_cropped,est_cropped_SSIM_map,cropped_est_SSIM_map},'Size',[3 3]);
% %         figure('name','Histogram Gt')
% %         histogram(gtNorm)
% %         figure('name','Histogram Cropped Depth')
% %         histogram(cropped_est_Norm)
% %         figure('name','Histogram Depth of Cropped')
% %         histogram(est_cropped_Norm)
%     end
     
    if (RMSE_cropped_error>RMSE_error_cropped)
        RMSE_diff_pos=[RMSE_diff_pos,(RMSE_cropped_error-RMSE_error_cropped)]
    else
        RMSE_diff_neg=[RMSE_diff_neg,(RMSE_cropped_error-RMSE_error_cropped)]
    end
    
    if(PSNR_cropped_error>PSNR_error_cropped)
        PSNR_diff_pos=[PSNR_diff_pos,(PSNR_cropped_error-PSNR_error_cropped)]
    else
        PSNR_diff_neg=[PSNR_diff_neg,(PSNR_cropped_error-PSNR_error_cropped)]
    end
    
    if(SSIM_cropped_error>SSIM_error_cropped)
        SSIM_diff_pos=[SSIM_diff_pos,(SSIM_cropped_error-SSIM_error_cropped)]
    else
        SSIM_diff_neg=[SSIM_diff_neg,(SSIM_cropped_error-SSIM_error_cropped)]
    end
    
    if()
    MI_diff_pos=[MI_diff,(MI_error_cropped-MI_cropped_error)]
    
end

avg_gmsd_est_cropped=sum(gmsd_est_cropped(:))/length(gmsd_est_cropped);
avg_gmsd_cropped_est=sum(gmsd_cropped_est(:))/length(gmsd_cropped_est);
 
avg_r=(sum(RMSE_diff)/length(RMSE_diff))/(sum(RMSE_cropped_error)/length(RMSE_diff));
avg_p=sum(PSNR_diff)/length(PSNR_diff)/(sum(PSNR_cropped_error)/length(PSNR_diff));
avg_s=sum(SSIM_diff)/length(SSIM_diff)/(sum(SSIM_cropped_error)/length(SSIM_diff));
avg_m=sum(MI_diff)/length(MI_diff)/(sum(MI_cropped_error)/length(MI_diff));



%%ERROR VISUALIZATION
figure('Name',sprintf('%s',datasets(select)))
subplot(4,1,1);
bar(1:length(RMSE_error_cropped),RMSE_error_cropped,'g');
hold on
bar(1:length(RMSE_cropped_error),RMSE_cropped_error, 'r');
title(sprintf('RMSE Performance gain in percent: %0.4f',avg_r));%(length(find(RMSE_error_cropped <= RMSE_cropped_error))/length(gtlist)*100)));


subplot(4,1,2);
bar(1:length(PSNR_error_cropped),PSNR_error_cropped,'g');
hold on
bar(1:length(PSNR_cropped_error),PSNR_cropped_error, 'r');
title(sprintf('PSNR Performance gain in percent: %0.4f',avg_p));%,length(find(PSNR_error_cropped <= PSNR_cropped_error))/length(gtlist)*100));


subplot(4,1,3);
bar(1:length(SSIM_error_cropped),SSIM_error_cropped,'g');
hold on
bar(1:length(SSIM_cropped_error),SSIM_cropped_error, 'r');
title(sprintf('SSIM Performance gain in percent: %0.4f',avg_s));%,length(find(SSIM_error_cropped <= SSIM_cropped_error))/length(gtlist)*100));


subplot(4,1,4);
bar(1:length(MI_error_cropped),MI_error_cropped,'g');
hold on
bar(1:length(MI_cropped_error),MI_cropped_error, 'r');
title(sprintf('MI Performance gain in percent: %0.4f',avg_m));%,length(find(MI_error_cropped >= MI_cropped_error))/length(gtlist)*100));





    