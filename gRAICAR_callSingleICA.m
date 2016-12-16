function gRAICAR_callSingleICA(settings, sbList)

for i = 1:length (sbList)
    fprintf ('\n =======================\n  RAICAR on subject %d...\n =========================\n', i);
    sb = sbList{i}; % to be replaced with for loop

    subj.setup.inputNm   = fullfile (settings.workdir, sb, settings.fmriDir, settings.fmriPrefix);

    subj.setup.mskNm     = fullfile (settings.workdir, settings.maskPath);

    subj.setup.trials    = 1;                % number of ICA realizations

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
    subj.setup.ICAOption.lastEig  = 50;
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
    initCond = [];
    
    mkdir (fullfile (settings.workdir, sb, settings.icaDir));
    % 
    
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
    fprintf ('\n ================ ICA started ================\n');  
    subj.setup.rlPrefix = subj.setup.outPrefix;
    
    
    % prepare ICA command
    icaCmd = [];
    optionName = fields (subj.setup.ICAOption);
    optionValue = struct2cell (subj.setup.ICAOption);

    for i = 1:length (optionName)
        name = cell2mat (optionName(i));
        name = strcat ('''', name, '''');
        value = cell2mat (optionValue(i));
        if isnumeric (value)
            value = num2str (value);
        else
            value = strcat ('''', value, '''');
        end
        if i == 1
        icaCmd = sprintf (', %s, %s', name, value);
        else
            icaCmd = sprintf ('%s, %s, %s', icaCmd, name, value);
        end
    end
    % icaCmd = sprintf ('[icasig, A, W, flagConverge] = fastica_varianceThr (subj.result.forIca, %s, initCond, %s, %s%s);', '''initGuess''', '''verbose''', '''off''', icaCmd);
    icaCmd = sprintf ('[icasig, A, W, flagConverge] = fastica (subj.result.forIca, %s, initCond, %s, %s%s);', '''initGuess''', '''verbose''', '''off''', icaCmd);
    icaCmd,
    
    eval (icaCmd);
    subj.result.aveMap = raicar_2Dto4D (icasig, size(subj.result.mask), subj.result.coordTable);
    % save result
    fprintf ('\n saving results ...\t');
    nii = subj.result.info;
    nii.dim(5) = size (A, 2);
    nii.vol = subj.result.aveMap;

    save_nifti (nii, [subj.setup.outPrefix, '_aveMap', '.nii']);
    clear nii;
    fprintf ('seccess\n');
end

