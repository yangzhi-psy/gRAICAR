function obj = findRepro (obj)

sz = size (obj.result.foundComp);
obj.result.foundRepro = cell(sz(1),1);
for cp = 1:sz(1)
    foundComp = squeeze(obj.result.foundComp(cp, :));
%%%%%%%%%% main loop %%%%%%%%%%%%
totalTrials = size (obj.result.trialTab, 1);
foundRepro = zeros (totalTrials, totalTrials);
% find Reproducibility
for rl = 1:totalTrials
    if foundComp(rl) ~= 0
		pos = sum(obj.result.trialTab(1:rl-1, 3))+foundComp(rl);
		cand_line = obj.result.MICM(pos, :)'+obj.result.MICM(:,pos);
        for rl2 = rl+1:totalTrials
            if foundComp(rl2) ~= 0
				pos = sum(obj.result.trialTab(1:rl2-1, 3))+foundComp(rl2);
                if cand_line(pos) > obj.result.thr
                    foundRepro(rl, rl2) = cand_line(pos);
                end
            end
        end
    end
end

% % mask out the used entry
% for rl = 1:totalTrials
% 	if foundComp(rl) ~= 0;
% 		pos = sum(obj.result.trialTab(1:rl-1, 3))+foundComp(rl);
%         obj.result.MICM (pos, :) = 0;
%         obj.result.MICM (:, pos) = 0;
% 	end
% end


%%%%%%%%%% end of main loop %%%%%%%%%%%%
    obj.result.foundRepro(cp) = {foundRepro};
    fprintf (strcat ('...', num2str (cp)));
    if mod (cp, 15) == 0
        fprintf ('\n');
    end
end
fprintf ('\n');