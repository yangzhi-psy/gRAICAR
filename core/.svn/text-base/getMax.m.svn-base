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
%       ind: a 4-element vector containing the location of the maximum
%       value. The first two are the locations of the block containing the
%       maximum, the last two are the locations of the maximum in the
%       block.
% example:
%       [val, ind] = getMax (obj);
%       [val, ind] = getMax (obj, [1:2], [4:6]);
%       [val, ind] = getMax (obj, [], [], [31:60], [31:60] );
%       [val, ind] = getMax (obj, [], [], [31:60; 91:120], [31:60; 91:120] );
%       

if nargin == 1
    include_row = 1:size (obj.result.trialTab, 1);
    include_col = include_row;
    exclude_row = [];
    exclude_col = [];
elseif nargin == 3
    exclude_row = [];
    exclude_col = [];
elseif nargin == 5
else
    error ('incorrect input parameters\n');
end

if isempty (include_row)
    include_row = 1:size (obj.result.trialTab, 1);
    include_col = include_row;
end

[numRg_include, lgth_row_include] = size (include_row);
[numRg_include, lgth_col_include] = size (include_col);
val = 0;
ind = zeros (1, 4);

for region = numRg_include
    for i = 1:lgth_row_include
        for j = 1:lgth_col_include
            r = include_row(i);
            c = include_col(j);
            
            % exclude blocks
            flag_exclude = 0;
            for k = 1:size (exclude_row, 1)
                if ~isempty (find (exclude_row(k, :) == r)) && ~isempty (find (exclude_col(k, :) == c))
                    flag_exclude = 1;
                end
            end
            
            if flag_exclude == 0
                % if the block is not in the diagnoal of MICM 
                if r ~= c            
                    % if c>r, the block is in the upper triangle of MICM
                    if c > r
                        tmp = cell2mat (obj.result.MICM(obj.result.refTab(r, c)));
                        [v, id] = max (tmp(:));
                        if val < v
                            val = v;
                            [ind(3), ind(4)] = ind2sub (size (tmp), id);
                            ind(1) = r;
                            ind(2) = c;
                        end
                    end
                end  
            end
            
        end
    end
end

            