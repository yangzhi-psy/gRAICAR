function mosaic = raicar_toMosaic (map, imPerRow)
%
% function mosaic = raicar_toMosaic (map, imPerRow)
%
% Author: Zhi Yang
% Version: 2.0
% Last change: July 1, 2007
% 
% Purpose: 
%   transform 4D or 3D map to mosaic format (3D or 2D)
% 
% Input:
%   map      : 3D or 4D map matrix
%   imPreRow : an integer indicating how many images per row in the mosaic   
% 
% Output:
%   mosaic   : mosaic format map
%

% check input
[errMsg] = nargchk(2, 2, nargin);
if ~isempty (errMsg)
    error ('raicar_mosaic takes and only takes two input argument: 3 or 4-D map, imPerRow');
end

sz = size (map);
if length (sz) < 3 || length (sz) > 4
    error ('raicar_toMosaic requires the first input as a 3 or 4-dimensional matrix, but now it is %d', length(sz));
end

if ~isa (imPerRow, 'numeric') || mod (imPerRow, 1) ~= 0 
    error ('raicar_toMosaic requires the second input as an integer');
end
   
% initialize
numRows = floor (sz(3)/imPerRow);
remain = sz(3)-numRows*imPerRow;

% transformation
if length (sz) == 4
    for i = 1:numRows
        for j = 1:imPerRow
            mosaic((i-1)*sz(2)+1:i*sz(2), (j-1)*sz(1)+1:j*sz(1), :) = ...
                permute(squeeze (map(:,:,(i-1)*imPerRow+j,:)),[2 1 3]);
        end
    end
    
    if remain > 0
        for j = 1:remain
            mosaic(numRows*sz(2)+1:(numRows+1)*sz(2), (j-1)*sz(1)+1:j*sz(1), :) = ...
                permute (squeeze (map(:,:,numRows*imPerRow+j,:)),[2 1 3]);
        end
    end
else
    for i = 1:numRows
        for j = 1:imPerRow
            mosaic((i-1)*sz(2)+1:i*sz(2), (j-1)*sz(1)+1:j*sz(1)) = ...
                permute(squeeze (map(:,:,(i-1)*imPerRow+j)),[2 1 3]);
        end
    end
    
    if remain > 0
        for j = 1:remain
            mosaic(numRows*sz(2)+1:(numRows+1)*sz(2), (j-1)*sz(1)+1:j*sz(1)) = ...
                permute (squeeze (map(:,:,numRows*imPerRow+j)),[2 1 3]);
        end
    end
end