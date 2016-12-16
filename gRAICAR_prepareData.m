function obj = gRAICAR_prepareData (obj, sub)

if nargin < 2
	sub = 1:obj.setup.subNum;
end

% dwt on mask
szmsk = size (obj.result.mask);
%dsmpMsk = my_dwt3D (double(obj.result.mask));
%dsmpMsk (dsmpMsk < 0) = 0;
dsmpMsk = obj.result.mask;

% checking the prepared data
for sb = sub
    fprintf ('subject %d: checking data\n', sb);
	trTab = find (obj.result.trialTab(:, 2) == sb);
    trials = length (trTab);
        
    for tr = 1:trials;			
        fn = fullfile(cell2mat (obj.setup.subDir(sb)), sprintf ('bin_%s%d.mat', obj.setup.ICAprefix, tr));
        if exist (fn, 'file')  % if the ICA maps are already binned
            fprintf ('file %s exist, will not overwrite it\n', fn);
            try % try to load the binned file
               load (fn);
               obj.result.trialTab(trTab(tr), 3) = size (comp, 1);
            catch exception
                error ('!!!!!! failed to load file %s\n',  fn);
            end
            
            % save nii header info
            if trials == 1 % deal with format difference
                fn = fullfile (cell2mat (obj.setup.subDir(sb)), obj.setup.ICAprefix);
            elseif trials > 1
                fn = fullfile(sprintf ('%s%d', cell2mat (obj.setup.subDir(sb)), tr), obj.setup.ICAprefix);
            end
            if sb == 1 && tr == 1
                obj.setup.niihdr = load_nifti(fn, 'hdr_only');
            end
        else    % if the ICA maps are not binned
            fprintf ('transforming trial %d of subject %d\n', tr, sb);
            tic,
            ext = getExtension (obj.setup.ICAprefix);
            if strcmp (ext, '.mat') % if the ICA file is in .mat format
                if trials == 1
                    fn = sprintf ('%s%s.mat', cell2mat (obj.setup.subDir(sb)), obj.setup.ICAprefix);
                elseif trials > 1
                    fn = sprintf ('%s%s%d.mat', cell2mat (obj.setup.subDir(sb)), obj.setup.ICAprefix, tr);
                end
                try
                    load (fn);
                catch exception2
                    error ('failed to load file %s\n',  fn);
                end
            else
                if trials == 1
                    fn = fullfile(sprintf ('%s', cell2mat (obj.setup.subDir(sb))), obj.setup.ICAprefix);
                elseif trials > 1
                    fn = fullfile(sprintf ('%s%d', cell2mat (obj.setup.subDir(sb)), tr), obj.setup.ICAprefix);
                end
                hdr = load_nifti(fn);
                nii = hdr.vol;
                dim = hdr.dim([2:5]);
                hdr.vol = [];
				% save nii header info
				if sb == 1 && tr == 1
					obj.setup.niihdr = hdr;
				end
                icasig = reshape (nii, dim(1)*dim(2)*dim(3), dim(4));
                icasig (obj.result.mask==0, :) = [];
                icasig = icasig';               
            end
   
			%%%%%%%%% filter data %%%%%%%
            if ~isempty (obj.setup.candidates)
                select = obj.setup.candidates{tr, sb};
                comp = icasig(select, :);
			else
				comp = icasig;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            clear icasig A W nii hdr;

            % bin the data
            [numComp, numVx] = size (comp);
            ncellx=ceil(numVx^(1/3));
            for cp = 1:numComp
                comp(cp, :) = NMI_binData (comp(cp, :), numVx, ncellx);
            end
            fn = fullfile(cell2mat (obj.setup.subDir(sb)), sprintf ('bin_%s%d.mat',  ...
            obj.setup.ICAprefix, tr));
            save (fn, 'comp');
			obj.result.trialTab(trTab(tr), 3) = size (comp, 1);
			fprintf ('num of IC = %d\n',size (comp, 1));
            toc,
       end
    end
end
inFn = sprintf ('%s_configFile.mat',obj.setup.outPrefix);
save (inFn, 'obj');
fprintf ('subject %d: done\n', sb);
