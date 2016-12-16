function varargout = gRAICAR_GUI(varargin)
% GRAICAR_GUI MATLAB code for gRAICAR_GUI.fig
%      GRAICAR_GUI, by itself, creates a new GRAICAR_GUI or raises the existing
%      singleton*.
%
%      H = GRAICAR_GUI returns the handle to a new GRAICAR_GUI or the handle to
%      the existing singleton*.
%
%      GRAICAR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRAICAR_GUI. M with the given input arguments.
%
%      GRAICAR_GUI('Property','Value',...) creates a new GRAICAR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gRAICAR_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gRAICAR_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gRAICAR_GUI

% Last Modified by GUIDE v2.5 14-Feb-2015 23:16:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gRAICAR_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @gRAICAR_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gRAICAR_GUI is made visible.
function gRAICAR_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gRAICAR_GUI (see VARARGIN)

% Choose default command line output for gRAICAR_GUI
handles.output = hObject;

% set up default values
handles.workdir  = [];
handles.outdir   = [];
handles.subjlist = [];
handles.taskname = 'analysis1';
handles.icapath  = [];
handles.maskpath = [];
handles.fmripath = [];
if ispc
    handles.ncores  = str2double(getenv('NUMBER_OF_PROCESSORS'));
    handles.maxcores = str2double(getenv('NUMBER_OF_PROCESSORS'));
else
    handles.ncores  = feature('numcores');
    handles.maxcores = feature('numcores');
end
handles.savemovie = 1;
handles.webreport = 1;
handles.useRAICAR = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gRAICAR_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gRAICAR_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_workdir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_workdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_workdir as text
%        str2double(get(hObject,'String')) returns contents of edit_workdir as a double
handles.workdir = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_workdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_workdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'Enable', 'inactive');


% --- Executes on button press in btn_workDir.
function btn_workDir_Callback(hObject, eventdata, handles)
% hObject    handle to btn_workDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.workdir = uigetdir('', 'Select the root directory for the analysis:');
if handles.workdir == 0
    handles.workdir = '';
end
set(handles.edit_workdir, 'Enable', 'on');
set(handles.edit_workdir, 'ForegroundColor', [0 0 0]);
set(handles.edit_workdir, 'ButtonDownFcn', []); % disable the buttondown event in the corresponding edit box
set(handles.edit_workdir, 'String', handles.workdir);
guidata(hObject, handles);

function edit_outputDir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_outputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_outputDir as text
%        str2double(get(hObject,'String')) returns contents of edit_outputDir as a double
handles.outdir = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_outputDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_outputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'Enable', 'inactive');


function edit_subjList_Callback(hObject, eventdata, handles)
% hObject    handle to edit_subjList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_subjList as text
%        str2double(get(hObject,'String')) returns contents of edit_subjList as a double
handles.subjlist = get(hObject, 'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_subjList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_subjList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'Enable', 'inactive');

% --- Executes on button press in btn_outputDir.
function btn_outputDir_Callback(hObject, eventdata, handles)
% hObject    handle to btn_outputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.outdir = uigetdir('', 'Select a directory for output:');
if handles.outdir == 0
    handles.outdir = '';
end
set(handles.edit_outputDir, 'Enable', 'on');
set(handles.edit_outputDir, 'ForegroundColor', [0 0 0]);
set(handles.edit_outputDir, 'ButtonDownFcn', []); % disable the buttondown event in the corresponding edit box
set(handles.edit_outputDir, 'String', handles.outdir);
guidata(hObject, handles);

% --- Executes on button press in btn_subjsList.
function btn_subjsList_Callback(hObject, eventdata, handles)
% hObject    handle to btn_subjsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn, fpth] = uigetfile('.list', 'Select a subject list:');
if fn == 0
    handles.subjlist = '';
else
    handles.subjlist = fullfile (fpth, fn);
