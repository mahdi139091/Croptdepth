function [sum_est_cropped_err,points1,points2,sum_cropped_est_err] = DDR(gt,depth_est_cropped,depth_cropped_est,image,log)
%DDR Summary of this function goes here
%   Detailed explanation goes here
if size(image,3)==3
    image = rgb2gray(image);
end
[gradient_gt,~] = imgradient(gt);
[gradient_est_cropped,~] = imgradient(depth_est_cropped);
[gradient_cropped_est,~] = imgradient(depth_cropped_est);
[gradient_image,~] = imgradient(image);

gradient = gradient_est_cropped + gradient_cropped_est + gradient_gt + gradient_image;
gradient = imgaussfilt(gradient,2);
% figure;
% montage({uint16(gt), uint16(depth_est_cropped), uint16(depth_cropped_est), uint16(gradient_gt), uint16(gradient_est_cropped),uint16(gradient_cropped_est)},'Size',[2 3]);
% figure;
% imshow(uint16(gradient/3))


meanval = mean(gradient(:));
threshold = min(gradient(:)) + 0.2 * meanval;

validpoints_ind = find(gradient<threshold);

random_index = randi([1 length(validpoints_ind)],1,15);

selected_pionts = validpoints_ind(random_index);

sum_est_cropped_err = 0;
sum_cropped_est_err = 0;

if log
    sprintf('%f %f %f',std(gt(:)),std(depth_est_cropped(:)),std(depth_cropped_est(:)))
end

same_ratio_gt = 1.01;
same_ratio_est_cropped = 1.2; 
same_ratio_cropped_ext = 1.01;

points1 = [size(gt,2) size(gt,1)];
points2 = [1 1];
for i=1:length(selected_pionts)
    for j=i:length(selected_pionts)
        if i~=j
            index1=selected_pionts(i);
            index2=selected_pionts(j); 
            sum_est_cropped_err = sum_est_cropped_err + abs(ord(gt(index1),gt(index2),same_ratio_gt) - ord(depth_est_cropped(index1),depth_est_cropped(index2),same_ratio_est_cropped));
            sum_cropped_est_err = sum_cropped_est_err + abs(ord(gt(index1),gt(index2),same_ratio_gt) - ord(depth_cropped_est(index1),depth_cropped_est(index2),same_ratio_cropped_ext));
            if log
                if ord(gt(index1),gt(index2),same_ratio_gt)~=ord(depth_est_cropped(index1),depth_est_cropped(index2),same_ratio_est_cropped)
                    [tempx,tempy] = index2index(index1,size(gt,1));
    %                         sprintf('%s-%s',tempx,tempy);
                    points1 = [points1;[tempy,tempx]];
                    [tempx,tempy] = index2index(index2,size(gt,1));
                    points2 = [points2;[tempy,tempx]];
                    sprintf('pairs: [%d %d]-[%d %d] \ngt: %d-%d --> ratio: %d  \nest: %d-%d --> ratio: %d',points1(end,:),points2(end,:),gt(index1),gt(index2),ord(gt(index1),gt(index2),same_ratio_gt),depth_est_cropped(index1),depth_est_cropped(index2),ord(depth_est_cropped(index1),depth_est_cropped(index2),same_ratio_est_cropped))
                end
    %               if ord(gt(index1),gt(index2))~=ord(depth_cropped_est(index1),depth_cropped_est(index2))
    %               end
            end
        end
    end
end
end

function out = ord(val1,val2,delta)
ratio = val1/val2;
if ratio > delta
    out = 1;
elseif ratio < 1/delta
    out = -1;
else
    out = 0;
end
end

function [x,y] = index2index(index,rows)
x=mod(index,rows);
y=floor(index/rows)+1;
if x == 0
    x = rows;
    y = y-1; 
end  
end


