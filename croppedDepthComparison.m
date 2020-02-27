clc;
clear;

%% Initialize

% set basic variables
RMSE_error_cropped=[];
RMSE_cropped_error=[];
PSNR_error_cropped=[];
PSNR_cropped_error=[];
SSIM_error_cropped=[];
SSIM_cropped_error=[];
MI_error_cropped=[];
MI_cropped_error=[];
DDR_error_cropped=[];
DDR_cropped_error=[];

RMSE_diff=[];
PSNR_diff=[];
SSIM_diff=[];
MI_diff=[];
GMSD_error_cropped=[];
GMSD_cropped_error=[];

% set visualization mode
visualize=true;

% select data set
select=3;
datasets=["RedWeb","DeepLens","IBMS1","Tau"];

% set data path
gtdir               = sprintf('img/%s/Depth_cropped',datasets(select)); 
imgdir              = sprintf('img/%s/Images',datasets(select));
cropped_imgdir      = sprintf('img/%s/Images_cropped',datasets(select));

datadir             = sprintf('results/%s/Depth_est',datasets(select));
datadir_cropped     = sprintf('results/%s/Depth_est_cropped',datasets(select)); 
cropped_datadir     = sprintf('results/%s/Cropped_Estimation',datasets(select));

resultsdir          = 'results'; %the directory for dumping results

% collect data
gtlist=dir(sprintf('%s/*.png', gtdir));
depth_cropped_list = dir(sprintf('%s/*.png',datadir_cropped));

if(isempty(dir(sprintf('%s/*.png', cropped_datadir))))
    cropImages(cropped_datadir, datadir);
end
cropped_depth_list = dir(sprintf('%s/*.png', cropped_datadir));

if(isempty(dir(sprintf('%s/*.png', cropped_imgdir))))
    cropImages(cropped_imgdir,imgdir);
end
cropped_image_list = dir(sprintf('%s/*.png', cropped_imgdir));

% select preprocessing and metric
do_norm= true
do_scale= true
do_gmsd= true
do_rmse= true
do_psnr= true
do_ssim= true
do_ddr= true 
do_mi =true;


%% Evaluation
for i = 1:numel(gtlist)
    
    % Load Data
    image = im2double(imread(sprintf('%s/%s', cropped_imgdir, cropped_image_list(i).name)));
    gt = im2double(imread(sprintf('%s/%s', gtdir, gtlist(i).name))); 
    est_cropped = im2double(imread(sprintf('%s/%s', datadir_cropped, depth_cropped_list(i).name)));
    cropped_est = im2double(imread(sprintf('%s/%s', cropped_datadir, cropped_depth_list(i).name)));
   
     
    %Normalize
    if(do_norm)
        gtNorm=normImg(gt)
        est_cropped=normImg(est_cropped)
        cropped_est=normImg(cropped_est)
    end
     
    %Rescale
    if(do_scale)
        gt=rescale(gt,0,1)
        est_cropped=rescale(est_cropped,0,1)
        cropped_est=rescale(cropped_est,0,1)
    end 

    % GMSD
    if(do_gmsd)
        e=gmsd(est_cropped,gt);
        c=gmsd(cropped_est,gt);
    
        GMSD_error_cropped =[GMSD_error_cropped,e];
        GMSD_cropped_error =[GMSD_cropped_error,c];
    end
    
    
    % RMSE
    if (do_rmse)
        est_cropped_RMSE_error=immse(est_cropped,gt);
        cropped_est_RMSE_error=immse(cropped_est,gt);
    
        est_cropped_RMSE_error_image=est_cropped-gt;
        cropped_est_RMSE_error_image=cropped_est-gt;

        RMSE_error_cropped =[RMSE_error_cropped,abs(est_cropped_RMSE_error)];
        RMSE_cropped_error =[RMSE_cropped_error,abs(cropped_est_RMSE_error)];

        RMSE_diff=[RMSE_diff,(RMSE_cropped_error-RMSE_error_cropped)]
    end
    
    %PSNR
    if (do_psnr)
        est_cropped_PSNR_error = psnr(est_cropped,gt);
        cropped_est_PSNR_error = psnr(cropped_est,gt);
    
        PSNR_error_cropped=[PSNR_error_cropped,abs(est_cropped_PSNR_error)];
        PSNR_cropped_error=[PSNR_cropped_error,abs(cropped_est_PSNR_error)];

        PSNR_diff=[PSNR_diff,(PSNR_cropped_error-PSNR_error_cropped)];
    end

    % SSIM
    if(do_ssim)
        [est_cropped_SSIM_error,est_cropped_SSIM_map] = ssim(est_cropped,gt);
        [cropped_est_SSIM_error,cropped_est_SSIM_map] = ssim(cropped_est,gt);

        SSIM_error_cropped=[SSIM_error_cropped,est_cropped_SSIM_error];
        SSIM_cropped_error=[SSIM_cropped_error,cropped_est_SSIM_error];

        SSIM_diff=[SSIM_diff,(SSIM_cropped_error-SSIM_error_cropped)];
    end
    
    % DDR
    if(do_ddr)
        [est_cropped_DDR_error, cropped_est_DDR_error]= DDR(gt,est_cropped,cropped_est,image);

        DDR_error_cropped=[DDR_error_cropped,est_cropped_DDR_error];
        DDR_cropped_error=[DDR_cropped_error,cropped_est_DDR_error];
    end

    %MI
    if(do_mi)
        est_cropped_MI_error = mutInfo(double(im2uint16(est_cropped)),double(im2uint16(gt)));
        cropped_est_MI_error = mutInfo(double(im2uint16(cropped_est)),double(im2uint16(gt)));
    

        MI_error_cropped=[MI_error_cropped,est_cropped_MI_error];
        MI_cropped_error=[MI_cropped_error,cropped_est_MI_error];

        MI_diff=[MI_diff,(MI_error_cropped-MI_cropped_error)];
    end
