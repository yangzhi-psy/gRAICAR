function [map4D, allMap] = gRAICAR_weight_averageMap_fast (obj, comps)

% purpose: weighted average ICs according to the alignment, in a faster way
% input:
%       obj: containing foundComp and foundRepro
%       comps: a vector listing the aligned component to be generated
% output:     
%       map4D: 4D images matrix containing the alignmed component map
%       allMap: 5D image matrix containing all individual component maps

aveMap = [];
aveTc  = [];
flagInit = 1;
flagFirst = ones(length(comps),1);
reproLoad = compWeight (obj, comps);


for sb = 1:obj.setup.subNum
	for tr = 1:obj.setup.trial(sb)
		% to be replaced by more capable loading function
		fn = sprintf ('%s/%s', cell2mat (obj.setup.subDir(sb)), obj.setup.ICAprefix);
        hdr = load_nifti(fn);
        dim = hdr.dim([2:5]);
        
        % select components
        if ~isempty (obj.setup.candidates)
            select = obj.setup.candidates{tr, sb};
            nii = hdr.vol(:,:,:,select);
            dim(4) = length(select);
        else
            nii = hdr.vol;
        end
        %%%
        
		icasig = reshape (nii, dim(1)*dim(2)*dim(3), dim(4));
		icasig (obj.result.mask==0, :) = [];
		icasig = icasig';
		fprintf ('loaded subject %d, trial %d\n',sb, tr);

		for id = 1:length (comps)
		cp = comps(id);
		pos = sum(obj.setup.trial(1:sb-1))+tr;
		if obj.result.foundComp(cp,pos) ~= 0
			map = icasig(obj.result.foundComp(cp, pos), :);
			%	tc = A(:,obj.result.foundComp(cp, pos));
			map = (map-mean(map))./std(map);
            map4D = singleMap_2Dto4D (map, size(obj.result.mask), obj.result.coordTable);
			%	tc = (tc-mean(tc))./std(tc);
         
				if flagFirst(id) == 1
                    if flagInit == 1
                        aveMap = zeros (length (comps), length (map));
                        szmsk = size (obj.result.mask);
                        allMap = zeros (szmsk(1),szmsk(2),szmsk(3),length (comps),size(obj.result.trialTab,1));
                        flagInit = 0;
                    end
			%		aveTc = zeros (length (tc), length (comps));
					aveMap(id, :) = reproLoad(id, pos)*map;
                    allMap(:,:,:,id, pos) = reproLoad(id, pos)*map4D;
			%		aveTc(:, id) = tc;
					flagFirst(id) = 0;
				else
					tmp = corrcoef (aveMap(id, :)',map');
					aveMap(id, :) = aveMap(id, :)+sign (tmp(1,2))*reproLoad(id, pos)*map;
			%		aveTc(:,id) = aveTc(:,id)+sign (tmp(1,2))*tc;
                    allMap(:,:,:,id, pos) = sign (tmp(1,2))*reproLoad(id, pos)*map4D;
				end
		end
		end % comp
	end % trial
end % subject

% for id = 1:length (comps)
%     aveMap(id, :) = (aveMap(id,:) - mean(aveMap(id, :)))/std(aveMap(id, :));
% end
map4D = raicar_2Dto4D (aveMap, size(obj.result.mask), obj.result.coordTable);