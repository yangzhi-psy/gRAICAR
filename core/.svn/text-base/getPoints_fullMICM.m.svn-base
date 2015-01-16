function point = getPoints_fullMICM (obj, range_row, range_col, row_no, col_no)
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
point = zeros (lgth_row, 1);

for i = 1:lgth_row
    r = range_row(i);
    c = range_col(i);
    
    if r ~= c 
        pos_r = sum(obj.result.trialTab(1:r-1, 3))+row_no;
        pos_c = sum(obj.result.trialTab(1:c-1, 3))+col_no;
        % if c>r, the block is in the upper triangle of MICM
        if c > r        
            point(i) = obj.result.MICM(pos_r, pos_c);
        else
            point(i) = obj.result.MICM(pos_c, pos_r);
        end
    end
end
            