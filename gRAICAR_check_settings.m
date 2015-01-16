function [pass, settings] = gRAICAR_check_settings (handles)
% function to check input settings and organize them into a structure
% 'setting', 'pass' is 1 if all input settings are valid.

pass = 1;
% check fields
neededFlds = {'ncores', 'workdir', 'outdir', 'subjlist', 'taskname', 'icapath', 'maskpath', 'savemovie', 'webreport'};
checkTab = zeros (length(neededFlds),1);
for i = 1:length(neededFlds)
    fdnm = cell2mat (neededFlds(i));
    checkTab(i) = ~isempty (handles.(fdnm));
end
idx_err = find(checkTab==0);
if ~isempty (idx_err')
    errmsg = sprintf ('The following fields are not configured: ');
    for i=idx_err
        errmsg = sprintf ('%s\n%s', errmsg, neededFlds{i});
    end
    pass = 0;
    errordlg (errmsg, 'Insufficient settings', 'modal');
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
settings.outDir = handles.outdir(length(handles.workdir)+1:end);
settings.pathSbList = handles.subjlist(length(handles.workdir)+1:end);
settings.maskPath = handles.maskpath(length(handles.workdir)+1:end);

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

% copy settings
try
    for nm = {'ncores', 'workdir', 'outdir', 'subjlist', 'taskname', 'icapath', 'maskpath', 'savemovie', 'webreport'}
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
