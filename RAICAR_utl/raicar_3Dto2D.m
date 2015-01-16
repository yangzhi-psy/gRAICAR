function [reformOrig, coordTable] = raicar_3Dto2D (orig, mask)
%
% function [reformOrig, coordTable] = raicar_3Dto2D (orig, mask)
%
% Author: Zhi Yang
% Last change: May 10, 2014
% 
% Purpose: 
%   reform the input data into 2-D matrix and return the mapping table
% 
% Input:
%   orig: 3-D form EPI data. This form of data is usually from surface data, where the first dimension is vertices (20420), the second dimension is 1, the third dimension is hemispheres (2), and the fourth is time points;
%	The load_nii funcion will suppress the second dimension, so the orig matrix becomes 3-D.;
%   mask: 2-D form mask data. For the same reason, the mask matrix will be 2-D (vertices * hemispheres) for surface data.
% 
% Output:
%   reformOrig:  2-D data matrix to be input to ICA;
%   coordTable:  a table containing the locations of the selected voxels
%

% check input 
[errMsg] = nargchk(2, 2, nargin);
if ~isempty (errMsg)
    error ('raicar_3Dto2D takes and only takes two input argument: 3-D data and 2-D mask');
end
dimsOrig = size (orig);
if length (dimsOrig) ~= 3
    error ('raicar_3Dto2D requires the first input argument as a 3-D matrix, but now it is %d-D', length (dimsOrig));
end
dimsMask = size (mask);
if length (dimsMask) ~= 2
    error ('raicar_3Dto2D requires the second input argument as a 2-D matrix, but now it is %d-D', length (dimsMask));
end

% check whether the mask matches the data
if dimsOrig (1:2) ~= dimsMask(1:2) ...
       | length (dimsOrig) ~= 3 | length (dimsMask) ~= 2
    error('raicar_3Dto2D found the mask did not match the data');
end

% reform the matrix to 2-dims
    % reshape the orig and mask to 2-dims matrix
reformOrig = cat (1, orig(:,1,:), orig(:,2,:)); %reshape (orig, [dimsOrig(1)*dimsOrig(2), dimsOrig(3)]);
reformOrig = squeeze(reformOrig);
reformMask = cat (1, mask(:,1,:), mask(:,2,:)); %reshape (mask, [dimsOrig(1)*dimsOrig(2), 1]);
reformMask = squeeze(reformMask);
    % create coordinate table recoding the 3-dim coordinates of the element of reshaped matrix  
[coordX coordY] = ind2sub (size(mask), 1:dimsOrig(1)*dimsOrig(2));
coordTable = [coordX' coordY'];
    % mask out the voxels out of brain
reformOrig (reformMask == 0,:) = [];
coordTable (reformMask == 0,:) = [];  % go with the dataset to keep a record of  the corresponding 2-dim coordinates
    % transport the forIca matrix to n*v form
reformOrig = reformOrig';
coordTable = coordTable';
