function [subj] = raicar_rank (subj)
%
% function [subj] = raicar_rank (subj)
%
% Author: Zhi Yang
% Version: 2.0
% Last change: June 08, 2007
% 
% Purpose: 
%   search through the CRCM, idenfy the aligned components and rank them by reproducibility 
% Input:
%   subj: subject object. The following input field will affect this
%   function:
%       subj.result.CRCM   : the CRCM matrix
% Output:
%   subj: subject object. The following input field will be add/modified  in this
%   function:
%       subj.result.foundComp  : a table containing the realization componnets
%                               (RCs) in each aligned component
%       subj.result.orderedRepro  : reproducibility rank of the aligned
%                                components
%       subj.result.orderedAcc : reproducibility rank
% 

fprintf ('\n Computing the reproducibility indices...\n');
% initialize
flagEnough = 0;
count = 1;
subj.result.foundComp = [];
subj.result.orderedRepro = zeros(1, 1);
siz = size (subj.result.CRCM);

% align components
fprintf ('\t');
while flagEnough == 0 && count< max (subj.result.numIC) +1
    [subj, flagEnough]= raicar_findComp (subj, siz, count);
    [subj] = raicar_findRepro (subj, squeeze(subj.result.foundComp(count, :)), count);
    count = count + 1;
    fprintf ('%d...', count-1);
    if mod (count-1, 15) == 0
        fprintf ('\n\t');
    end
end
fprintf ('\n');

% make sure the length of foundRepro and foundComp is equal
minl = min (length(subj.result.foundRepro), size(subj.result.foundComp,1));
subj.result.foundRepro = subj.result.foundRepro(1:minl);
subj.result.foundComp = subj.result.foundComp(1:minl, :);

% rank components
[subj.result.orderedRepro, ordered_idx] = sort (subj.result.foundRepro, 'descend');
subj.result.foundComp = subj.result.foundComp (ordered_idx, :);

fprintf ('\tsuccess\n');
