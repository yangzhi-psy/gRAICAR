function FileExtension = getExtension(FileName)
%Gets the extension of a filename. The extension is assumed to be the last
%dot of the filename and all characters following the last dot. If there is
%no dot, then FileExtension is empty.
%
%This code seems useful when you allow the user to select a file (eg. using
%uigetfile), and you want to do different things based on the extension of
%the file the user has chosen. You could do this with the index of the
%options of uigetfile, but this gives a way for the user to see all files
%in a directory, and still determine the type of file that was chosen.
%
% Example:
% LoadFileExt = GetExtension(LoadFileName)
% if isempty(LoadFileExtension)
% ...
% elseif LoadFileExtension = '.txt'
% ...
% elseif LoadFileExtenstion = '.mat'
% ...
% end
%
%Sure, its short, but useful. Maybe you coudl extend it to be used with an
%array of filenames, but I'm not sure where that would be useful.

extIndices= findstr('.',FileName);
FileExtension = FileName(max(extIndices):length(FileName));

