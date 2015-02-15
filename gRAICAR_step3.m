
function [status, exeption] = gRAICAR_step3(settings)
status = 1;
exeption = [];

try

%%%%%%%%% load user settings %%%%%%%%%%%%%%%
% rootdir: the path of directory in which the entire analysis is runing
rootDir = settings.workdir;

% outdir: the name of directory for the output of gRAICAR (!!!!relative to the rootDir, instead of full path!!!!)
outDir = settings.outDir;

% taskName: name of the analysis task, will be used as the prefix of the configFile that stores information about the analysis.
taskName = settings.taskname;

% pathSbList: path to the subject list file (!!!!relative to the rootDir, instead of full path!!!!)
% the subject list file contains a list (column) of subject names. The data for each subject are under the directory with the listed subject name
pathSbList = settings.pathSbList;

% icaPrefix: name of the Melodic ICA file
icaPrefix = settings.icaPrefix;

% icaDir: path of the ICA directory (!!!!relative to the subject directory, instead of full path!!!!)
icaDir= settings.icaDir;

% maskPath: path of the mask file (!!!!relative to the rootDir, instead of full path!!!!)
maskPath = settings.maskPath;

% number of cores for computation
ncores = settings.ncores;

% extra settings
displayThreshold = settings.displayThreshold;
compPerPage = settings.compPerPage;

%%%%%%%%%% end of user settings %%%%%%%%%%%%%%%%%%%
keep_FSM = 0;

load ([rootDir, outDir, '/', taskName, '_configFile.mat'])

% check if all NMI computations are done
fprintf ('\n-------------------------\n');
fprintf (' checking NMI computaions\n');
fprintf ('-------------------------\n');
total = size (obj.result.cmptTab, 1);

failList=[];
for ptr=1:obj.setup.step:total
	fn = sprintf ('%s/computeFile/NMI_grp_result_%d.mat', obj.setup.outDir, ptr);
	if ~exist(fn,'file')
		failList = [failList, ptr];
	end
end
if ~isempty (failList)
	fprintf ('!!!!!!!!!!!!!!!!!!!!!!!!\n');
	fprintf ('error: NMI compuation is not completed\n')
	for i=1:length(failList)
		fprintf ('file NMI_grp_result_%d.mat not found\n', failList(i));
	end
	fprintf ('!!!!!!!!!!!!!!!!!!!!!!!!\n');
	error ('NMI compuation is not completed\n');
end

% align ICs
fprintf ('\n-------------------------\n');
fprintf (' aligning ICs \n');
fprintf ('-------------------------\n');

obj = gRAICAR_align_fullMICM (obj.setup.outPrefix, keep_FSM);
obj.result = rmfield (obj.result, 'MICM'); % remove the MICM to save disk space

% rank ACs according to meanRep
nAC = length (obj.result.foundRepro);
meanRep = zeros (nAC, 1);
for i = 1:nAC
    simMat = obj.result.foundRepro{i};
    simMat = simMat + simMat';
    simVec = squareform (simMat, 'tovector');
    meanRep(i) = mean (simVec);
end
[sort_meanRep, sort_idx] = sort (meanRep, 'descend');
obj.result.meanRepro  = sort_meanRep;
obj.result.foundComp  = obj.result.foundComp(sort_idx, :);
obj.result.foundRepro = obj.result.foundRepro(sort_idx);

fn = sprintf ('%s_result.mat', obj.setup.outPrefix);
save (fn, 'obj');

% examine subject loads
fprintf ('\n-------------------------\n');
fprintf (' examining subject loads \n');
fprintf ('-------------------------\n');

fn = sprintf ('%s_null_interSb_reproMap.mat', obj.setup.outPrefix);
if exist (fn, 'file')    % save some time if the null distribution is already simulated
    load (fn)
