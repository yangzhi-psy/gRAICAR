function [estimate]=calcNMI(xx, yy,total, lengthPar)

ncellx = lengthPar;%-1;
ncelly = ncellx;

h(1:ncellx,1:ncelly)=0;
total = min (size (yy, 1), size (xx,1));
for n=1:total
  indexx=xx(n);
  indexy=yy(n);
%   if indexx >= 1 && indexx <= ncellx && indexy >= 1 && indexy <= ncelly
    h(indexx,indexy)=h(indexx,indexy)+1;
%   end
end

h=h./total;



hy=sum(h);
hx=sum(h,2);

% toc,

hx = -sum (hx.*log2(hx+eps));
hy = -sum (hy.*log2(hy+eps));
hxy = -sum(sum (h.*log2(h+eps)))+eps;

estimate = (hx+hy)/hxy;



