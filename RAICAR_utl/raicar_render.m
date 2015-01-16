function raicar_render (toshow, anat, thresh)
%
% function raicar_render (toshow, anat, thresh)
%
% Author: Zhi Yang
% Version: 2.0
% Last change: July 1, 2007
% 
% Purpose: 
%   rander a map with the statistical map overlaid on anatomy image 
% Input:
%   toshow : the statistical map to show (overlay, 2D matrix)
%   anat   : anatomy image (underlay, 2D matrix)
%   thresh : threshold for the statistical map. only values have a larger 
%            absolute value than thresh will be shown
% Output:
%   None
%

% check input
if ndims (toshow) ~= 2
    error ('raicar_render requires the first input as a 2D matrix, but now it is %d', ndims (toshow));
end
if ndims (anat) ~= 2
    error ('raicar_render requires the second input as a 2D matrix, but now it is %d', ndims (anat));
end
if ~isa (thresh, 'numeric') 
    error ('raicar_render requires the third input as a scalar, but now it is not');
end
sz = size (toshow);
szAnat = size (anat);
if sz(1)==0 || sz(2) == 0
    error ('raicar_render: input map is empty');
end
if szAnat(1)==0 || szAnat(2) == 0
    error ('raicar_render: input anatomy image is empty');
end

% initialize
UP = 5; % intensity range to show
overlay_cmap = colormap ('jet');
anat_cmap    = colormap ('gray');

if szAnat ~= sz
    % resize the overlay
    toshow = imresize (squeeze (toshow), [szAnat(1) szAnat(2)]);  
    sz = size (toshow);
end

% scale the image intensity
anat = round (63 * (anat - min (anat(:))) ./ (max (anat(:)) - min (anat(:)))) + 1;
toshow_orig = toshow;
toshow (toshow > UP) = UP;
toshow (toshow < -UP) = -UP;
toshow = round (63 * (toshow + UP)/2/UP) + 1;

% assign color
anat_RGB = zeros ([sz 3]);
overlay_RGB = zeros ([sz 3]);
for RGB_dim = 1:3 
    overlay_color_vals = overlay_cmap(toshow, RGB_dim);
    anat_color_vals = anat_cmap(anat, RGB_dim);
    overlay_RGB(:, :, RGB_dim) = reshape (overlay_color_vals, sz);
    anat_RGB(:, :, RGB_dim) = reshape (anat_color_vals, sz);
end 

% rethreshold the map to only show supra-threshold voxels
overlay_threshed = (abs (toshow_orig) > thresh);

% merge and show
opacity = 1;
compound_RGB = zeros ([sz 3]);
for RGB_dim = 1:3
    compound_RGB(:,:,RGB_dim) = ...
        opacity*overlay_threshed.*overlay_RGB(:,:,RGB_dim) + ...
        (1-opacity)*overlay_threshed.*anat_RGB(:,:,RGB_dim)+ ...
        (1-overlay_threshed).* anat_RGB(:,:,RGB_dim);
end        
compound_RGB = min (compound_RGB,1);
image (compound_RGB);
axis ('image');
axis off,
text(10, sz(1)-25, 'R', 'color', [1,1,1]);
