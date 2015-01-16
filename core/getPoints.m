function point = getPoints (obj, range_row, range_col, row_no, col_no)
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
%

lgth_row = length (range_row);
point = sparse (lgth_row, 1);

for i = 1:lgth_row
    r = range_row(i);
    c = range_col(i);
    if r ~= c    
        % if c>r, the block is in the upper triangle of MICM
        if c > r
            tmp = cell2mat (obj.result.MICM(obj.result.refTab(r, c)));
            point(i) = tmp(row_no, col_no);
        else
            tmp = cell2mat (obj.result.MICM(obj.result.refTab(c, r)));
            point(i) = tmp(col_no, row_no);
        end
    end
end
            