function [beta_rank_subjLoad, sig_subjLoad, subjLoad, null_subjLoad] = examSigSubjLoad (obj, null_interSb_reproMap)


sz = size (null_interSb_reproMap);

null_subjLoad = zeros (obj.setup.subNum, sz(2));
for i = 1:sz(2)
	tmp_map = squareform (null_interSb_reproMap(:,i), 'tomatrix');
	null_subjLoad(:,i) = max (tmp_map,[],1); %/(obj.setup.subNum-1);
end

null_subjLoad_thr = zeros (obj.setup.subNum,1);
rank_null_subjLoad = zeros (size(null_subjLoad));
for i = 1:obj.setup.subNum
	null_subjLoad_thr(i) = prctile (null_subjLoad(i,:),50);
	rank_null_subjLoad(i,:) = tiedrank (null_subjLoad(i,:));
end
	
numComp = length (obj.result.foundRepro);
subjLoad = zeros (obj.setup.subNum,numComp);
sig_subjLoad = subjLoad;

mean_rank_subjLoad = zeros (numComp,1);
beta_rank_subjLoad = mean_rank_subjLoad;

for i = 1:numComp
	fprintf ('computing component %d of %d\n', i, numComp);
    reproMap = cell2mat(obj.result.foundRepro(i));
    reproMap = full (reproMap+reproMap');
    
	similarity = sepIntra_Inter (obj, [], reproMap);	
    % subject load
    subjLoad(:,i) = sum (similarity, 1)/(obj.setup.subNum-1);
  
    
	[diffv, idx] = min (abs(null_subjLoad - repmat (subjLoad(:,i),[1,sz(2)])),[], 2);
    for sb = 1:obj.setup.subNum
        sig_subjLoad(sb,i) = rank_null_subjLoad(sb,idx(sb))./sz(2);
    end
    
    mean_rank_subjLoad(i) = sum (sig_subjLoad(:,i))/obj.setup.subNum;
    beta_rank_subjLoad(i) = length (find (subjLoad(:,i)-null_subjLoad_thr<0))/obj.setup.subNum;

end

% decision_interSb_con (beta_interSb_con<0.15) = 1;
    
