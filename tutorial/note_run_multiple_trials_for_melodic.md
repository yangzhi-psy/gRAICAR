# Run gRAICAR on multiple trials/tasks per subject from MELODIC
In order to run gRAICAR on multiple trials/tasks per subject from MELODIC, the main idea is to treat the output of MELODIC as a single trial/task as in RAICAR. gRAICAR can be setup to read the MELODIC output as a trial and run multi-trial (full, instead of single trial per subject) analysis.

The following steps are required:
1. orgnize the MELODIC output as the following file-tree:

```bash
├── 0scripts
│   └── subjs.list
├── group
│   └── mask
│       └── grpmask.nii.gz
├── subj1
│   └── rest
│       └── ICA
│           └── melodic1
│               └── melodic_IC_mni152_3mm.nii
│           └── melodic2
│               └── melodic_IC_mni152_3mm.nii
│           └── melodic3
│               └── melodic_IC_mni152_3mm.nii
├── subj2
│   └── rest
│       └── ICA
│           └── melodic1
│               └── melodic_IC_mni152_3mm.nii
│           └── melodic2
│               └── melodic_IC_mni152_3mm.nii
│           └── melodic3
│               └── melodic_IC_mni152_3mm.nii
├── subj3
│   └── rest
│       └── ICA
│           └── melodic1
│               └── melodic_IC_mni152_3mm.nii
│           └── melodic2
│               └── melodic_IC_mni152_3mm.nii
│           └── melodic3
│               └── melodic_IC_mni152_3mm.nii
| ......
```
2. fill in the settings structure:
```matlab
% rootdir: the path of directory in which the entire analysis is runing
settings.workdir = 'path_to_workdir';

% outdir: the name of directory for the output of gRAICAR (!!!!relative to the rootDir, instead of full path!!!!)
settings.outDir = 'out';

% taskName: name of the analysis task, will be used as the prefix of the configFile that stores information about the analysis.
settings.taskname = 'multitrial_melodic';

% pathSbList: path to the subject list file (!!!!relative to the rootDir, instead of full path!!!!)
% the subject list file contains a list (column) of subject names. The data for each subject are under the directory with the listed subject name
settings.pathSbList = 'subjs.list';

% icaPrefix: name of the Melodic ICA file
settings.icaPrefix = 'melodic_IC_mni152_3mm.nii'; % change this to match your ICA file name

% icaDir: path of the ICA directory (!!!!relative to the subject directory, instead of full path!!!!)
settings.icaDir = 'rest/ICA/melodic'; % relative to the subject directory, no trial number in the end

% maskPath: path of the mask file (!!!!relative to the rootDir, instead of full path!!!!)
settings.maskPath = 'group/mask/grpmask.nii.gz';

% trialsPerSubj: number of trials/tasks per subject
settings.trialsPerSubj = 3; % number of trials/tasks per subject, change this to match your data structure  
```

The above code assumes that the MELODIC output is organized as the above file-tree. The settings structure can be saved as a mat file.

3. call gRAICAR_step1_multi_trial_melodic.m with the settings structure:
```matlab
gRAICAR_step1_multi_trial_melodic(settings);
```
