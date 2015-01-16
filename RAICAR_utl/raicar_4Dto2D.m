function [reformOrig, coordTable] = raicar_4Dto2D (orig, mask)
%
% function [reformOrig, coordTable] = raicar_4Dto2D (orig, mask)
%
% Author: Zhi Yang
% Version: 2.0
% Last change: June 30, 2007
% 
% Purpose: 
%   reform the input data into 2-D matrix and return the mapping table
% 
% Input:
%   orig: 4-D form EPI data;
%   mask: 3-D form mask data;
% 
% Output:
%   reformOrig:  2-D data matrix to be input to ICA;
%   coordTable:  a table containing the locations of the selected voxels
%

% check input 
[errMsg] = nargchk(2, 2, nargin);
if ~isempty (errMsg)
    error ('raicar_4Dto2D takes and only takes two input argument: 4-D data and 3-D mask');
end
dimsOrig = size (orig);
if length (dimsOrig) ~= 4
    error ('raicar_4Dto2D requires the first input argument as a 4-D matrix, but now it is %d-D', length (dimsOrig));
end
dimsMask = size (mask);
if length (dimsMask) ~= 3
    error ('raicar_4Dto2D requires the second input argument as a 3-D matrix, but now it is %d-D', length (dimsMask));
end

% check whether the mask matches the data
if dimsOrig (1:3) ~= dimsMask(1:3) ...
       | length (dimsOrig) ~= 4 | length (dimsMask) ~= 3
    error('raicar_4Dto2D found the mask did not match the data');
end

% reform the matrix to 2-dims
    % reshape the orig and mask to 2-dims matrix
reformOrig = reshape (orig, [dimsOrig(1)*dimsOrig(2)*dimsOrig(3), dimsOrig(4)]);
reformMask = reshape (mask, [dimsOrig(1)*dimsOrig(2)*dimsOrig(3), 1]);
    % create coordinate table recoding the 3-dim coordinates of the element of reshaped matrix  
[coordX coordY coordZ] = ind2sub (size(mask), 1:dimsOrig(1)*dimsOrig(2)*dimsOrig(3));
coordTable = [coordX' coordY' coordZ'];
    % mask out the voxels out of brain
reformOrig (reformMask == 0,:) = [];
coordTable (reformMask == 0,:) = [];  % go with the dataset to keep a record of  the corresponding 3-dim coordinates
    % transport the forIca matrix to n*v form
reformOrig = reformOrig';
coordTable = coordTable';
