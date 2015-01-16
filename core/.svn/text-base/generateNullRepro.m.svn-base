function null_interSb_reproMap = generateNullRepro (obj, numIter)

totalTrials = size (obj.result.trialTab, 1);
subNum = obj.setup.subNum;
null_interSb_reproMap = zeros (subNum*(subNum-1)/2, numIter);
%null_compRepro = zeros (100,1);
pos = zeros (totalTrials, 1);

fprintf ('------------------------------------\n');
fprintf ('   Generating null-distribution\n');
fprintf ('------------------------------------\n');


for i = 1:numIter
fprintf ('progress %d of %d\n', i, numIter);
for rl = 1:totalTrials
	rand_pos = randi(obj.result.trialTab(rl,3),1,1);
    pos(rl) = sum(obj.result.trialTab(1:rl-1, 3))+rand_pos;
end

null_reproMap = zeros (totalTrials);

for rl = 1:totalTrials
    cand_line = obj.result.MICM(pos(rl), :);%'+obj.result.MICM(:,pos(rl));
%     cand_line = getLines (obj, rl, pos(rl)-sum(obj.result.trialTab(1:rl-1, 3)));
	null_reproMap(rl,:) = cand_line(pos);
end

[similarity, subj_load, cons_inter_sb, cons_intra_sb] = sepIntra_Inter (obj,[], null_reproMap);
null_interSb_reproMap (:,i) = squareform(similarity, 'tovector');
%null_compRepro (i)= sum (null_repro(:))/2;
%null_reproLoad (:,i) = subj_load;
end