end
set(handles.edit_subjList, 'Enable', 'on');
set(handles.edit_subjList, 'ForegroundColor', [0 0 0]);
set(handles.edit_subjList, 'ButtonDownFcn', []); % disable the buttondown event in the corresponding edit box
set(handles.edit_subjList, 'String', handles.subjlist);
guidata(hObject, handles);

% --- Executes on button press in btn_maskPath.
function btn_maskPath_Callback(hObject, eventdata, handles)
% hObject    handle to btn_maskPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn, fpth] = uigetfile('*.*', 'Select a group mask file .nii or .nii.gz:');
if fn == 0
    handles.maskpath = '';
else
    handles.maskpath = fullfile (fpth, fn);
end
set(handles.edit_maskPath, 'Enable', 'on');
set(handles.edit_maskPath, 'ForegroundColor', [0 0 0]);
set(handles.edit_maskPath, 'ButtonDownFcn', []); % disable the buttondown event in the corresponding edit box
set(handles.edit_maskPath, 'String', handles.maskpath);
guidata(hObject, handles);


function edit_maskPath_Callback(hObject, eventdata, handles)
% hObject    handle to edit_maskPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_maskPath as text
%        str2double(get(hObject,'String')) returns contents of edit_maskPath as a double
handles.maskpath = get(hObject, 'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_maskPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_maskPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'Enable', 'inactive');


function edit_taskName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_taskName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_taskName as text
%        str2double(get(hObject,'String')) returns contents of edit_taskName as a double
handles.taskname = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_taskName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_taskName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'Enable', 'inactive');


function edit_ICAdir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ICAdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ICAdir as text
%        str2double(get(hObject,'String')) returns contents of edit_ICAdir as a double
if handles.useRAICAR == 0
    handles.icapath = get(hObject, 'String');
else
    handles.fmripath = get(hObject, 'String');
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_ICAdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ICAdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'Enable', 'inactive');


