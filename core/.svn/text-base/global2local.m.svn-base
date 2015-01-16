function [rl, cp] = global2local (idx, rangeTable1)

% Purpose: convert global indices from the MICM to local indices, in (rl, cp)
% form 
% Input:
%       idx: a vector containing the global indices
%       rangeTable1: a table containing the global indices of the last IC in the previous
%       trials (IC sets),starting from 0.
% Output:
%       rl: realization index (same length as idx)
%       cp: component index (same length as idx)

len = length (idx);
rl = zeros (len, 1);
cp = rl;

for j = 1:len    
diff_idx = idx-rangeTable1;
tmp_pos_idx = find(diff_idx>0);
rl(j) = tmp_pos_idx(end);
cp(j) = idx - rangeTable1(rl(j));
end