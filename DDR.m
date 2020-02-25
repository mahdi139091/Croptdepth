function [sum_est_cropped_err, sum_cropped_est_err] = DDR(gt,depth_est_cropped,depth_cropped_est,image)
%DDR Summary of this function goes here
%   Detailed explanation goes here
if size(image,3)==3
    image = rgb2gray(uint16(image));
end
[gradient_gt,~] = imgradient(uint16(gt));
[gradient_est_cropped,~] = imgradient(uint16(depth_est_cropped));
[gradient_cropped_est,~] = imgradient(uint16(depth_cropped_est));
[gradient_image,~] = imgradient(uint16(image));

gradient = gradient_est_cropped + gradient_cropped_est + gradient_gt;

% figure;
% montage({uint16(gt), uint16(depth_est_cropped), uint16(depth_cropped_est), uint16(gradient_gt), uint16(gradient_est_cropped),uint16(gradient_cropped_est)},'Size',[2 3]);
% figure;
% imshow(uint16(gradient/3))

maxvalue = max(gradient,[],'all');
threshold = round(0.2 * maxvalue);

validpoints_ind = find(gradient<threshold);

random_index = randi([1 length(validpoints_ind)],1,1000);

selected_pionts = validpoints_ind(random_index);

sum_est_cropped_err = 0;
sum_cropped_est_err = 0;

for i=1:length(selected_pionts)
    for j=1:length(selected_pionts)
        if i~=j
            index1=selected_pionts(i);
            index2=selected_pionts(j); 
            
            if ord(gt(index1),gt(index2))~=0 && ord(gt(index1),gt(index2))~=ord(depth_est_cropped(index1),depth_est_cropped(index2))
                sum_est_cropped_err = sum_est_cropped_err + 1;
            end
            
            if ord(gt(index1),gt(index2))~=0 && ord(gt(index1),gt(index2))~=ord(depth_cropped_est(index1),depth_cropped_est(index2))
                sum_cropped_est_err = sum_cropped_est_err + 1;
            end
            
        end
    end
end
end

function out = ord(val1,val2)
delta = 0.1;
ratio = val1/val2;
if ratio > 1+delta
    out = 1;
elseif ratio < 1-delta
    out = -1;
else
    out = 0;
end
end


