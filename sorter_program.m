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

% Last Modified by GUIDE v2.5 07-Aug-2015 13:21:16

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

    % initialize path, load_path must be in same directory as this program.
%     load_path(pwd);

    % User settings mat file name. Name should be constant.
    handles.SETTINGS_FILENAME = 'sorter_settings.mat';

    % initialize variables
    
    if ~exist(handles.SETTINGS_FILENAME, 'file')
        handles.feat_dir = uigetdir2('', 'Select feature directory');
        handles.algo_dir = uigetdir2('', 'Select algorithm directory');
        handles.data_dir = uigetdir2('', 'Select data export directory');

    else
        % load settings
        handles = load_settings(handles);
    end
    
    display(handles.feat_dir);
    display(handles.algo_dir);
    display(handles.data_dir);

    
    handles.tank = '';
    handles.path = '';
    handles.align_opt = 'none';
    handles.current_spikes = [];
    handles.original_spikes = [];
    handles.shift = 5;
    handles.superblocks = cell(0);

    handles.is2d = true;

    % These two should be existing functions inside the project path.
    handles.feature = @pca75;
    handles.algo = @sorter_kmeans;

    handles.k = 0;
    
    set(handles.feature_dim_group, 'selectedobject', handles.radiobutton3);

    feature_str = sprintf('Feature: %s', func2str(handles.feature));
    update_static_text_string(handles.feature_name, feature_str);

    algo_str = sprintf('Algorithm: %s', func2str(handles.algo));
    update_static_text_string(handles.algo_name, algo_str);

    % Choose default command line output for sorter_program
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes sorter_program wait for user response (see UIRESUME)
    % uiwait(handles.sorter_program_figure);


% --- Outputs from this function are returned to the command line.
function varargout = sorter_program_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% -----------------------------------------------------------------------------
% Helpers
% -----------------------------------------------------------------------------
function [] = update_static_text_string(text_obj, new_str)
% Update the string property of the static text object TEXTOBJ with string
% NEW_STR

    set(text_obj, 'string', new_str);
    
function [] = save_settings(handles)
% Saves select fields of HANDLES to a settings struct. This struct is saved as
% the value of handles.SETTINGS_FILENAME.

    settings.feat_dir = handles.feat_dir;
    settings.algo_dir = handles.algo_dir;
    settings.data_dir = handles.data_dir;
    
    save(handles.SETTINGS_FILENAME, 'settings');

    
function [handles] = load_settings(handles)
% Load the settings file located at handles.SETTINGS_FILE_PATH. The file is
% assumed to exist. Then update fields in HANDLES with the corresponding saved
% settings.

    settings = load(handles.SETTINGS_FILENAME);
    settings = settings.settings;
    
    handles.feat_dir = settings.feat_dir;
    handles.algo_dir = settings.algo_dir;
    handles.data_dir = settings.data_dir;
    
    
function [] = plotspikes(handles)
% Plot the spikes in the handle's current spikes

    nSpikes = size(handles.current_spikes, 1);
    hold on;
    for i = 1:nSpikes
        plot(handles.current_spikes(i, :));
    end
    hold off;


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
        return
    elseif k_num < 1
        errordlg('You must enter a positive integer', 'Invalid Input', 'modal');
        return
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

    if isempty(handles.superblocks)
        return
    end

    feat = handles.feature;
    algo = handles.algo;
    
    tank_info.tank = handles.tank;
    tank_info.path = handles.path;

% Notes:
% Need to add handles parameter to below function to update handle fields
% like current_spikes
% Below function would need to block to wait for user input.
% The interactive parts in this function should be removed since the GUI
% replaces the interactive functionality
%
% e.g. After superblocks created through open_tank user presses sort
% button. The first press should bring up the first superblock/channel.
% Then the  sorter_cluster_superblock should block somehow to wait for user
% to align and determine # of units. The second press of sort would unblock
%  sorter_cluster_superblock, and so on.
%
%     sorter_cluster_superblock(handles.superblocks, feat, algo, tank_info, ...
%                               handles.data_dir);
    

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
        return
    elseif shift < 0
        errordlg('You must enter a positive integer', 'Invalid Input', 'modal');
        return
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
        errordlg('No spikes loaded', 'Align Error', 'modal');
        return
    end

    opt = handles.align_opt;
    
    if strcmp(opt, 'none')
        handles.current_spikes = handles.original_spikes;
    else
        aligned = align_snip(handles.current_spikes, handles.shift, opt);
        handles.current_spikes = aligned;
    end
    
    guidata(hObject, handles);

    % plot
    
    axes(handles.spike_axes);
    plotspikes(handles);

