function [similarity, subj_load, cons_inter_sb, cons_intra_sb] = sepIntra_Inter (obj, cp, repro)

if nargin < 3
    repro = full(cell2mat(obj.result.foundRepro(cp)));
	repro = repro+repro';
end

subNum = obj.setup.subNum;
numTrials = obj.setup.trial(1); %assuming all subjects have same numbers of ICA instances
cons_inter_sb = zeros (subNum);
reli_inter_sb = cons_inter_sb ;
cons_intra_sb = zeros (subNum, 1);
reli_intra_sb =cons_intra_sb;
subj_load = zeros(subNum, 1);


for row = 1:subNum
    for col = row+1:subNum
         localData = repro((row-1)*numTrials+1:row*numTrials, (col-1)*numTrials+1:col*numTrials);
         cons_inter_sb(row, col) = mean (localData(:));
         cons_inter_sb(col, row) = cons_inter_sb(row, col);
         reli_inter_sb(row, col) = (std (localData(:)));
         reli_inter_sb(col, row) =reli_inter_sb(row, col);
    end
    % self-variance (intra-subject variance: importance of the subject)
    localData = repro((row-1)*numTrials+1:row*numTrials, (row-1)*numTrials+1:row*numTrials);
    cons_intra_sb(row) = mean (localData(:));
    reli_intra_sb(row) = (std (localData(:)));
end

similarity = cons_inter_sb;
% comp_repromap = cons_inter_sb+diag(cons_intra_sb);


%similarity = zeros (subNum);
%for row = 1:subNum
%    for col = row+1:subNum
%%        similarity (row, col) = cons_inter_sb(row, col)* cons_intra_sb(row) * cons_intra_sb(col);
%        similarity (row, col) = cons_inter_sb(row, col);%* cons_intra_sb(row) * cons_intra_sb(col);
%    end
%end
%similarity = similarity+similarity';
%
%% min_sim = min(min(triu(similarity)));
%% max_sim = max(max(triu(similarity)));
%
%
%% norm_similarity = (similarity-min_sim)/(max_sim-min_sim);
%% norm_similarity = (1-eye(subNum)).*norm_similarity;
%norm_similarity = similarity;
%for row = 1:subNum
%    subj_load(row) = mean (norm_similarity(row, :)); %./std(norm_similarity(row,:));   
%%  localData = repro((row-1)*numTrials+1:row*numTrials,:);
%  subj_load(row) = mean(localData(:))./std(localData(:));
%end


% subj_load = subj_load./sum(subj_load);
