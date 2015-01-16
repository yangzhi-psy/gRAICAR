
function reformMap = singleMap_2Dto4D (map, szMsk, coordTable)

% purpose: convert a single component map from 1D vector into a 4D image
% input:
%		map: a vector containing the component map
%		szMsk: the SIZ structure of the brain mask, can be obtained by szMsk = size (obj.result.mask);
%		coordTable: a table containing 3 columns corresponding to the x,y,z coordinates for each valid voxel
% output:
%		reformMap: a 3D image matrix

reformMap = zeros([szMsk,1]);
IND = sub2ind(szMsk, coordTable(1,:), coordTable(2,:),coordTable(3,:));
reformMap(IND) = map;

