function [subj] = raicar_prepareShow (subj, imagePerRow)
%
% function [subj] = raicar_prepareShow (subj, imagePerRow)
%
% Author: Zhi Yang
% Version: 2.0
% Last change: July 18, 2007
% 
% Purpose: 
%   prepare the result to show. transform the maps and anatomy image into mosaic format,
%   if the anatomy image is not provided, a mean image of the original data
%   will be generated
%
% Input:
%   subj: subject object. The following input field will affect this
%   function:
%       subj.result.anat      : anatomy image. can be empty
%       subj.result.aveMap    : averaged component maps (4D matrix)
%   imagePerRow: number of images per row in the mosaic
%
% Output:
%   subj: subject object. The following input field will be add/modified  in this
%   function:
%       subj.result.aveMap    : mosaic format of the component maps (3D
%       matrix)
%       subj.result.anat      : mosaic format of the anatomy image (2D
%       matrix)
% 

fprintf ('\n Preparing results...');

% check anatomy image
if isempty (subj.result.anat)
% generate mean EPI image
    subj.result.anat = mean (raicar_2Dto4D (subj.result.forIca, ...
    size (subj.result.mask), subj.result.coordTable), 4);
end


%     subj.result.anat = flipdim (subj.result.anat, 2);
subj.result.anat = raicar_toMosaic (subj.result.anat, imagePerRow);

% prepare result map
%     subj.result.aveMap = flipdim (subj.result.aveMap, 2);
subj.result.aveMap = raicar_toMosaic (subj.result.aveMap, imagePerRow);

fprintf ('\tsuccess\n');

    
