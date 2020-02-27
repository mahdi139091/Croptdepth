function gmsd = gmsd(x, y)

[mag_x,dir_x]=imgradient(x);
[mag_y,dir_y]=imgradient(y);

mag_x = mapper(mag_x,mag_y);

gms=(2.*mag_x.*mag_y+0.0026)/(mag_x.^2+mag_y.^2+0.0026);

gmsm=sum(gms(:))/length(gms);

gmsd=sqrt(sum(gms(:)-gmsm).^2/length(gms));