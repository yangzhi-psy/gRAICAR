function [subj] = raicar_controller (subj)
%
% function [subj] = raicar_controller (subj)
% 
% Author: Zhi Yang
% Version: 2.0
% Last change: May 04, 2007
% 
% Purpose: 
%   Main gateway function. Ensure the correctness of the input and manage 
%   the processing steps. The whole process consists of four phases: 
%   preparing data, conducting multiple ICA, generating CRCM, and 
%   ranking/averaging components. This function can manage the phases 
%   according to the input arguments. 
%
% Input:   
%   subj: object of the subject containing the following fields:
%       setup: contains following sub-fields:
%           inputNm   : file name of the input data. the input file can be
%                       NIFTI or ANALYZE format;
%           mskNm     : file name of the data mask. can be NIFTI or ANALYZE
%                       format;
%           trials    : number of ICA realization; 
%           outPrefix : prefix for the output files. the output files 
%                       include the multiple ICA result (.mat), the CRCM 
%                       matrix(.mat), the ranking and averaging results 
%                       (.mat)and the final averaged component map (.nii);
%           initOption: (optional) options on resampling methods. the
%                       choice are 'randinit', 'bootstrap', and 'both'. 
%                       default = 'randinit';
%           rlPrefix  : (optional) prefix of the ICA realizations. if the
%                       ICA results exist, RAICAR can directly use them.
%                       e.g. if demo_ICA1.mat to demo_ICA30.mat 
%                       exsit, the optional input rlPrefix should be 
%                       'demo_ICA', and then RAICAR will directly read
%                       them in, instead of calculating ICA again.
%                       default = [];
%           CRCMNm    : (optional) file name of the provided CRCM. if the 
%                       CRCM is provided, RAICAR will directly read it and
%                       use it to rank the components. default = [];
%           anatNm    : (optional) file name of the anatomy image. if
%                       provided, the anatomy image will be used to
%                       display the component maps. default = [];
%           paraNm    : (optional) file name of the paradigm file (.mat or
%                       .1D). if provided, the experiment paradigm can be
%                       displayed with the component time courses.
%                       default = [];
%           start     : (optional) the index of individual ICA result to 
%                       start from. default = 1;
%           threshold : (optional) user-specified SCC threshold.
%                       default = [];
%           sparse    : (optional) flag indicating whether RAICAR will use 
%                       sparse method on CRCM. set to 1 to use sparse,0 to
%                       disable it. sparse matrix can save a lot of RAM, but 
%                       requires a pre-thresholding which will change the 
%                       reproducibility ranking a little bit. 
%                       default = 1;
%           ICAOption : (optional) structure storing user-specified options 
%                       for ICA. for details see the FastICA help.
%                       default:
%                           ICAOption.approach = 'symm'
%                           ICAOption.epsilon  = 0.0001
%                           ICAOption.maxNumIterations = 3000
%                           ICAOption.g        = 'tanh'
%                           ICAOption.stabilization   = 'off'
%                       NOTE: once ICAOption is set to nonempty, all the
%                       default values will be overwritten. This means,
%                       even though you only need to modify one of the ICA 
%                       options, you have to sepcify all options using 
%                       'ICAOption', otherwise RAICAR will use the default 
%                       settings of FastICA. 
%                       NOTE: it is the user's responsibility to make sure
%                       the options for ICA are correct, once it is
%                       changed from the default setting. RAICAR will not
%                       check it. 
%           webReport : (optional) flag indicating whether RAICAR will 
%                       automatically generate a web-page report. set to 
%                       1 to generate. default = 1;
%                       
%                           
% Output:
%   subj: object of the subject containing the following fields:
%       setup: same as input
%       result: contains following sub-fields:
%           info      : structure storing the information of the input file;
%           reproRank : ordered reproducibility indices of components;
%           foundComp : a table containing the realization-components of
%                       each aligned components;
%           aveMap    : averaged component maps (Z-normalized, 3D matrix, mosaic format);
%           aveTc     : averaged component time courses (Z-normalized, 2D);
%           mask      : matrix form of the data mask (3D matrix);
%           forIca    : reformed EPI image for ICA decomposition (2D matrix);
%           coordTable: the lookup table for the location of the voxels;
%           paradigm  : a vector containing stimulus paradigm, empty if not
%                       provided;
%           anat      : 2D matrix for the anatomy image (mosaic format), if not
%                       provided in the input, it will be the mean image of the 
%                       input data;
%           histogram : SCC histogram generated from CRCM;
%           threshold : SCC threshold determined by RAICAR or user input
%           TR        : effective TR of the EPI data (acquired from data
%                       header file);
%           CRCM      : cross-correlation correlation matrix generated or
%                       read in by program
%           numIC     : record number of components for each realization
%
%

