function cont = coreCompNMI (obj, ptr)

cont = 1;
step = obj.setup.step;
total = size (obj.result.cmptTab, 1);
if ptr <= total
	if ptr+step-1 <= total
		long = step;
	else 
		long = total-ptr+1;
	end

	% main computation loop
    mi_part = cell (long, 1);
    for i = 1:long
		% load trials to be computed
		tr_ptr = obj.result.cmptTab(ptr+i-1, :);
		split = [0;0];
        numVx = 0;
        lgthPar = 0;
		for j = 1:2
			tr = obj.result.trialTab(tr_ptr(j), 1);
            sb = obj.result.trialTab(tr_ptr(j), 2);
			fn = sprintf ('%s/bin_%s%d.mat', cell2mat (obj.setup.subDir(sb)), ...
							obj.setup.ICAprefix, tr);
			load (fn);
            split(j) = size (comp, 1);
            obj.result.trialTab(tr_ptr(j), 3) = split(j);
            if j == 1
                comp1 = comp';
                numVx = size (comp, 2);
                lgthPar = ceil (numVx^(1/3));
            else
                comp2 = comp';
            end
			clear comp;
		end
	
		% computation
		fprintf ('computing block %d of %d\n', ptr+i-1, total); 
		tic,
        mi_blk = zeros (split(1), split(2));
        for c1 = 1:split(1)
            xx = comp1(:, c1);
            for c2 = 1:split(2) 
                yy = comp2(:, c2);
                mi_blk(c1, c2) = calcNMI (xx, yy, numVx, lgthPar);
            end
        end
        mi_part(i) = {mi_blk};
        toc,
    end
	
    % save result
    fn = sprintf ('%s/computeFile/NMI_grp_result_%d', obj.setup.outDir, ptr);
    save (fn, 'mi_part');
		
else
	cont = 0;
end