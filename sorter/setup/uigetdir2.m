function [path] = uigetdir2(start_path, dialog_title)
% UIGETDIR2 prompt directory dialog that comes with a title.
%
%   PATH = UIGETDIR2() opens a dialog in the current working directory with
%   title 'Open' whereby the user can select a directory.
%
%   PATH = UIGETDIR2(START_PATH) opens a dialog with title 'Open' in the
%   directory START_PATH. If START_PATH does not exist, the current working
%   directory is used.
%
%   PATH = UIGETDIR2(START_PATH, DIALOG_TITLE) opens a dialog with title
%   DIALOG_TITLE in the directory START_PATH.
%
%   PATH = UIGETDIR2('', DIALOG_TITLE) opens a dialog with title DIALOG_TITLE in
%   the current working directory.
%
% Prompt user for a directory with a directory open dialog. This is the same as
% UIGETDIR, except the title of the dialog is customizable. If user cancels
% the operation, returns empty string.
%
% INPUT:
% START_PATH    (optional) String of path to the starting search directory. If
%               this value is empty or does not exist, the dialog will start in
%               the current working directory.
% DIALOG_TITLE  (optional) String for the dialog title.
%
% OUTPUT:
% PATH          String of the absolute path to the user-chosen directory. If
%               the user cancels the operation, returns an empty string.
%
% See also UIGETDIR
%
% Source:
% http://stackoverflow.com/questions/6349410/using-uigetfile-instead-of-uigetdir-to-get-directories-in-matlab

    import javax.swing.JFileChooser;

    if nargin == 0 || isempty(start_path) || ~exist(start_path, 'dir')
        start_path = pwd;
    end

    jchooser = javaObjectEDT('javax.swing.JFileChooser', start_path);

    jchooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
    
    if nargin > 1
        jchooser.setDialogTitle(dialog_title);
    end

    status = jchooser.showOpenDialog([]);

    if status == JFileChooser.APPROVE_OPTION
        jFile = jchooser.getSelectedFile();
        path = char(jFile.getPath());
    elseif status == JFileChooser.CANCEL_OPTION
        path = '';
    else
        error('Error occurred while picking file');
    end

end