% --------------------------------------------------------------------
function menu_tank_open_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tank_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [tank, path] = sorter_get_tank('U:/');

    if isempty(tank) || isempty(path)
        return;
    end

    handles.tank = tank;
    handles.path = path;
    
    guidata(hObject, handles);

    % make superblocks
    tic
    [superblocks, ~, ~] = build_rfblock(handles.path, handles.data_dir);
    toc
    
    handles.superblocks = superblocks;
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function exit_menu_Callback(hObject, eventdata, handles)
% hObject    handle to exit_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    % save state to settings file
    if exist(handles.SETTINGS_FILENAME, 'file')
        delete(handles.SETTINGS_FILENAME);
    end
    
    save_settings(handles);
    
    closereq

    
% --------------------------------------------------------------------
function algo_menu_Callback(hObject, eventdata, handles)
% hObject    handle to algo_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function algorithm_select_menu_Callback(hObject, eventdata, handles)
% hObject    handle to algorithm_select_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    algo_handle = sorter_get_algorithm(handles.algo_dir);

    if isempty(algo_handle)
        return
    end
    
    handles.algo = algo_handle;
    
    algo_str = sprintf('Algorithm: %s', func2str(handles.algo));
    update_static_text_string(handles.algo_name, algo_str);
    
    guidata(hObject, handles);

% --------------------------------------------------------------------
function feature_menu_Callback(hObject, eventdata, handles)
% hObject    handle to feature_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function feature_select_menu_Callback(hObject, eventdata, handles)
% hObject    handle to feature_select_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    feat_handle = sorter_get_feature(handles.feat_dir);

    if isempty(feat_handle)
        return
    end
    
    handles.feature = feat_handle;
    
    feature_str = sprintf('Feature: %s', func2str(handles.feature));
    update_static_text_string(handles.feature_name, feature_str);
    
    guidata(hObject, handles);

% --- Executes when selected object is changed in feature_dim_group.
function feature_dim_group_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in feature_dim_group 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    switch get(eventdata.NewValue, 'Tag')
        case 'radiobutton3'
            handles.is2d = true;
            set(handles.feature_name, 'String', '2d');
        case 'radiobutton4'
            handles.is2d = false;
            set(handles.feature_name, 'String', '3d');
    end

    if isempty(handles.current_spikes)
        return
    end
    
    guidata(hObject, handles);
    
    fs = handles.feature(handles.current_spikes);
    
    if size(fs, 2) < 3
        errordlg('Too few feature dimensions', 'Feature Error', 'modal');
        return
    end
    
    fs = fs(:, 1:3);
    
    if handles.is2d
        scatter(fs(:, 1), fs(:, 2), 5);
    else
        scatter3(fs(:, 1), fs(:, 2), fs(:, 3), 0.9);
    end

    
% --------------------------------------------------------------------
function path_settings_Callback(hObject, eventdata, handles)
% hObject    handle to path_settings_Callback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function set_feat_dir_menu_Callback(hObject, eventdata, handles)
% hObject    handle to set_feat_dir_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    feat_dir = uigetdir2('', 'Select features directory');

    if isempty(feat_dir)
        return
    end
    
    handles.feat_dir = feat_dir;
    guidata(hObject, handles);

% --------------------------------------------------------------------
function set_algo_dir_menu_Callback(hObject, eventdata, handles)
% hObject    handle to set_algo_dir_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    algo_path = uigetdir2('', 'Select algorithm directory');

    if isempty(algo_path)
        return
    end
    
    handles.algo_dir = algo_path;
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function set_data_dir_menu_Callback(hObject, eventdata, handles)
% hObject    handle to set_data_dir_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    data_dir = uigetdir2(handles.data_dir, 'Select data output directory');

    if isempty(data_dir)
        return
    end
    
    handles.data_dir = data_dir;
    guidata(hObject, handles);

% --- Executes when user attempts to close sorter_program_figure.
function sorter_program_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to sorter_program_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

    % save state to settings file
    if exist(handles.SETTINGS_FILENAME, 'file')
        delete(handles.SETTINGS_FILENAME);
    end
    
    save_settings(handles);

    delete(hObject);