% show progress
fprintf ('\n######################## RAICAR progress #########################\n');
clk = clock;
fprintf ('\n started at %4d-%02d-%02d %02d:%02d:%02.0f\n', ...
    clk(1), clk(2), clk(3), clk(4), clk(5), clk(6));
fprintf ('\n Initializing...\t');

% define object fields in subj.setup
mandatory = {'inputNm', 'mskNm', 'trials','outPrefix'};

% setup default values for all the optional input
defaults.initOption = 'randinit';
defaults.rlPrefix   = [];
defaults.CRCMNm     = [];
defaults.anatNm     = [];
defaults.paraNm     = [];
defaults.start      = 1;
defaults.threshold  = [];
defaults.sparse     = 1;
defaults.ICAOption.approach        = 'symm';
defaults.ICAOption.epsilon         = 0.0001;
defaults.ICAOption.maxNumIterations= 3000;
defaults.ICAOption.g               = 'tanh';
defaults.ICAOption.stabilization   = 'off';
defaults.webReport  = 1;

% check input
    % number of input
[errMsg] = nargchk (1, 1, nargin);
if ~isempty (errMsg)
    error ('raicar_controller takes and only takes one input argument: subject object');
end
    % general rules
[subj.setup, errMsg] = raicar_checkInput (subj.setup, mandatory, defaults);
if ~isempty (errMsg)
    error (errMsg);
end
    % sepcial constrains
[errMsg] = checkSpecialRule (subj.setup);
if ~isempty (errMsg)
    error (errMsg);
end

% initialize subj.result fields
subj.result.info         = [];
subj.result.orderedRepro = [];
subj.result.foundComp    = [];
subj.result.aveMap       = [];
subj.result.aveTc        = [];
subj.result.mask         = [];
subj.result.forIca       = [];  
subj.result.coordTable   = [];
subj.result.paradigm     = [];
subj.result.anat         = [];
subj.result.histogram    = [];
subj.result.threshold    = [];
subj.result.TR           = [];
subj.result.CRCM         = [];  %internal use, will be deleted after computation

% show progress
fprintf ('sucess\n');

% determine the phases
if ~isempty (subj.setup.CRCMNm)
    phase = 3;
elseif ~isempty (subj.setup.rlPrefix)
    phase = 2;
else
    phase = 1;
end

% read in the input file
    % check input data
try
    fprintf ('\n Reading in the input data file ...\t');
    nii = load_nifti (subj.setup.inputNm);
    orig = nii.vol;
    subj.result.TR = nii.pixdim(5);
    nii.vol = [];
    subj.result.info = nii;
    fprintf ('success\n');
catch
    error('raicar_controller failed to read in the input data file');
end
    % check mask
try
    fprintf ('\n Reading in the mask file ...\t');
    nii = load_nifti (subj.setup.mskNm);
    subj.result.mask = logical (nii.vol);
    clear nii;
    fprintf ('success\n');
catch
    error ('raicar_controller failed to read in the input mask file');
end

    %check individual ICA files
if ~isempty (subj.setup.rlPrefix)
    fprintf ('\n Checking the ICA realizations...\t');
    for i = subj.setup.start:subj.setup.trials+subj.setup.start-1
        s = strcat (subj.setup.rlPrefix, num2str(i), '.mat');
        fid = fopen (s, 'r');
        if fid == -1
            error ('raicar_controller failed to read all the ICA realizations');
        end
        fclose (fid);
    end
    try
        tmp = load (strcat (subj.setup.rlPrefix, num2str(subj.setup.start), '.mat'));
        clear tmp;
        fprintf ('success\n');
    catch
        error ('raicar_controller failed to read all the ICA realizations');
    end
end
    % check the CRCM file
if ~isempty (subj.setup.CRCMNm)
    fprintf ('\n Checking the provided CRCM... \t');
    try  
        tmp = load (subj.setup.CRCMNm);
        subj.result.CRCM = tmp.CRCM;
        subj.result.histogram = tmp.logfreqdist;
        subj.result.threshold = tmp.thr;
        subj.result.numIC = tmp.numIC;
        clear tmp;
        fprintf ('success\n');
    catch
        error ('raicar_controller failed to read the provided CRCM file');
    end
end
    % check the anatomy data
