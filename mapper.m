function output = mapper(estimation,gt)
%MAPPER Summary of this function goes here
%   Detailed explanation goes here

estimation_flat = reshape(estimation', [size(estimation,1)*size(estimation,2) 1]);
gt_flat = reshape(gt', [size(gt,1)*size(gt,2) 1]);

X = [ones(size(estimation_flat)) estimation_flat];
b = X\gt_flat;    % Removes NaN data

output =  round(b(1) + estimation.*b(2));

minval = min(gt,[],'all');
maxval = max(gt,[],'all');

output(output>maxval)=maxval;
output(output<minval)=minval;

% 
% if minval<0
%     minval=0;
% end
% 
% if maxval>65535
%     maxval=65535;
% end
% output = rescale(output,minval,maxval);

end

