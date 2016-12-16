function candidates = gRAICAR_callRAICAR(settings, sbList)

% function to call RAICAR to perform ICA
candidates = cell(1, length (sbList));
for i = 1:length (sbList)
fprintf ('\n =======================\n  RAICAR on subject %d...\n =========================\n', i);
sb = sbList{i}; % to be replaced with for loop

subj.setup.inputNm   = fullfile (settings.workdir, sb, settings.fmriDir, settings.fmriPrefix);

subj.setup.mskNm     = fullfile (settings.workdir, settings.maskPath);

subj.setup.trials    = 3;                % number of ICA realizations

subj.setup.outPrefix = fullfile (settings.workdir, sb, settings.icaDir, settings.icaPrefix);
                        % prefix for the output files. the output 
				        % files include the multiple ICA result (.mat), 
                        % the CRCM matrix(.mat), the ranking and 
                        % averaging results (.mat)and the final 
                        % averaged component map (.nii);

% optional inputs
subj.setup.initOption= 'randinit';       % options on resampling methods. the choice 
					 % are 'randinit', 'bootstrap', and 'both'. 
					 % default = 'randinit';

subj.setup.rlPrefix  = [];%'/Users/yangz/Documents/myCode/gRAICAR/demo/subj1/rest/ICA/RAICAR/RAICAR_ICA'; %[];               % prefix of the ICA realizations. if the 
				         % ICA results exist, RAICAR can directly use them. 
					 % e.g. if demo_ICA1.mat to demo_ICA30.mat exsit, 
					 % the optional input rlPrefix should be 'demo_ICA', 
                                         % and then RAICAR will directly read them in, 
					 % instead of calculating ICA again. default = [];

subj.setup.CRCMNm    = [];%'/Users/yangz/Documents/myCode/gRAICAR/demo/subj1/rest/ICA/RAICAR/RAICAR_ICA_CRCM.mat';               % file name of the provided CRCM. if the 
                                         % CRCM is provided, RAICAR will directly read it and
                                         % use it to rank the components. default = [];

subj.setup.anatNm    = [];               % file name of the anatomy image. if
                                         % provided, the anatomy image will be used to
                                         % display the component maps. default = [];

subj.setup.paraNm    = [];               % file name of the paradigm file (.mat or
                                         % .1D). if provided, the experiment paradigm can be
					 % displayed with the component time courses.
					 % default = [];

subj.setup.start     = 1;                % the index of individual ICA result to 
                                         % start from. default = 1;

subj.setup.threshold = [];               % user-specified SCC threshold. default = [];

subj.setup.sparse    = 1;                % a flag indicating whether RAICAR will use 
					 % sparse method on CRCM. set to 1 to use sparse,0 to
					 % disable it. sparse matrix can save a lot of RAM, but 
					 % requires a pre-thresholding which will change the 
					 % reproducibility ranking a little bit. 
					 % default = 1;

subj.setup.ICAOption.approach = 'symm';
subj.setup.ICAOption.epsilon  = 0.0001;
subj.setup.ICAOption.maxNumIterations = 3000;
subj.setup.ICAOption.g        = 'tanh';
subj.setup.stabilization      = 'off' ;   
subj.setup.ICAOption.lastEig  = 75;
% structure storing user-specified options 
					 % for ICA. for details see the FastICA help.
                                         % default:
                                         %     ICAOption.approach = 'symm'
                                         %     ICAOption.epsilon  = 0.0001
                                         %     ICAOption.maxNumIterations = 3000
                                         %     ICAOption.g        = 'tanh'
                                         %     ICAOption.stabilization   = 'off'
                                         % NOTE: once ICAOption is set to nonempty, all the
                                         % default values will be overwritten. This means,
                                         % even though you only need to modify one of the ICA 

subj.setup.webReport = 0;                % a flag indicating whether RAICAR will           
                                         % automatically generate a web-page report. set to 
                                         % 1 to generate. default = 1;
subj.setup.compPerPage = settings.compPerPage;
subj.setup.displayThreshold = settings.displayThreshold;

% start RAICAR
mkdir (fullfile (settings.workdir, sb, settings.icaDir));
[subj] = raicar_controller (subj);

% save the results
fn = strcat (subj.setup.outPrefix, '_result.mat');
save (fn, 'subj');

% define candidate components according to reproducibility
select = find (subj.result.orderedRepro > settings.reproThr * subj.setup.trials*(subj.setup.trials-1)/2);
candidates(1,i) = {select};
end
 
