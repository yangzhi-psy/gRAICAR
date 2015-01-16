function [obj, m] = normByRow (obj)

% purpose: normalize each row of MICM within each RC block, generating a
%n asymmetric MICM for pagerank
% input:
%       obj: with MICM and trialTb
% output:
%       m: an asymmetric MICM for pagerank, same size as MICM, only local
%       maxima retained
%       obj: updated result.MICM, normalized by row


rangeTable2 = cumsum (obj.result.trialTab(:, 3));
rangeTable1 = [0; rangeTable2];
rangeTable1(end) = [];

m = zeros (rangeTable2(end));
for j = 1:length(rangeTable1)
    for k = j+1:length(rangeTable1)
        con = obj.result.MICM(rangeTable1(j)+1:rangeTable2(j),rangeTable1(k)+1:rangeTable2(k));
        sz = size (con);
%         % normalize by sum
%         colsum = sum(con, 2);
%         colsum = repmat (colsum, 1, sz(2));
%         con2 = con./colsum;
        
        % normalize by Z
        colmean = mean(con,2);
        colstd  = std(con,0,2);
        con_row = (con - repmat (colmean,1,sz(2)))./repmat(colstd,1,sz(2));
        
        con = obj.result.MICM(rangeTable1(j)+1:rangeTable2(j),rangeTable1(k)+1:rangeTable2(k))';
        sz = size (con);
        colmean = mean(con,2);
        colstd  = std(con,0,2);
        con_col = (con - repmat (colmean,1,sz(2)))./repmat(colstd,1,sz(2));
        
        [vmax,imax] = max (con_row, [], 2);
        t_max = zeros (size(con_row));
        for r = 1:length(imax)
            t_max(r,imax(r)) = vmax(r);
        end
        m(rangeTable1(j)+1:rangeTable2(j),rangeTable1(k)+1:rangeTable2(k)) = t_max;
        obj.result.MICM(rangeTable1(j)+1:rangeTable2(j),rangeTable1(k)+1:rangeTable2(k)) = con_row;
        
        [vmax,imax] = max (con_col, [], 2);
        t_max = zeros (size(con_col));
        for r = 1:length(imax)
            t_max(r,imax(r)) = vmax(r);
        end
        m(rangeTable1(k)+1:rangeTable2(k),rangeTable1(j)+1:rangeTable2(j)) = t_max;
        obj.result.MICM(rangeTable1(k)+1:rangeTable2(k),rangeTable1(j)+1:rangeTable2(j)) = con_col;
    end
end