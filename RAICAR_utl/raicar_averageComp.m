function [subj] = raicar_averageComp (subj)
%
% function [subj] = raicar_averageComp (subj)
%
% Author: Zhi Yang
% Version: 2.0
% Last change: June 18, 2007
% 
% Purpose: 
%   average components according to the aligned table 
% Input:
%   subj: subject object. The following input field will affect this
%   function:
%       subj.result.foundComp  : a table containing the realization componnets
%                               (RCs) in each aligned component
%       subj.result.orderedRepro  : reproducibility rank of the aligned
%                                components
% Output:
%   subj: subject object. The following input field will be add/modified  in this
%   function:
%       subj.result.aveMap     : averaged component maps (Z-normalized, 4D matrix);
%       subj.result.aveTc      : averaged component time courses (Z-normalized, 2D);
% 

fprintf ('\n Averaging components (This may take several minutes)...\n');
% initialize
[numPt, numVx] = size (subj.result.forIca);

% average components
fprintf ('\t');
for i = 1:size (subj.result.foundComp, 1)
    
    % number of average (# of cols) 
    existRl = find (subj.result.foundComp(i,:) ~= 0);  % total number of realizations needs to be averaged
    numAve = length (existRl);          
    if numAve == 0
        break;
    end

    % use first component as base, others will correlate with it to decide the sign
    realization = existRl(1);
    compNum = subj.result.foundComp(i,realization) - sum (subj.result.numIC(1:realization-1));  % which component
    matNm = strcat (subj.setup.rlPrefix, num2str(realization+subj.setup.start-1), '.mat');
    ica = load (matNm);
    numPt = size (ica.A, 1);
    s1 = (ica.icasig(compNum,:) - mean (ica.icasig(compNum,:)))/std (ica.icasig(compNum,:));   
    t1 = (ica.A(:, compNum) - mean (ica.A(:, compNum)))/std (ica.A(:,compNum));   
    subj.result.aveMap(i,1:numVx) = s1;
    subj.result.aveTc(1:numPt, i) = t1;

    % other components
    for j = 2:numAve
        realization = existRl(j) ;
        compNum = subj.result.foundComp(i,realization) - sum (subj.result.numIC(1:realization-1));
        matNm = strcat(subj.setup.rlPrefix, num2str(realization+subj.setup.start-1), '.mat');
        ica = load(matNm);
        s2 = (ica.icasig(compNum,:) - mean (ica.icasig(compNum,:)))/std (ica.icasig(compNum,:));   
        t2 = (ica.A(:, compNum) - mean (ica.A(:, compNum)))/std (ica.A(:,compNum));  
        tmp = corrcoef (s1',s2');
        subj.result.aveMap(i, 1:numVx) = subj.result.aveMap(i, 1:numVx) + sign (tmp(1,2)) * s2;
        tmp = corrcoef (t1,t2);
        subj.result.aveTc(1:numPt, i) = subj.result.aveTc(1:numPt, i) + sign (tmp(1,2)) * t2;
    end

    % if reproducibility is zero or the averaged component has nothing 
    if max (subj.result.aveMap(i,:))== min (subj.result.aveMap(i,:)) || subj.result.orderedRepro(i) == 0
        subj.result.aveMap(i:end, :) = [];
        subj.result.aveTc(:,i:end) = [];
        subj.result.foundComp(i:end,:) = [];
        subj.result.orderedRepro(i:end) = [];
        break;
    end

    fprintf (strcat ( num2str(i), '...'));
    if mod (i, 15) == 0
            fprintf ('\n\t');
    end
end
fprintf ('\n');

% normalize and reform result
[subj]= raicar_reformResult (subj);

fprintf ('\tsuccess\n');
