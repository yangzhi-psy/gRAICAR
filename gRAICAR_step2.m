
function [status, exeption] = gRAICAR_step2(settings)
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

%%%%%%%%%% end of user settings %%%%%%%%%%%%%%%%%%%

inPrefix = fullfile(rootDir, outDir,taskName);
cueFile = fullfile(rootDir, outDir, 'progress.log');
% call distributed computing function
pth = which ('gRAICAR_step2');
gRAICAR_pth = fileparts(pth);

% initialize distComp log
fn = fullfile(rootDir, outDir, 'distComp.log');
prog = 0;
save (fn, 'prog', '-ascii');

% call distComp
for i = 2:ncores
    cmd = sprintf ('"%s" -nodisplay -r "addpath(genpath(''%s''));gRAICAR_distrCompNMI (''%s'',''%s'');exit" &', fullfile(matlabroot, 'bin', 'matlab.exe'), gRAICAR_pth, inPrefix, cueFile);
    fprintf ('\nStarting computing core %d\n', i);
    system (cmd);
    pause(1);
end

fprintf ('\nStarting computing core %d\n', 1);
fprintf ('\nWaiting for all computing cores to finish\n');

gRAICAR_distrCompNMI (inPrefix,cueFile);

% check progress of distributed computing
prog = 0;

while prog < ncores
    fn = fullfile(rootDir, outDir, 'distComp.log');
    prog = load (fn, '-ascii');
    pause(1);
end

fprintf ('\nAll computing cores have finished\n');

catch exeption
    status = 0;
    return
end
