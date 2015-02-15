function [subj] = raicar_findRepro (subj, foundComp, count)
%
% function foundRepro = raicar_findRepro (subj, foundComp, count)
%
% Author: Zhi Yang
% Version: 2.0
% Last change: June 08, 2007
% 
% Purpose: 
%   search through the CRCM, idenfy the aligned components and rank them by reproducibility 
% Input:
%   subj : subject object. The following input field will affect this
%                  function:
%       subj.result.CRCM   : the CRCM matrix
%   foundComp    : a table containing the realization componnets
%                  (RCs) in the current aligned component 
%   count        : index of the current aligned component
% Output:
%   subj : subject object. The following input field will be add/modified  in this
%   function:
%       subj.result.foundComp  : a table containing the realization componnets
%                               (RCs) in each aligned component. If the
%                               reproducibility is zero, the corresponding
%                               aligned component will be removed
%   foundRepro   : reproducibility of the current aligned component
%

% initialize
lgth = nnz (foundComp);
subj.result.foundRepro(count) = 0;

% calculate reproducibility
for i = 1:lgth-1
    oldRepro = subj.result.foundRepro(count);
    for j = i+1:lgth
        if foundComp(i) >0 && foundComp(j) > 0 
            tmp =  full (abs(subj.result.CRCM(foundComp(i), foundComp(j))));
            if tmp >= subj.result.threshold
                subj.result.foundRepro(count) = subj.result.foundRepro(count) + tmp;
            end
        end
    end
    if subj.result.foundRepro(count) == oldRepro
        subj.result.foundComp(count,i) = 0;
    end
end
