function imgNorm = normImg(img)

     imgNorm=(img-min(img(:)))/(max(img(:))-min(img(:)))
     imgNorm(isnan(imgNorm))=0;
   