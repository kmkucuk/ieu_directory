function varargout = uigetfiles(varargin)
% UIGETFILES: Open file(s) dialog box
%     UIGETFILES(DIRECTORY)
%     displays GUI to select a single or multiple 
%     files from a DIRECTORY and returns PATHNAME
%     and FILENAME to the base workspace (varname
%     unchangeable)
%     
%     In the case of a multple selection PATHNAME
%     and FILENAME are vectors. To affirm the se-
%     lection press the OK-Button. Unfortunately
%     there is no discrimination between directo-
%     ries and files. To abort press the Cancel-
%     button.
    
if nargin <= 1   % LAUNCH GUI
	if nargin == 0 
		initial_dir = pwd;
	elseif nargin == 1 & exist(varargin{1},'dir')  
		initial_dir = varargin{1};
	else
		errordlg('Input argument must be a valid directory','Input Argument Error!')
		return
	end
	% Open FIG-file
	fig = openfig(mfilename,'reuse');	% Generate a structure of handles to pass to callbacks, and store it. 
	set(fig,'Color',[0.66 0.76 1], 'name', 'Select file(s)');
    handles = guihandles(fig);
	guidata(fig, handles);
	% Populate the listbox
	load_listbox(initial_dir,handles)
	% Return figure handle as first output argument
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end

% --------------------------------------------------------------------
function varargout = listbox_Callback(h, eventdata, handles, varargin)
if strcmp(get(handles.figure1,'SelectionType'),'open')
	index_selected = get(handles.listbox,'Value');
	file_list = get(handles.listbox,'String');	
	filename = file_list{index_selected};
	if  handles.is_dir(handles.sorted_index(index_selected))
		cd (filename)
		load_listbox(pwd,handles)
    end
end

% --------------------------------------------------------------------
function varargout = ok_button_Callback(h, eventdata, handles, varargin)
global initial_dir
list_entries = get(handles.listbox,'String');
index_selected = get(handles.listbox,'Value');
filename = list_entries(index_selected); 
pathname = pwd; 
if strcmp(filename, '.') == 0 & strcmp(filename, '..') == 0
    assignin('base', 'filename', filename)
    assignin('base', 'pathname', pathname)
    delete(handles.figure1)
end
% --------------------------------------------------------------------
function varargout = cancel_button_Callback(h, eventdata, handles, varargin)
delete(handles.figure1)
% --------------------------------------------------------------------
function load_listbox(dir_path,handles)
cd (dir_path)
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = [sorted_index];
guidata(handles.figure1,handles)
set(handles.listbox,'String',handles.file_names,...
	'Value',1)
set(handles.text1,'String',pwd)