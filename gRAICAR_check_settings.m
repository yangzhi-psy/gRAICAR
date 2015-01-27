function [pass, settings] = gRAICAR_check_settings (handles)
% function to check input settings and organize them into a structure
% 'setting', 'pass' is 1 if all input settings are valid.

pass = 1;
% check fields
if handles.useRAICAR == 0
    neededFlds = {'ncores', 'workdir', 'outdir', 'subjlist', 'taskname', 'icapath', 'maskpath', 'savemovie', 'webreport'};
else
    neededFlds = {'ncores', 'workdir', 'outdir', 'subjlist', 'taskname', 'fmripath', 'maskpath', 'savemovie', 'webreport'};
end

checkTab = zeros (length(neededFlds),1);
for i = 1:length(neededFlds)
    fdnm = cell2mat (neededFlds(i));
    checkTab(i) = ~isempty (handles.(fdnm));
end
idx_err = find(checkTab==0);
if ~isempty (idx_err')
    errmsg = sprintf ('The following fields are not configured: ');
    for i=idx_err'
        errmsg = sprintf ('%s \n %s', errmsg, neededFlds{i});
    end
    pass = 0;
    errordlg (errmsg, 'Insufficient settings', 'modal');
    error(errmsg);
    return
end

% load the subject list
try
    fid = fopen (handles.subjlist);
    tmp = textscan (fid,'%s');
    len = length (tmp{1});
    fclose(fid);

    sbList = cell(len,1);
    fid = fopen (handles.subjlist, 'r');
    for i=1:len
        sbList{i} = fgetl (fid);
    end
    fclose(fid);
catch
    errmsg = 'Failed to load the subject list.';
    pass = 0;
    errordlg (errmsg, 'Failed to load subject list file', 'modal');
    return
end

% determine icaPrefix and icaDir

if handles.useRAICAR == 0 % if not using RAICAR
    matched = zeros(len, 1);
    icapaths = cell(len, 1);
    for i = 1:len
        icapaths{i} = sprintf('%s/%s/',handles.workdir, sbList{i});
        if strfind(handles.icapath, icapaths{i})==1
            matched(i) = 1;
        end   
    end
    idx_match = find(matched == 1);
    len_icapath = length(icapaths{idx_match(1)});
    tosplit = handles.icapath(len_icapath:end);
    splited = strsplit(tosplit, '/');
    settings.icaPrefix = splited{end};
    settings.icaDir = strjoin(splited(1:end-1), '/');
    
    % check whether the ica file exist for each subject
    icaFound = zeros(len,1);
    for i=1:len
        fn = sprintf('%s/%s%s/%s', handles.workdir, sbList{i}, settings.icaDir, settings.icaPrefix);
        if exist(fn)== 2
            icaFound(i) = 1;
        end
    end
    idx_err = find(icaFound==0);
    if ~isempty (idx_err)
        errmsg = sprintf ('Failed to find the ICA result files for the following subjects: ');
        for i=[idx_err']
            errmsg = sprintf ('%s  \n  %s', errmsg, sbList{i});
        end
        pass = 0;
        errordlg (errmsg, 'Failed to load ICA file', 'modal');
        return
    end
    
    handles.fmripath =[];
else
    matched = zeros(len, 1);
    fmripaths = cell(len, 1);
    for i = 1:len
        fmripaths{i} = sprintf('%s/%s/',handles.workdir, sbList{i});
        if strfind(handles.fmripath, fmripaths{i})==1
            matched(i) = 1;
        end   
    end
    idx_match = find(matched == 1);
    len_fmripath = length(fmripaths{idx_match(1)});
    tosplit = handles.fmripath(len_fmripath:end);
    splited = strsplit(tosplit, '/');
    settings.fmriPrefix = splited{end};
    settings.fmriDir = strjoin(splited(1:end-1), '/');
    
    % define icaprefix using the RAICAR default
    settings.icaPrefix = 'RAICAR_ICA';
    settings.icaDir = '/rest/ICA/RAICAR';
    
    
    % check whether the fmri file exist for each subject
    fmriFound = zeros(len,1);
    for i=1:len
        fn = sprintf('%s/%s%s/%s', handles.workdir, sbList{i}, settings.fmriDir, settings.fmriPrefix);
        if exist(fn)== 2
            fmriFound(i) = 1;
        end
    end
    idx_err = find(fmriFound==0);
    if ~isempty (idx_err)
        errmsg = sprintf ('Failed to find the fMRI files for the following subjects: ');
        for i=[idx_err']
            errmsg = sprintf ('%s  \n  %s', errmsg, sbList{i});
        end
        pass = 0;
        errordlg (errmsg, 'Failed to load fMRI file', 'modal');
        return
    end
    handles.icapath = [];
end

settings.outDir = handles.outdir(length(handles.workdir)+1:end);
settings.pathSbList = handles.subjlist(length(handles.workdir)+1:end);
settings.maskPath = handles.maskpath(length(handles.workdir)+1:end);



% copy settings
try
    for nm = {'ncores', 'workdir', 'outdir', 'subjlist', 'taskname', 'icapath', 'fmripath', 'maskpath', 'savemovie', 'webreport'}
        fdnm = cell2mat (nm);
        settings.(fdnm) = handles.(fdnm);
    end
    
    % default settings
    settings.displayThreshold = 1.5;
    settings.compPerPage = 10;
catch
    pass = 0;
    errordlg ('Error in copying settings, please look for invalid paths', 'Error in settings', 'modal');
    return
end
