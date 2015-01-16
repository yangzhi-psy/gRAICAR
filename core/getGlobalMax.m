function [val, ind]  = getMax (obj, include_row, include_col, exclude_row, exclude_col)
% function [val, ind]  = getMax (obj, include_row, include_col, exclude_row, exclude_col)
% function to retrieve global maximum in the big matrix MICM
% input: 
%       obj: the object containing the current analysis information
%       include_row/include_col: a 2-dimensional matrix containing the indices of the
%       blocks to include during the searching. leave empty for the whole
%       (see examples)
%       matrix
%       exclude_row/exclude_col: (optional) a 2-dimensional matrix containing the indices of the blocks to be excluded
%       when searching for the maximum (see examples)
% output:
%       val: the maximum value
%       ind: the location of the maximum value
% example:
%       [val, ind] = getMax (obj);
%       [val, ind] = getMax (obj, [1:2], [4:6]);
%       [val, ind] = getMax (obj, [], [], [31:60], [31:60] );
%       [val, ind] = getMax (obj, [], [], [31:60; 91:120], [31:60; 91:120] );


lgth_row = length (range_row);
lgth_col = length (range_col);
r = 0;
c = 0;
for i = 1:lgth_row
    for j = 1:lgth_col
        r = range_row(i);
        c = range_col(j);
        % if the block is not in the diagnoal of MICM 
        if r ~= c            
            % if c>r, the block is in the upper triangle of MICM
            if c > r
                blks(oldpos(1)+1:oldpos(1)+obj.result.trialTab(r, 3), ...
                    oldpos(2)+1:oldpos(2)+obj.result.trialTab(c, 3)) ...
                    = cell2mat (obj.result.MICM(obj.result.refTab(r, c)));
            end
            
            oldpos(2) = oldpos(2)+obj.result.trialTab(c, 3);
        end
    end
    if r ~= c
        oldpos(1) = oldpos(1)+obj.result.trialTab(r, 3);
    end
end
            