function obj = findComp_PR (obj, keep_FSM)
%%% function for aligning components

totalTrials = size (obj.result.trialTab, 1);
rangeTable2 = cumsum (obj.result.trialTab(:, 3));
rangeTable1 = [0; rangeTable2];
rangeTable1(end) = [];

% compute pagerank for each IC
[obj, m] = normByRow (obj);
% [PR,PR_idx] = calcPagerank (obj, m);
% load tmp_PR.mat

m = m'.*m;
m = sum(m,2);
[PR,PR_idx] = sort(m, 'descend');
% [PR,PR_idx] = calcPagerank (obj, m);
obj.result.MICM = obj.result.MICM'+obj.result.MICM;
min_MICM = min (obj.result.MICM(:));
obj.result.MICM = obj.result.MICM - min_MICM;

obj.result.thr = 0;

% search loop 
flagEnough = 0;
count = 1;
while flagEnough == 0
    foundComp = zeros (totalTrials, 1);
    foundMval = foundComp;
    coreIdx = PR_idx(1);
    [coreRl, coreCp] = global2local (coreIdx, rangeTable1);
    
    % extract the corresponding line in MICM
    line = obj.result.MICM(coreIdx, :); %+obj.result.MICM(:,coreIdx);
    
    % search each trial block for local maxima
    for rl = 1:totalTrials
        [foundMval(rl), foundComp(rl)] = max (line(rangeTable1(rl)+1:rangeTable2(rl)));
    end
    % fill the core itself in
    foundMval(coreRl) = 99;
    foundComp(coreRl) = coreCp;
    
    % mask out the used entry
    for rl = 1:totalTrials
        if foundMval(rl) <= obj.result.thr;
            foundComp(rl) = 0;
        else
            pos = rangeTable1(rl)+foundComp(rl);
            if keep_FSM == 0
                % instead of setting picked RCs to 0 in the FSM, perserve them in negative values
                obj.result.MICM (pos, :) = -abs(obj.result.MICM (pos, :));
                obj.result.MICM (:, pos) = -abs(obj.result.MICM (:, pos));
            end
            % mask out the pagerank
            PR(PR_idx==pos) = [];
            PR_idx(PR_idx==pos) = [];      
        end
    end
    
    % check status
    
    obj.result.foundComp(count,:) = foundComp;
	foundIdx = find (foundComp > 0);
    foundComp_valid = foundComp(foundIdx);
    rangeTable_valid = rangeTable1(foundComp>0);
    pos_valid = rangeTable_valid + foundComp_valid;
    
	foundRepro = zeros (totalTrials);
	for r = 1:length(foundIdx)
		for c = r+1:length(foundIdx)
			foundRepro(foundIdx(r), foundIdx(c)) = abs(obj.result.MICM(pos_valid(r), pos_valid(c)));
		end
	end
    obj.result.foundRepro(count) = {foundRepro};
    fprintf (strcat ('...', num2str (count)));
    if mod (count, 15) == 0
        fprintf ('\n');
    end
    
    if isempty(PR_idx)
        flagEnough = 1;
    end
    count = count+1;
%%%%%%%%%%%%% end of mainloop %%%%%%%%%%%%%%
end
fprintf ('\n');
       
    
    
    
    
