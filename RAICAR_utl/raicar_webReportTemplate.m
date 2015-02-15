function raicar_webReportTemplate (component, total, dirNm)
%
% function raicar_webReportTemplate (component, total, dirNm)
%
% Author: Zhi Yang
% Version: 2.0
% Last change: July 1, 2007
% 
% Purpose: 
%   generate the index page of the webreport
% Input:
%   component : current component
%   total     : total number of the components
%   dirNm     : the path and name of the target directory
% Output:
%   None
%

% check input
if ~isa (component, 'numeric') || mod (component, 1) ~= 0
    error ('raicar_webReportTemplate: the first input, component, is not integer');
end
if ~isa (total, 'numeric') || mod (total, 1) ~= 0
    error ('raicar_webReportTemplate: the second input, total, is not integer');
end
if component > total
    error ('raicar_webReportTemplate: current component > total number!');
end

% generate page
fn = sprintf ('%s/IC_%d.html', dirNm, component);
fid = fopen (fn, 'w');
fprintf (fid, '<html>\n');
fprintf (fid, '<head>\n');
fprintf (fid, '<title>RAICAR Report: Component %d</title>\n', component);
fprintf (fid, '</head>\n');

fprintf (fid, '<body>\n');
fprintf (fid, '<h1 align="center">Component %d</h1>', component);

fprintf (fid, '<table border="0" align="center" cellpadding="10">\n');
fprintf (fid, '<tr>\n');

if component ~= 1
	fn = sprintf ('IC_%d.html', component-1);
	fprintf (fid, '<td><a href="%s">Previous component</a></td>\n', fn);
end
fn = '00_index.html';
fprintf (fid, '<td><a href="%s">Index</a></td>\n', fn);
if component ~= total
	fn = sprintf ('IC_%d.html', component+1);
	fprintf (fid, '<td><a href="%s">Next component</a></td>\n', fn);
end
	
fprintf (fid, '<table border="0" align="center" cellpadding="5">\n');
fprintf (fid, '<tr>\n');
fn = sprintf ('map_IC%d.png', component);
fn2 = sprintf ('map_IC_nothresh%d.png', component);
fprintf (fid, '<td colspan="2" align="center"><a href="%s"><img src="%s" align="center"></td>\n', fn2, fn);
fprintf (fid, '</tr>\n');

fprintf (fid, '<tr>\n');
fn = sprintf ('tc_IC%d.png', component);
fprintf (fid, '<td align="center"><img src="%s" align="center"></td>\n', fn);
fn = sprintf ('rank_IC%d.png', component);
fprintf (fid, '<td align="center"></><img src="%s" align="left"></td>\n', fn);
fprintf (fid, '</tr>\n');
fprintf (fid, '</body>\n');
fprintf (fid, '</html>\n');
fclose (fid);
