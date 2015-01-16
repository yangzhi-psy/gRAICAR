function obj = load_cmptFile (obj, SNMI_switch)

inPrefix = obj.setup.cmptPrefix;
step = obj.setup.step;
% file index
starter = 1:step:size (obj.result.cmptTab, 1);

% assemble loop
obj.result.MICM = zeros (sum (obj.result.trialTab(:,3)),sum (obj.result.trialTab(:,3)));
%obj.result.NMI = obj.result.MICM;

count = 1;
fprintf ('\n');

for fl = starter
   fprintf ('\tloading file %d\n ', fl);
   fn = sprintf ('%s/computeFile/NMI_grp_result_%d.mat', inPrefix, fl);
   load (fn);
   
   % in the mi_part file,  normalize each block
   for bl = 1:min (step, length (mi_part));
       block = cell2mat (mi_part(bl))-1;
       
       % determine position
       trialPos = obj.result.cmptTab(count, :);
	   [row_start, row_end] = getRCRange (obj.result.trialTab, trialPos(1), trialPos(1));
	   [col_start, col_end] = getRCRange (obj.result.trialTab, trialPos(2), trialPos(2));
       
       % assign to NMI matrix
       %obj.result.NMI(row_start:row_end, col_start:col_end) = block;
       if SNMI_switch > 0
            % compute SNMI
            block = NMI_norm (block);
       end
       obj.result.MICM(row_start:row_end, col_start:col_end) = block;
	
       count = count+1;
    end    
end
clear bl block mi_part starter step fl flag_first;
fprintf ('\nloading finished\n\n'); 