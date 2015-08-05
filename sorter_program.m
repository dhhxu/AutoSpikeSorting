function varargout = sorter_program(varargin)
% SORTER_PROGRAM MATLAB code for sorter_program.fig
%      SORTER_PROGRAM, by itself, creates a new SORTER_PROGRAM or raises the existing
%      singleton*.
%
%      H = SORTER_PROGRAM returns the handle to a new SORTER_PROGRAM or the handle to
%      the existing singleton*.
%
%      SORTER_PROGRAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SORTER_PROGRAM.M with the given input arguments.
%
%      SORTER_PROGRAM('Property','Value',...) creates a new SORTER_PROGRAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sorter_program_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sorter_program_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sorter_program

% Last Modified by GUIDE v2.5 05-Aug-2015 17:36:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sorter_program_OpeningFcn, ...
                   'gui_OutputFcn',  @sorter_program_OutputFcn, ...
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


% --- Executes just before sorter_program is made visible.
function sorter_program_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sorter_program (see VARARGIN)

handles.align_opt = 'none';
handles.current_spikes = [];
handles.original_spikes = [];
handles.shift = 5;

handles.is2d = true;

handles.feature = @pca75;
handles.algo = @sorter_kmeans;

handles.DATA_PATH = 'U:\DanielX\data';

% Choose default command line output for sorter_program
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sorter_program wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sorter_program_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on selection change in align_popup.
function align_popup_Callback(hObject, eventdata, handles)
% hObject    handle to align_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns align_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from align_popup

    opt = get(hObject, 'String');
    val = get(hObject, 'Value');
    
    switch opt{val}
        case 'None'
            handles.align_opt = 'none';
        case 'Maximum'
            handles.align_opt = 'max';
        case 'Minimum'
            handles.align_opt = 'min';
    end
    
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function align_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to align_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_unit_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to num_unit_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_unit_textbox as text
%        str2double(get(hObject,'String')) returns contents of num_unit_textbox as a double

    k_str = get(hObject, 'String');
    
    k_num = str2double(k_str);
    
    if isnan(k_num) || ceil(k_num) ~= floor(k_num)
        errordlg('You must enter an interger', 'Invalid Input', 'modal');
    elseif k_num < 1
        errordlg('You must enter a positive integer', 'Invalid Input', 'modal');
    end
    
    handles.k = k_num;
    
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function num_unit_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_unit_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sort_button.
function sort_button_Callback(hObject, eventdata, handles)
% hObject    handle to sort_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    feat = handles.feature;
    algo = handles.algo;
    

function max_shift_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to max_shift_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_shift_textbox as text
%        str2double(get(hObject,'String')) returns contents of max_shift_textbox as a double

    raw_shift = get(hObject, 'String');
    
    shift = str2double(raw_shift);
    
    if isnan(shift) || floor(shift) ~= ceil(shift)
        errordlg('You must enter an integer', 'Invalid Input', 'modal');
    elseif shift < 0
        errordlg('You must enter a positive integer', 'Invalid Input', 'modal');
    end
    
    handles.shift = shift;
    
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function max_shift_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_shift_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in align_apply_button.
function align_apply_button_Callback(hObject, eventdata, handles)
% hObject    handle to align_apply_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if isempty(handles.original_spikes)
        % popup
        return
    end

    opt = handles.align_opt;
    guidata(hObject, handles);
    
    if strcmp(opt, 'none')
        handles.current_spikes = handles.original_spikes;
    else        
        aligned = align_snip(handles.original_spikes, handles.shift, opt);
        handles.current_spikes = aligned;
    end

    % plot
    
    axes(handles.spike_axes);
    
    nSpikes = size(handles.current_spikes, 1);
    hold on;
    for i = 1:nSpikes
        plot(handles.current_spikes(i, :));
    end
    hold off;

    
% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function feature_menu_Callback(hObject, eventdata, handles)
% hObject    handle to feature_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function algo_menu_Callback(hObject, eventdata, handles)
% hObject    handle to algo_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_tank_open_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tank_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [TANK, PATH] = sorter_get_tank();

    if isempty(TANK) || isempty(PATH)
        return;
    end

    handles.tank = TANK;
    handles.path = PATH;
    
    guidata(hObject, handles);

% --------------------------------------------------------------------
function export_menu_Callback(hObject, eventdata, handles)
% hObject    handle to export_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    DATA_PATH = sorter_get_dir(handles.DATA_PATH);
    
    if isempty(DATA_PATH)
        return
    end
    
    handles.DATA_PATH = DATA_PATH;
    guidata(hObject, handles);    

% --------------------------------------------------------------------
function exit_menu_Callback(hObject, eventdata, handles)
% hObject    handle to exit_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    closereq;

% --------------------------------------------------------------------
function algorithm_menu_select_Callback(hObject, eventdata, handles)
% hObject    handle to algorithm_menu_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function feature_select_menu_Callback(hObject, eventdata, handles)
% hObject    handle to feature_select_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in feature_dim_group.
function feature_dim_group_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in feature_dim_group 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    switch get(eventdata.NewValue, 'Tag')
        case 'radiobutton3'
            handles.is2d = true;
        case 'radiobutton4'
            handles.is2d = false;
    end
    
    guidata(hObject, handles);
    
    if isempty(handles.current_spikes)
        return
    end
    
    fs = handles.feature(handles.current_spikes);
    
    if size(fs, 2) < 3
        % error
    end
    
    fs = fs(:, 1:3);
    
    if handles.is2d
        scatter(fs(:, 1), fs(:, 2), 5);
    else
        scatter3(fs(:, 1), fs(:, 2), fs(:, 3), 0.9);
    end
    
    
