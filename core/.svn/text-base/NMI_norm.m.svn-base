function con2 = NMI_norm (con)
% function con2 = NMI_norm (con)
% function for normalizing the NMI blocks

[m, n] = size (con);
mean_c = mean (con, 1);
mean_r = mean (con, 2);

std_c = std (con, 0, 1);
std_r = std (con, 0, 2);

mean_r = repmat (mean_r, [1, n]);
mean_c = repmat (mean_c, [m, 1]);
std_c = repmat (std_c, [m, 1]);
std_r = repmat (std_r, [1, n]);

ma = (mean_r+mean_c)/2;
st = (std_r*m+std_c*n)/(m+n-1)+0.00001;

con2 = (con-ma)./st;
