function reproLoad = compWeight (obj, comps)

reproLoad = zeros (length(comps), size(obj.result.trialTab, 1));
for i = 1:length(comps)
cp = comps(i);
repro = full (cell2mat (obj.result.foundRepro(cp)));
sz = size (repro);
repro = repro+repro';

for sb = 1:obj.setup.subNum
	for tr = 1:obj.setup.trial(sb)
		pos = sum(obj.setup.trial(1:sb-1))+tr;
    	reproLoad(i,pos) = sum(repro(pos,:)) + sum(repro(:, pos));
	end
end
reproLoad(i,:) = reproLoad(i,:)./(2*sum(sum(repro)));
end

