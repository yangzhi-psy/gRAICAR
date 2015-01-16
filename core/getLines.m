function line = getLines (obj, range_row, row_no)
% function getBlocks (obj, range)
% function to retrieve a row/column across the big matrix MICM
% input: 
%       obj: the object containing the current analysis information
%       range_row: a vector indicating the row/column locations of the blocks to
%       acquire. 
%       row_no: a vector indicating the position of the row/column in the
%       corresponding block.
%       The range_row and row_no should be vectors of the same size
% output:
%       line: a column vector, containing concatenated rows/columns
% example:
%       line = getBlocks (obj, 2, 104);   % retrieve component 104 of the
%       block row/column 2



lgth_row = length (range_row);

line = zeros (sum (obj.result.trialTab(:, 3)), 1);
oldpos =0;

for i = 1:lgth_row
    r = range_row(i);
    for c = 1:size (obj.result.trialTab, 1)
      
            if r ~= c    
                % if c>r, the block is in the upper triangle of MICM
                if c > r
                    tmp = full (cell2mat (obj.result.MICM(obj.result.refTab(r, c))));
                    tmp =  ((tmp(row_no, :)));
                    line(oldpos+1:oldpos+size (tmp, 2)) = tmp;
                else
                    tmp = cell2mat (obj.result.MICM(obj.result.refTab(c, r)));
                    line(oldpos+1:oldpos+size (tmp, 1)) = tmp(:, row_no);
                end
            end
            oldpos = oldpos+obj.result.trialTab(c, 3);
    end
end
            