function edit_numCores_Callback(hObject, eventdata, handles)
% hObject    handle to edit_numCores (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_numCores as text
%        str2double(get(hObject,'String')) returns contents of edit_numCores as a double
ncores = str2double(get(hObject, 'String'));
if ncores > handles.maxcores
    handles.ncores = handles.maxcores;
elseif ncores < 1
    handles.ncores = 1;
else
    handles.ncores = round (ncores);
end
set(hObject, 'String', handles.ncores);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_numCores_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_numCores (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
if ispc
    handles.maxcores = str2double(getenv('NUMBER_OF_PROCESSORS'));
else
    handles.maxcores = feature('numcores');
end
handles.ncores = handles.maxcores;
set(hObject, 'string', handles.ncores);
set(hObject, 'Enable', 'inactive');
guidata(hObject, handles);

% --- Executes on button press in btn_save.
function btn_save_Callback(hObject, eventdata, handles)
% hObject    handle to btn_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[pass, gRAICAR_settings] = gRAICAR_check_settings (handles);
if pass == 1
    fn = sprintf ('gRAICAR_settings_%s_%s.mat', handles.taskname, datestr(now, 'mmm-dd.HH-MM'));
    uisave ('gRAICAR_settings', fn);
end


% --- Executes on button press in btn_load.
function btn_load_Callback(hObject, eventdata, handles)
% hObject    handle to btn_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load settings
[filename, pathname] = uigetfile('*.mat', 'Select a gRAICAR setting file:');
if filename ~= 0
    load (fullfile(pathname, filename));
    for nm = fieldnames(gRAICAR_settings)'
        fdnm = cell2mat (nm);
        handles.(fdnm) = gRAICAR_settings.(fdnm);
    end
    guidata(hObject, handles);

    % update ui
    set(handles.edit_workdir,   'string', handles.workdir, 'ForegroundColor', [0 0 0], 'ButtonDownFcn', [], 'Enable', 'on');
    set(handles.edit_outputDir, 'string', handles.outdir, 'ForegroundColor', [0 0 0], 'ButtonDownFcn', [], 'Enable', 'on');
    set(handles.edit_subjList,  'string', handles.subjlist, 'ForegroundColor', [0 0 0], 'ButtonDownFcn', [], 'Enable', 'on');
    set(handles.edit_taskName,  'string', handles.taskname, 'ForegroundColor', [0 0 0], 'ButtonDownFcn', [], 'Enable', 'on');
    if handles.useRAICAR == 0
        set(handles.checkbox_RAICAR, 'value', 0);
        set(handles.text5, 'string', 'First ICA File');
        set(handles.edit_ICAdir, 'string', handles.icapath, 'ForegroundColor', [0 0 0], 'ButtonDownFcn', [], 'Enable', 'on');
    else
        set(handles.checkbox_RAICAR, 'value', 1);
        set(handles.text5, 'string', 'First fMRI file')
        set(handles.edit_ICAdir, 'string', handles.fmripath, 'ForegroundColor', [0 0 0], 'ButtonDownFcn', [], 'Enable', 'on');
    end
    set(handles.edit_maskPath,  'string', handles.maskpath, 'ForegroundColor', [0 0 0], 'ButtonDownFcn', [], 'Enable', 'on');
    set(handles.edit_numCores,  'string', handles.ncores, 'ForegroundColor', [0 0 0], 'ButtonDownFcn', [], 'Enable', 'on');
    set(handles.checkbox_saveMovie, 'value', handles.savemovie, 'ForegroundColor', [0 0 0], 'ButtonDownFcn', [], 'Enable', 'on');
    set(handles.checkbox_report, 'value', handles.webreport, 'ForegroundColor', [0 0 0], 'ButtonDownFcn', [], 'Enable', 'on');
end

% --- Executes on button press in btn_run.
function btn_run_Callback(hObject, eventdata, handles)
% hObject    handle to btn_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[pass, settings] = gRAICAR_check_settings (handles);
if pass == 1
    % start step 1
    set(hObject, 'Enable', 'off');
    set(handles.text_status, 'Visible', 'on', 'String', 'Setting up gRAICAR analysis...', 'Foregroundcolor', [0,0,1]);drawnow;
    [status, exeption] = gRAICAR_step1(settings);
    if status == 0  % check error
        set(hObject, 'Enable', 'on');
        set(handles.text_status, 'Visible', 'on', 'String', 'Error in gRAICAR setup', 'Foregroundcolor', [1,0,0]);drawnow;
        rethrow (exeption);
    end
    
    % start step 2
    set(handles.text_status, 'Visible', 'on', 'String', 'Computing similarity matrix...', 'Foregroundcolor', [0,0,1]);drawnow;
    [status, exeption] = gRAICAR_step2(settings);
    if status == 0
        set(hObject, 'Enable', 'on');
        set(handles.text_status, 'Visible', 'on', 'String', 'Error in distributed computing', 'Foregroundcolor', [1,0,0]);drawnow;
        rethrow (exeption);
    end
    
    % start step 3
    set(handles.text_status, 'Visible', 'on', 'String', 'Post processing...', 'Foregroundcolor', [0,0,1]); drawnow;
    [status, exeption] = gRAICAR_step3(settings);
    if status == 0
        set(hObject, 'Enable', 'on');
        set(handles.text_status, 'Visible', 'on', 'String', 'Error in post processing', 'Foregroundcolor', [1,0,0]);drawnow;
        rethrow (exeption);
    end
    
    % when finished
    set(hObject, 'Enable', 'on');
    set(handles.text_status, 'Visible', 'on', 'String', 'gRAICAR done', 'Foregroundcolor', [0,0,1]);drawnow;    
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_workdir.
function edit_workdir_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_workdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'string', []);
set(hObject, 'Enable', 'on');
set(hObject, 'ForegroundColor', [0 0 0]);
uicontrol(hObject);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_outputDir.
function edit_outputDir_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_outputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'string', []);
set(hObject, 'Enable', 'on');
set(hObject, 'ForegroundColor', [0 0 0]);
uicontrol(hObject);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_subjList.
function edit_subjList_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_subjList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'string', []);
set(hObject, 'Enable', 'on');
set(hObject, 'ForegroundColor', [0 0 0]);
uicontrol(hObject);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_maskPath.
function edit_maskPath_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_maskPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'string', []);
set(hObject, 'Enable', 'on');
set(hObject, 'ForegroundColor', [0 0 0]);
uicontrol(hObject);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_taskName.
function edit_taskName_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_taskName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'string', []);
set(hObject, 'Enable', 'on');
set(hObject, 'ForegroundColor', [0 0 0]);
set(hObject, 'ButtonDownFcn', []); % disable the buttondown event in the corresponding edit box
uicontrol(hObject);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_ICAdir.
function edit_ICAdir_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_ICAdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'string', []);
set(hObject, 'Enable', 'on');
set(hObject, 'ForegroundColor', [0 0 0]);
uicontrol(hObject);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_ICAprefix.
function edit_ICAprefix_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_ICAprefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'string', []);
set(hObject, 'Enable', 'on');
set(hObject, 'ForegroundColor', [0 0 0]);
uicontrol(hObject);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_numCores.
function edit_numCores_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_numCores (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'string', []);
set(hObject, 'Enable', 'on');
set(hObject, 'ForegroundColor', [0 0 0]);
uicontrol(hObject);


