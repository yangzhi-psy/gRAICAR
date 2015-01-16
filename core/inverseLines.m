function  obj = inverseLines (obj,range_row, row_no)
% function getBlocks (obj, range)
% function to set a row/column across the big matrix MICM to its negative
% absolute value
% input: 
%       obj: the object containing the current analysis information
%       range_row: a vector indicating the row/column locations of the blocks to
%       acquire. 
%       row_no: a vector indicating the position of the row/column in the
%       corresponding block.
%       The range_row and row_no should be vectors of the same size
% output:
%       obj: the object containing the current analysis information
% example:
%       line = getBlocks (obj, 2, 104);   % inverse component row 104 of the
%       block row 2
%

lgth_row = length (range_row);

for i = 1:lgth_row
    r = range_row(i);
    for c = 1:size (obj.result.trialTab, 1)        
        if r ~= c            
            % if c>r, the block is in the upper triangle of MICM
            if c > r
%                 tmp = full (cell2mat (obj.result.MICM(obj.result.refTab(r, c))));
%                 tmp(row_no, :) = -abs (tmp(row_no, :));
              %  tmp = cell2mat (obj.result.MICM(obj.result.refTab(r, c)));
              %  tmp (row_no, :) = 0;
              %  obj.result.MICM(obj.result.refTab(r, c)) = {tmp};
				obj.result.MICM{obj.result.refTab(r, c)}(row_no, :) = 0;
            else
%                 tmp = full (cell2mat (obj.result.MICM(obj.result.refTab(c, r))));
%                 tmp(:, row_no) = -abs (tmp(:, row_no));
              %  tmp = cell2mat (obj.result.MICM(obj.result.refTab(c, r)));
              %  tmp (:, row_no) = 0;
              %  obj.result.MICM(obj.result.refTab(c, r)) = {tmp};
				obj.result.MICM{obj.result.refTab(c, r)}(:, row_no) = 0;
            end
        end
    end
end
