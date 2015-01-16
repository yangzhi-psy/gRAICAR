function obj = gRAICAR_align_fullMICM (inPrefix, keep_FSM)

%%%%%%%%%%%%%%%%%%
fn = sprintf ('%s_configFile.mat', inPrefix);
load (fn)

% load cmptFiles
SNMI_switch = 0;
obj = load_cmptFile (obj, SNMI_switch);

% % threshold SNMI
% min_SNMI = min (obj.result.MICM(:));
% obj.result.MICM = obj.result.MICM-min_SNMI; % set minimum of FSM to 0
% obj.result.thr = -min_SNMI;

% align components
count = 1;
flagEnough = 0;

% if keep_FSM==1
% 	obj = findComp_keepFSM (obj);
% else
	obj = findComp_PR (obj, keep_FSM);
% end

% % % load cmptFile
% SNMI_switch = 0;
% obj = load_cmptFile (obj, SNMI_switch);
% % obj.result.thr = 0;
% obj = findRepro (obj);
% 
% % % get SNMI repromatrix
% SNMI_switch = 1;
% obj.result.foundRepro_NMI = obj.result.foundRepro;
% obj = load_cmptFile (obj, SNMI_switch);
% obj = findRepro (obj);

