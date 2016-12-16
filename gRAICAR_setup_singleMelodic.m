
function obj = gRAICAR_setup_singleMelodic (rootDir, sbList, outDir, taskName, icaDir, icaPrefix, maskPath, candidates)
% parse input
obj.setup.subNum = length (sbList);
obj.setup.trial  = 1*ones(obj.setup.subNum,1);
obj.setup.ICAprefix = icaPrefix;
for i = 1:obj.setup.subNum
    obj.setup.subDir(i) = {fullfile(rootDir, cell2mat(sbList(i)), icaDir)};
end
infoFn = []; %'../gRAICAR/mask_coordTable.mat';
obj.setup.maskNm = fullfile(rootDir,maskPath);

%%%%% set up candidate %%%%%
obj.setup.candidates = candidates;
%%%%%%%%%%%%%%%%%%%%%%%%%%%

obj.setup.outDir = fullfile(rootDir, outDir);
obj.setup.outPrefix = fullfile(obj.setup.outDir, taskName);
obj.setup.cmptPrefix = obj.setup.outDir;
obj.setup.step = 50;
mkdir (obj.setup.outDir);
mkdir (fullfile(obj.setup.outDir, 'computeFile'));

% trialTab: a table storing the mapping between trials and subjects
obj.result.trialTab = [];
for sb = 1:obj.setup.subNum
	for tr = 1:obj.setup.trial(sb)
		tmp = [tr, sb, 0];                  % trial, subject, and numIC
		obj.result.trialTab = [obj.result.trialTab; tmp];
	end
end
clear tmp sb tr;	

% cmptTab: a table storing the indices of pairs of trials to be computed
sz = size (obj.result.trialTab, 1);
obj.result.cmptTab = zeros (sz, 2);
count = 1;
for ptr = 1:size (obj.result.trialTab, 1)
	for ptr2 = ptr+1: size (obj.result.trialTab, 1)
		obj.result.cmptTab(count, :) = [ptr, ptr2]; 
		count = count+1;
	end
end
clear count sz ptr ptr2;

if ~isempty (infoFn)
	load (infoFn);
	obj.result.mask = subj.result.mask;
	obj.result.coordTable = subj.result.coordTable;
	clear subj;
else
	hdr = load_nifti (obj.setup.maskNm);
%     nii = load_untouch_nii (obj.setup.maskNm);
	obj.result.coordTable = makeCoordTable (hdr.vol); %nii.img
	obj.result.mask = hdr.vol; %nii.img
end

outFn = sprintf ('%s_configFile.mat', obj.setup.outPrefix);
save (outFn, 'obj');