if ~isempty (subj.setup.anatNm)
    fprintf ('\n Checking the anatomy file...\t');
    try
        nii = load_nii (subj.setup.anatNm); % don't save to RAM until the display phase
        if isempty (nii.img)
            error ('raicar_controller found the anatomy file is empty');
        else
            clear nii
        end
        fprintf ('success\n');
    catch
        error ('raicar_controller failed to read in the anatomy file');
    end
end 
    % check the paradigm file
if ~isempty (subj.setup.paraNm)
    fprintf ('\n Reading in the paradigm file ...\t');
    try
	tmp = load (subj.setup.paraNm);
	if isstruct (tmp)
	    tmp = struct2cell (tmp);
	    tmp = cell2mat (tmp);
	end
	subj.result.paradigm = tmp;
	clear tmp
    catch
        error ('raicar_controller failed to read in the paradigm file');
    end
end

% prepare the data
fprintf ('\n Reforming the input data ...\t');

if length (size (orig)) == 3 % in case that the input data is from a surface dataset, so that the load_nii function squeeze orig matrix into 3-D
	[subj.result.forIca, subj.result.coordTable] = raicar_3Dto2D (orig, subj.result.mask);
else
	[subj.result.forIca, subj.result.coordTable] = raicar_4Dto2D (orig, subj.result.mask);
end
clear orig mask;
fprintf ('success\n');

% assign the processing tasks
if phase == 1
    % conduct multiple ICA
    fprintf ('\n ================ Phase 1 started ================\n');  
    subj.setup.rlPrefix = subj.setup.outPrefix;
    raicar_multiICA (subj);
    phase = phase + 1;
end

if phase == 2  
    % compute CRCM and determine threshold
    fprintf ('\n ================ Phase 2 started ================\n');   
    subj.setup.CRCMNm = strcat (subj.setup.outPrefix, '_CRCM.mat');
    [subj] = raicar_crcm (subj);
    
    phase = phase + 1;
end

if phase == 3
    % rank by reproducibility
    fprintf ('\n ================ Phase 3 started ================\n');
    [subj] = raicar_rank (subj);
    % average
    [subj] = raicar_averageComp (subj);
end

% save result
fprintf ('\n saving results ...\t');
nii = subj.result.info;
nii.dim(5) = size (subj.result.aveTc, 2);
nii.vol = subj.result.aveMap;

save_nifti (nii, [subj.setup.outPrefix, '_aveMap', '.nii']);
clear nii;
fprintf ('seccess\n');


% generate web page report
if subj.setup.webReport ~= 0 
    raicar_generateWebReport (subj, subj.setup.displayThreshold);
end

fprintf ('\n##### RAICAR process is finished, and ready to show the results #####\n');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub-functions *****************************

function [errMsg] = checkSpecialRule (subj)
%
% function [errMsg] = checkSpecialRule (subj)
%
% Purpose: 
%   Check the input arguments according to the program-specilized
%   constaints
% Input:
%   subj: subject object containing the input information;
% Output:
%   errMsg: a string describing the latest error. empty if no error occurs
%

errMsg = [];

% check input: trials
if mod (subj.trials, 1) ~= 0
    errMsg = 'the input "trials" should be an integer, now it is not a integer';
    return;
end

if subj.trials < 3
    errMsg = 'the input "trials" should be at least 3, now it is less than 3';
    return;
end

% check input: outPrefix
if ~ischar (subj.outPrefix)
    errMsg = 'the input "outPrefix" should be a char string, now this requirement is not satisfied';
    return;
end

% check optional input: 
if ~strcmp (subj.initOption, 'randinit') && ...
        ~strcmp (subj.initOption, 'bootstrap') && ...
        ~strcmp (subj.initOption, 'both')
    errMsg = sprintf ('the optional input "initOption = %s" is not recognized', subj.initOption);
end

if mod (subj.start, 1) ~= 0 || subj.start < 1
    errMsg = ('the optional input "start" is either not a integer or less than 1');
end

if subj.threshold < 0; %< 0.35
    errMsg = sprintf ('the optional input "threshold = %d" does not seem reasonable', subj.threshold);
end

if subj.sparse ~= 0 && subj.sparse ~= 1
    errMsg = sprintf ('the optional input "sparse = %d" is not correct. it should be 0 or 1', subj.sparse);
end

if subj.webReport ~= 0 && subj.webReport ~= 1
    errMsg = sprintf ('the optional input "webReport = %d" is not correct. it should be 0 or 1', subj.webReport);
end

