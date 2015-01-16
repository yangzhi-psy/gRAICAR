function [reformMap] = raicar_2Dto3D (map, mskSz, coordTable)
%
% function [reformMap] = raicar_2Dto3D (map, mskSz, coordTable)
%
% Author: Zhi Yang
% Version: 2.0
% Last change: June 30, 2007
% 
% Purpose: 
%   reform the input data into 3-D matrix, which is an opposite operation
%   to raicar_3Dto2D
%   This function is used to generate surface data, instead of volume maps
% 
% Input:
%   orig : 2-D matrix from ICA
%   mskSz: a 3-element vector containing the dimensionality of the data
%   (i.e., the size of the original mask)
%   coordTable: a table containing the locations of the selected voxels
% 
% Output:
%   reformMap: reformed 3-D map
%

% check input 
[errMsg] = nargchk(3, 3, nargin);
if ~isempty (errMsg)
    error ('raicar_2Dto3D takes and only takes three input argument: 2-D map, mskSz, and coordTable');
end
dimsMap = size (map);
if length (dimsMap) ~= 2
    error ('raicar_2Dto3D requires the first input argument as a 2-D matrix, but now it is %d-D', length (dimsMap));
end
if length (mskSz) ~= 2
    error ('raicar_2Dto3D requires the second input argument as a 2-element vector, but now its size is %d', length (mskSz));
end
dimsTable = size (coordTable);
if length (dimsTable) ~= 2 || dimsTable(1) ~= 2
    error ('raicar_2Dto3D requires the third input argument as a 2-D matrix (2*numVoxel), but now it is %d dimension, first dimension: %d',length (dimsTable), dimsTable(1));
end

% check whether the map and coordTable match with each other
if dimsTable(2) ~= dimsMap (2)
    error ('raicar_2Dto4D found the coordTable did not match to the 2-D map');
end

% reshape map to 3D
tmp = map;
reformMap = zeros ([mskSz(1),1, mskSz(2), dimsMap(1)]);
for i = 1:size (coordTable, 2)
    reformMap (coordTable(1,i), 1,coordTable(2,i),:) = squeeze(tmp(:, i));
end
