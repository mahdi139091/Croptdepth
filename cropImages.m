function cropImages(directory)

%% cropping input images

datadir     = 'img/Tau/Depth';    %the directory containing the images
resultsdir  = 'results/Tau/Cropped_Estimation'; %the directory for dumping results

imglist = dir(sprintf('%s/*.dpt', datadir));
rows=3;
columns=2;

for i = 1:numel(imglist)
    
    %read in images%
    [path, imgname, dummy] = fileparts(imglist(i).name);
    img = depth_read(sprintf('%s/%s', datadir, imglist(i).name));
    
    [width,height,channel]=size(img);
    blwidth=round(width/columns);
    blheight=round(height/rows);
    
    for j = 0:columns-1
        for k = 0:rows-1
            
            if(j~=columns-1 && k~=rows-1)
                croppedImg=img(j*blwidth+1:(j+1)*blwidth+1,k*blheight+1:(k+1)*blheight+1,:);
            elseif(j==columns-1 && k~=rows-1)
                croppedImg=img(j*blwidth+1:end,k*blheight+1:(k+1)*blheight+1,:);  
            elseif(j~=columns-1 && k==rows-1)
                croppedImg=img(j*blwidth+1:(j+1)*blwidth+1,k*blheight+1:end,:);
            else
                croppedImg=img(j*blwidth+1:end,k*blheight+1:end,:);
            end
                   
              
            fname = sprintf('%s/%s_%d_%d.hdr', resultsdir, imgname,j,k);
           
            img=cat(3, croppedImg, croppedImg, croppedImg);
            hdrwrite(img,fname)
            %imwrite2tif(croppedImg, fname,'uint32');
            figure;
            imshow(croppedImg)
        end
    end
end


