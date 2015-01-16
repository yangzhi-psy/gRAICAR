function [coordTable] = makeCoordTable (mask)

dimsMask = size (mask);
if length (dimsMask) ~= 3
    error ('requires the input argument as a 3-D matrix, but now it is %d-D', length (dimsMask));
end

% reform the matrix to 2-dims
    % reshape the mask to 2-dims matrix
reformMask = reshape (mask, [dimsMask(1)*dimsMask(2)*dimsMask(3), 1]);
    % create coordinate table recoding the 3-dim coordinates of the element of reshaped matrix  
[coordX coordY coordZ] = ind2sub (size(mask), 1:dimsMask(1)*dimsMask(2)*dimsMask(3));
coordTable = [coordX' coordY' coordZ'];
    % mask out the voxels out of brain
coordTable (reformMask == 0,:) = [];  % go with the dataset to keep a record of  the corresponding 3-dim coordinates
    % transport the forIca matrix to n*v form
coordTable = coordTable';

