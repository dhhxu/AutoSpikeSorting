function [rfs_string] = get_rfs_from_user()
% GET_RFS_FROM_USER get manual RF information from user.
%
%   RFS_STRING = GET_RFS_FROM_USER()
%
%   Opens a dialog for the user to enter RF information manually. The format is
%   as follows:
%
%   If an entire block is an entire RF, enter the block number only
%   If a block has multiple RFs, enter:
%       block(part A part B ...)
%   If a block has no RFs, do not enter its number.
%
%   All the entered blocks must be comma separated.
%
%   The blocks must be unique and in order. Within a block, any entered parts
%   must also be unique and in order.
%
%   Examples:
%
%       Simple case: 1, 2, 6, 9, 27, 27, 31
%
%       Hard case: 1, 2(1 5 8), 3(4 7), 4(4 7)
%
%   This format must be adhered to; otherwise, errors will occur in validation
%   and/or parsing.
%
%   INPUT:
%   NONE
%
%   OUTPUT:
%   RFS_STRING  String of manually entered RFs. If operation is cancelled,
%               returns empty string.

    s = sprintf('Instructions:\n');
    s = sprintf('%s1. Only enter blocks that contain receptive field(s).\n', s);
    s = sprintf('%s2. If a block is an entire RF, enter its number only.\n', s);
    s = sprintf('%s3. If a block has multiple RFs, enter:\n', s);
    s = sprintf('%s\tblock(part A, part B, ...)\n', s);
    s = sprintf('%s4. All blocks must be unique and in increasing order.\n', s);
    s = sprintf('%s5. This also applies to parts, if any.\n', s);
    s = sprintf('%s6. All entered blocks must be comma separated.\n', s);
    s = sprintf('%s7. Parts must be separated by spaces.\n', s);
    s = sprintf('%s\nExamples:\n', s);
    s = sprintf('%sSimple:\t1, 2, 6, 9, 27, 27, 31\n', s);
    s = sprintf('%sHard:\t1, 2(1 5 8), 3(4 7), 4(4 7)\n', s);
    
    prompt = {s};
    title = 'Manual RF entry';
    numlines = 1;
    
    rfs_string = inputdlg(prompt, title, numlines);
    
    if isempty(rfs_string)
        rfs_string = '';
    else
        rfs_string = rfs_string{1};
    end
    
    
end