else
    obj=load_cmptFile(obj, 0);

    % normalize according to new alignment algorithm
    obj = normByRow (obj);
    obj.result.MICM = obj.result.MICM'+obj.result.MICM;
    min_MICM = min (obj.result.MICM(:));
    obj.result.MICM = obj.result.MICM - min_MICM;
    
    
    % start multiple computing core
    dlmwrite ([rootDir, outDir, '/distComp.log'], 0, 'precision', '%d');
    pth = which ('gRAICAR_step2');
    gRAICAR_pth = fileparts(pth);
    nIt = zeros (ncores, 1);
    fn_tmp = [rootDir, outDir, '/tmp_obj.mat'];
    save (fn_tmp, 'obj');
    for i = 2:ncores
        nIt(i) = round(1000/ncores);
        cmd = sprintf ('%s/bin/matlab -nodisplay -r "addpath(genpath(''%s''));generateNullRepro_worker (''%s'', %d, %d);exit" &', matlabroot, gRAICAR_pth, fn_tmp, nIt(i), i);
        fprintf ('\nStarting computing core %d\n', i);
        system (cmd);
        pause(1);
    end
    
    fprintf ('\nStarting computing core %d\n', 1);
    fprintf ('\nWaiting for all computing cores to finish\n');
    null_interSb_reproMap = generateNullRepro (obj, 1000-sum(nIt));
    
    % check status
    prog = 0;
    while prog < ncores
        fn = [rootDir, outDir, '/distComp.log'];
        prog = load (fn, '-ascii');
        pause (1);
    end
    fprintf ('\nAll computing cores have finished\n');
    delete (fn_tmp);
    
    % merge all parts
    for i = 2:ncores
        fn = sprintf ('%s_null_interSb_reproMap_%d.mat', obj.setup.outPrefix, i);
        tmp = load (fn);
        null_interSb_reproMap = [null_interSb_reproMap, tmp.null_interSb_reproMap];
        % clean up tmp files
        delete(fn);
    end
    fn = sprintf ('%s_null_interSb_reproMap.mat', obj.setup.outPrefix);
    save (fn, 'null_interSb_reproMap');
    
end

% really examine subject load
[obj.result.beta_rank_subjLoad, obj.result.sig_subjLoad, obj.result.subjLoad,obj.result.null_subjLoad] = examSigSubjLoad (obj, null_interSb_reproMap);

% cut off empty ACs
ACs_toRemain = find (sum(obj.result.sig_subjLoad <0.05, 1) < obj.setup.subNum);
obj.result.foundComp  = obj.result.foundComp(ACs_toRemain, :);
obj.result.foundRepro = obj.result.foundRepro(ACs_toRemain);
obj.result.meanRepro  = obj.result.meanRepro(ACs_toRemain);
obj.result.beta_rank_subjLoad = obj.result.beta_rank_subjLoad(ACs_toRemain);
obj.result.subjLoad   = obj.result.subjLoad(:, ACs_toRemain);
obj.result.sig_subjLoad   = obj.result.sig_subjLoad(:, ACs_toRemain);

% weighted averaging
fprintf ('\n-------------------------\n');
fprintf (' weighted averaging ICs \n');
fprintf ('-------------------------\n');
tic,
[map4D, allMap] = gRAICAR_weight_averageMap_fast (obj, 1:size (obj.result.foundComp));
fn = sprintf ('%s_aveMap.mat', obj.setup.outPrefix);
save (fn, 'map4D');

% write aligned components into nii file
fprintf ('\n-------------------------\n');
fprintf (' writing AC maps \n');
fprintf ('-------------------------\n');

hdr = obj.setup.niihdr;
sz = size (map4D);
cmd = sprintf ('!mkdir -p %s/compMaps/', obj.setup.outDir);
eval (cmd);
for i=1:sz(4)
	hdr.vol = map4D(:,:,:,i);
	hdr.dim = [3 sz(1) sz(2) sz(3) 1 1 1 1];
	hdr.glmax = max (map4D(:,:,:,i));
	hdr.glmin = max (map4D(:,:,:,i));
	fn = sprintf('%s/compMaps/comp%03d.nii.gz', obj.setup.outDir, i);
	save_nifti (hdr, fn);
	fprintf ('compMap%d written out\n', i);
end
toc,

% write component movie into nii file
% allMap = gRAICAR_synthesizeCompMap (obj, 1:size (obj.result.foundComp,1));
if settings.savemovie == 1
    tic,
    fprintf ('\n-------------------------\n');
    fprintf (' writing movies of AC maps (slow)\n');
    fprintf ('-------------------------\n');
    allMap = gRAICAR_movie_fast (obj, 1:size (obj.result.foundComp,1));
    sz=size(allMap);
    for i=1:sz(4)
        hdr.vol = squeeze(allMap(:,:,:,i,:));
        hdr.dim = [4 sz(1) sz(2) sz(3) sz(5) 1 1 1];
        hdr.glmax = max (squeeze(allMap(:,:,:,i,:)));
        hdr.glmin = min (squeeze(allMap(:,:,:,i,:)));
        fn = sprintf('%s/compMaps/movie_comp%03d.nii.gz', obj.setup.outDir, i);
        save_nifti (hdr, fn); 
        fprintf ('movie_compMap%d written out\n', i);
    end
    toc,
end

% save results
fn = sprintf ('%s_result.mat', obj.setup.outPrefix);
save (fn, 'obj');

% generate webreports
if settings.webreport == 1
    tic,
    fprintf ('\n-------------------------\n');
    fprintf (' Generating web reports \n');
    fprintf ('-------------------------\n');
    
    gRAICAR_generateReport (obj, displayThreshold, compPerPage);
    toc,
end

fprintf ('\n-------------------------\n');
fprintf (' gRAICAR done \n');
fprintf ('-------------------------\n');

catch exeption
    status = 0;
    return
end