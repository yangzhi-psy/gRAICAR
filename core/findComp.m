
function obj = findComp (obj)
%%% function for aligning components

% initialize
flagEnough = 0;
count = 1;
rangeTable = cumsum (obj.result.trialTab(:, 3));
rangeTable = [0; rangeTable];

while flagEnough == 0 %&& count < max (obj.result.trialTab(:,3))

%%%%%%%%%%%%%%% mainloop %%%%%%%%%%%%%%%%%%%%%%%%%

% total = sum (obj.result.trialTab(:, 3));
totalTrials = size (obj.result.trialTab, 1);
foundComp = zeros (totalTrials, 1);	


% zero out all the within subject entries
for sub = 1:obj.setup.subNum   
    tmp = find (obj.result.trialTab(:, 2) == sub);
    [row_start, row_end] = getRCRange (obj.result.trialTab, tmp(1), tmp(end));
    obj.result.MICM(row_start:row_end, row_start:row_end) = 0.0001*obj.result.MICM(row_start:row_end, row_start:row_end);
end
clear tmp sub;
%tab = [];

% search for the largest correlation coefficient 
[mval, mpos] = max (obj.result.MICM(:));
[mpos_x, mpos_y] = ind2sub (size (obj.result.MICM), mpos);   

if full (mval) <= obj.result.thr
		flagEnough = 1;
		return;
end

% restore intra values
for sub = 1:obj.setup.subNum   
    tmp = find (obj.result.trialTab(:, 2) == sub);
    [row_start, row_end] = getRCRange (obj.result.trialTab, tmp(1), tmp(end));
    obj.result.MICM(row_start:row_end, row_start:row_end) = 10000*obj.result.MICM(row_start:row_end, row_start:row_end);
end

% extract the corresponding row and column
row = obj.result.MICM(mpos_x, :)'+obj.result.MICM(:,mpos_x);
col = obj.result.MICM(:, mpos_y)+obj.result.MICM(mpos_y, :)';

% row_mval = zeros(totalTrials, 1);
% col_mval = row_mval;
% row_mpos = row_mval;
% col_mpos = row_mval;
container = zeros (totalTrials, 2);    

% search in row and column
for rl = 1:totalTrials
	range(1) = sum(obj.result.trialTab(1:rl-1, 3))+1;
	range(2) = sum(obj.result.trialTab(1:rl, 3));
    
    [row_mval, row_mpos] = max (row(range(1):range(2)));
    [col_mval, col_mpos] = max (col(range(1):range(2)));
    
    if row_mval <= obj.result.thr && col_mval <= obj.result.thr
		foundComp(rl) = 0;
    elseif row_mval <= obj.result.thr && col_mval > obj.result.thr
		foundComp(rl) = col_mpos;
    elseif row_mval > obj.result.thr && col_mval <= obj.result.thr
		foundComp(rl) = row_mpos;  
    else
        if col_mpos ~= row_mpos
            container(rl, :) = [row_mpos, col_mpos];
        else
            foundComp(rl) = row_mpos;
        end
    end
end
clear row col row_mpos row_mval col_mpos col_mval range sub

% vote to decide which to take
[core(:, 1), junk, core(:, 2)] = find (foundComp);
lgth = size (core, 1);

for rl = 1:totalTrials
    if container(rl, 1) ~= 0
		vote = 0;
		for i = 1:lgth 
            if getPoints_fullMICM (obj, core(i, 1), rl, core(i, 2), container(rl, 1)) ...
                    > getPoints_fullMICM (obj, core(i, 1), rl, core(i, 2), container(rl, 2))
				vote = vote + 1;
			else
				vote = vote - 1;
            end
		end
		if vote > 0
			foundComp(rl) = container(rl, 1);
		elseif vote < 0
			foundComp(rl) = container(rl, 2);
		else
			if container(rl) > container(rl, 2)
				foundComp(rl) = container(rl, 1);
			else
				foundComp(rl) = container(rl, 2);
			end
        end
    end
end
clear container core 

% detect odd global maximum
diff_x = mpos_x-rangeTable;
tmp_pos_idx_x = find(diff_x>0);
tmp_rl_x = tmp_pos_idx_x(end);

diff_y = mpos_y-rangeTable;
tmp_pos_idx_y = find(diff_y>0);
tmp_rl_y = tmp_pos_idx_y(end);

if foundComp(tmp_rl_x) ~= diff_x(tmp_rl_x) || foundComp(tmp_rl_y) ~= diff_y(tmp_rl_y)   % the global maximum cannot be find in foundComp
    obj.result.MICM (mpos_x, mpos_y) = -abs(obj.result.MICM (mpos_x, mpos_y));
    fprintf ('...');
else
    % mask out the used entry
    for rl = 1:totalTrials
        if foundComp(rl) ~= 0;
            pos = rangeTable(rl)+foundComp(rl);
            % instead of setting picked RCs to 0 in the FSM, perserve them in negative values
            obj.result.MICM (pos, :) = -abs(obj.result.MICM (pos, :));
            obj.result.MICM (:, pos) = -abs(obj.result.MICM (:, pos));
        end
    end

    if flagEnough == 0
        obj.result.foundComp(count,:) = foundComp;
        count = count+1;
    end
    
    % show progress
    fprintf (strcat ('...', num2str (count-1)));
    if mod (count-1, 15) == 0
        fprintf ('\n');
    end
end
%%%%%%%%%%%%% end of mainloop %%%%%%%%%%%%%%%
end
fprintf ('\n');