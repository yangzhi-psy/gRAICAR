function [aveMap aveTc] = gRAICAR_weight_averageMap (obj, comps)

aveMap = [];
aveTc = [];
flagInit = 1;
reproLoad = compWeight (obj, comps);
for id = 1:length (comps)
	cp = comps(id);
    map = [];
	flagFirst = 1;
	count = 1;
	for sb = 1:obj.setup.subNum
		for tr = 1:obj.setup.trial(sb)
			pos = sum(obj.setup.trial(1:sb-1))+tr;
			if obj.result.foundComp(cp, pos) ~= 0
	            ext = getExtension (obj.setup.ICAprefix);
            	if strcmp (ext, '.gz')
                    if obj.setup.trial(sb) == 1
                        fn = sprintf ('%s/%s', cell2mat (obj.setup.subDir(sb)), obj.setup.ICAprefix);
                    else
                        fn = sprintf ('%s%d/%s', cell2mat (obj.setup.subDir(sb)), tr, obj.setup.ICAprefix);
                    end
                	[nii, dim] = read_avw(fn);
					icasig = reshape (nii, dim(1)*dim(2)*dim(3), dim(4));
                	icasig (obj.result.mask==0, :) = [];
					icasig = icasig';
				elseif isempty (ext)
                    if obj.setup.trial(sb) == 1
                        fn = sprintf ('%s%s.mat', cell2mat (obj.setup.subDir(sb)), obj.setup.ICAprefix);
                    else
                        fn = sprintf ('%s%s%d.mat', cell2mat (obj.setup.subDir(sb)), obj.setup.ICAprefix, tr);
                    end
					load (fn);
				end
				fprintf ('component: %d: loaded subject %d, trial %d\n', cp, sb, tr);
             	map = icasig(obj.result.foundComp(cp, pos), :);
			%	tc = A(:,obj.result.foundComp(cp, pos));
				map = (map-mean(map))./std(map);
			%	tc = (tc-mean(tc))./std(tc);
				if flagFirst == 1
                    if flagInit == 1
                        aveMap = zeros (length (comps), length (map));
                        flagInit = 0;
                    end
			%		aveTc = zeros (length (tc), length (comps));
					aveMap(id, :) = reproLoad(id, pos)*map;
			%		aveTc(:, id) = tc;
					flagFirst = 0;
				else
					tmp = corrcoef (aveMap(id, :)',map');
					aveMap(id, :) = aveMap(id, :)+sign (tmp(1,2))*reproLoad(id, pos)*map;
			%		aveTc(:,id) = aveTc(:,id)+sign (tmp(1,2))*tc;
				end
				count = count + 1;
			end
		end
	end
%	aveMap(id, :) = aveMap(id, :)/count;
%	aveTc(:, id) = aveTc(:, id)/count;
% 	aveMap(id, :) = zscore(aveMap(id, :), 0, 2);
end



