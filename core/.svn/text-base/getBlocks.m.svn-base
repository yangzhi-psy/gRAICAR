function blks = getBlocks (obj, range_row, range_col)
% function getBlocks (obj, range)
% function to retrieve blocks in the big matrix MICM
% input: 
%       obj: the object containing the current analysis information
%       range_row: a vector indicating the range in the row to acquire. 
%                   the unit is block.
%       range_col: a vector indicating the range in the column to acquire. 
%                   the unit is block.
% output:
%       blks: concatenated blocks
% example:
%       blks = getBlocks (obj, 2:3, 4:6);
%

blks = zeros (sum (obj.result.trialTab(range_row, 3)), ...
    sum (obj.result.trialTab(range_col, 3)));

oldpos = [0, 0];
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
            else
                tmp = cell2mat (obj.result.MICM(obj.result.refTab(c, r)));
                blks(oldpos(1)+1:oldpos(1)+obj.result.trialTab(r, 3), ...
                    oldpos(2)+1:oldpos(2)+obj.result.trialTab(c, 3)) = tmp';
            end
            
            oldpos(2) = oldpos(2)+obj.result.trialTab(c, 3);
        end
    end
    if r ~= c
        oldpos(1) = oldpos(1)+obj.result.trialTab(r, 3);
    end
end
            
                