% --- Executes on button press in btn_ICAfile.
function btn_ICAfile_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ICAfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.useRAICAR == 0
    [fn, fpth] = uigetfile('*.*', 'Select an ICA result file (.nii or .nii.gz):');
    if fn == 0
        handles.icapath = '';
    else
        handles.icapath = fullfile (fpth, fn);
    end
    set(handles.edit_ICAdir, 'String', handles.icapath);
else
    [fn, fpth] = uigetfile('*.*', 'Select an fMRI file (.nii or .nii.gz):');
    if fn == 0
        handles.fmripath = '';
    else
        handles.fmripath = fullfile (fpth, fn);
    end
    set(handles.edit_ICAdir, 'String', handles.fmripath);
end

set(handles.edit_ICAdir, 'Enable', 'on');
set(handles.edit_ICAdir, 'ForegroundColor', [0 0 0]);
set(handles.edit_ICAdir, 'ButtonDownFcn', []); % disable the buttondown event in the corresponding edit box

guidata(hObject, handles);

% --- Executes on button press in checkbox_saveMovie.
function checkbox_saveMovie_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_saveMovie (see GCBO) 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_saveMovie
handles.savemovie = get(hObject, 'Value');
guidata(hObject, handles);

% --- Executes on button press in checkbox_report.
function checkbox_report_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_report (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_report
handles.webreport = get(hObject, 'Value');
guidata(hObject, handles);


% --- Executes on button press in checkbox_RAICAR.
function checkbox_RAICAR_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_RAICAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_RAICAR
handles.useRAICAR = get(hObject, 'Value');
if handles.useRAICAR == 1
    set (handles.text5, 'string', 'First fMRI file');
    if isempty (handles.fmripath)
        set (handles.edit_ICAdir, 'string', 'processed fMRI file for the first subject', 'ForegroundColor', [1 0 0]);
    else
        set (handles.edit_ICAdir, 'string', handles.fmripath, 'ForegroundColor', [0 0 0]);
    end    
else
    set (handles.text5, 'string', 'First ICA file');
    if isempty (handles.icapath)
        set (handles.edit_ICAdir, 'string', 'ICA result file for the first subject', 'ForegroundColor', [1 0 0]);
    else
        set (handles.edit_ICAdir, 'string', handles.icapath, 'ForegroundColor', [0 0 0]);
    end
end
guidata(hObject, handles);
