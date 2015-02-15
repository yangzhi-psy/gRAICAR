function [subj, flagEnough] = raicar_findComp (subj, siz, count)
%
% function [subj] = raicar_findComp (subj, siz, count)
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
%       subj.setup.trials  : the number of ICA realizations
%   siz:  the size of the CRCM
%   count: index of the current component
%
% Output:
%   subj : subject object. The following input field will be add/modified  in this
%   function:
%       subj.result.CRCM   : the CRCM matrix. The searched entries will be
%                            set to negative value
%   	subj.result.foundComp  : a table containing the realization componnets
%                (RCs) in the current aligned component
%   flagEnough : a flag indicating the termination of the search. nonzero
%                means terminate search.
%   

% initialize
trials = subj.setup.trials;
subj.result.foundComp(count, :) = 0;
flagEnough = 0;

% search for the largest correlation coefficient 
[mval, mpos] = max (subj.result.CRCM(:));

if full (mval) < subj.result.threshold
	flagEnough = 1;
	subj.result.foundComp(count, :) = 0;
	return;
end

% determine the position of the maxima
[rowNo,y] = ind2sub(siz, mpos);    

% extract the corresponding row and column
row = full (subj.result.CRCM (rowNo, :));
col = full (subj.result.CRCM (:, y));

% search in row and column
row_mval = zeros (trials, 1);
row_mpos = zeros (trials, 1);
col_mval = zeros (trials, 1);
col_mpos = zeros (trials, 1);
for rl = 1:trials
	numIC = subj.result.numIC(rl);
        [row_mval(rl), row_mpos(rl)] = max (row((rl-1)*numIC+1:rl*numIC));
        row_mpos(rl) = row_mpos(rl) + (rl-1)*numIC;
        [col_mval(rl), col_mpos(rl)] = max (col((rl-1)*numIC+1:rl*numIC));
        col_mpos(rl) = col_mpos(rl) + (rl-1)*numIC;
        
        %[row_mval(rl), row_mpos(rl), col_mval(rl), col_mpos(rl)],
        if row_mval(rl) > 0 && col_mval(rl) > 0
            
            if col_mpos(rl) ~= row_mpos(rl)
                if row_mval(rl) <= col_mval(rl)
                    subj.result.foundComp(count, rl) = col_mpos(rl);
                else
                    subj.result.foundComp(count, rl) = row_mpos(rl);  
                end
            else
                subj.result.foundComp(count, rl) = row_mpos(rl);
            end    
        elseif row_mval(rl) > 0 && col_mval(rl) <= 0
                subj.result.foundComp(count, rl) = row_mpos(rl);
        elseif row_mval(rl) <= 0 && col_mval(rl) > 0
                subj.result.foundComp(count, rl) = col_mpos(rl);
        else
               subj.result.foundComp(count, rl) = 0;
        end         
end

% mask out the used entry
for rl = 1:trials
    if subj.result.foundComp(count, rl) > 0
        subj.result.CRCM(:,subj.result.foundComp(count, rl)) = ...
            -abs(subj.result.CRCM(:,subj.result.foundComp(count, rl)));
        subj.result.CRCM(subj.result.foundComp(count, rl), :) = ...
            -abs(subj.result.CRCM(subj.result.foundComp(count, rl), :));
    end
end