end

% if(do_gmsd)
%     avg_gmsd_est_cropped=sum(gmsd_est_cropped(:))/length(gmsd_est_cropped);
%     avg_gmsd_cropped_est=sum(gmsd_cropped_est(:))/length(gmsd_cropped_est);
% end

%%ERROR VISUALIZATION 

avg_r=(sum(RMSE_diff)/length(RMSE_diff))/(sum(RMSE_cropped_error)/length(RMSE_diff));
avg_p=sum(PSNR_diff)/length(PSNR_diff)/(sum(PSNR_cropped_error)/length(PSNR_diff));
avg_s=sum(SSIM_diff)/length(SSIM_diff)/(sum(SSIM_cropped_error)/length(SSIM_diff));
avg_m=sum(MI_diff)/length(MI_diff)/(sum(MI_cropped_error)/length(MI_diff));

                   
                                                                      
figure('Name',sprintf('%s',datasets(select)))                          
subplot(6,1,1);
bar(1:length(RMSE_error_cropped),RMSE_error_cropped,'g');
hold on
bar(1:length(RMSE_cropped_error),RMSE_cropped_error, 'r');
title(sprintf('RMSE Performance gain in percent: %0.4f',length(find(RMSE_error_cropped <= RMSE_cropped_error))/length(gtlist)*100));


subplot(6,1,2);
bar(1:length(PSNR_error_cropped),PSNR_error_cropped,'g');
hold on
bar(1:length(PSNR_cropped_error),PSNR_cropped_error, 'r');
title(sprintf('PSNR Performance gain in percent: %0.4f',length(find(PSNR_error_cropped <= PSNR_cropped_error))/length(gtlist)*100));


subplot(6,1,3);
bar(1:length(SSIM_error_cropped),SSIM_error_cropped,'g');
hold on
bar(1:length(SSIM_cropped_error),SSIM_cropped_error, 'r');
title(sprintf('SSIM Performance gain in percent: %0.4f',length(find(SSIM_error_cropped <= SSIM_cropped_error))/length(gtlist)*100));

subplot(6,1,4);
bar(1:length(GMSD_error_cropped),GMSD_error_cropped,'g');
hold on
bar(1:length(GMSD_cropped_error),GMSD_cropped_error, 'r');
title(sprintf('GMSD Performance gain in percent: %0.4f',length(find(GMSD_error_cropped <= GMSD_cropped_error))/length(gtlist)*100));

subplot(6,1,5);
bar(1:length(DDR_error_cropped),DDR_error_cropped,'g');
hold on
bar(1:length(DDR_cropped_error),DDR_cropped_error, 'r');
title(sprintf('DDR Performance gain in percent: %0.4f',length(find(DDR_error_cropped <= DDR_cropped_error))/length(gtlist)*100));

subplot(6,1,6);
bar(1:length(MI_error_cropped),MI_error_cropped,'g');
hold on
bar(1:length(MI_cropped_error),MI_cropped_error, 'r');
title(sprintf('MI Performance gain in percent: %0.4f',length(find(MI_error_cropped >= MI_cropped_error))/length(gtlist)*100));





    