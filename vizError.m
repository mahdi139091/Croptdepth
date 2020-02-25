clc;
clear;

resultsdir  = 'results'; %the directory for dumping results

load('results/Cropped_IBMS1_error.mat','error');
cropped_IBMS1_error = error;
load('results/IBMS1_error_cropped.mat','error');
IBMS1_error_cropped = error;

load('results/Cropped_DeepLens_error.mat','error');
cropped_DeepLens_error= error;
load('results/DeepLens_error_cropped.mat','error');
DeepLens_error_cropped=error;

figure('Name','IBMS1 error');
bar(1:length(cropped_IBMS1_error),cropped_IBMS1_error,'g');
hold on
bar(1:length(IBMS1_error_cropped),IBMS1_error_cropped, 'r')

figure('Name','DeepLense error');
bar(1:length(cropped_DeepLens_error),cropped_DeepLens_error,'g');
hold on
bar(1:length(DeepLens_error_cropped),DeepLens_error_cropped, 'r');