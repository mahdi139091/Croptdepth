function output = SIRMSE(estimation,gt)
%SIRMSE Summary of this function goes here
%   Detailed explanation goes here
n = size(estimation,1)*size(estimation,2);
gt = rescale(gt,0,1);
estimation= rescale(estimation,0,1);

gt(gt==0)=1;
estimation(estimation==0)=1;
r = log(estimation)-log(gt);

output = (1/n)*sum(r.^2,'all')-(1/(n.^2))*(sum(r,'all'))^2;
end

