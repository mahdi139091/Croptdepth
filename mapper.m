function output = mapper(input1,input2)
%MAPPER Summary of this function goes here
%   Detailed explanation goes here

est_rang = max(input2(:)) - min(input2(:));

input1_cropped = input1(input2>min(input2(:)')+0.2*est_rang & input2<max(input2(:))-0.2*est_rang);
input2_cropped = input2(input2>min(input2(:))+0.2*est_rang & input2<max(input2(:))-0.2*est_rang);

input1_flat = input1_cropped;%%reshape(estimation_cropped', [size(estimation_cropped,1)*size(estimation_cropped,2) 1]);
input2_flat = input2_cropped;%reshape(gt_cropped', [size(gt_cropped,1)*size(gt_cropped,2) 1]);

X = [ones(size(input1_flat)) input1_flat];
b = X\input2_flat;    % Removes NaN data

output =  b(1) + input1.*b(2);

minval = min(output(:));
maxval = max(output(:));
 
if minval<min(input2(:))
    minval=min(input2(:));
end

if maxval>max(input2(:))
    maxval=max(input2(:));
end
output = rescale(output,minval,maxval);

end

