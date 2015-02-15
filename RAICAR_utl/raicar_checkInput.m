function [subj, errMsg] = raicar_checkInput (subj, mandatory, defaults)
%
% function [subj, errMsg] = raicar_checkInput (subj, mandatory, defaults)
% 
% Author: Zhi Yang
% Version: 2.0
% Last change: May 05, 2007
%
% Purpose: 
%   Validate the mandatory input arguments and set up the default values of
%   the optional input arguments. 
%   NOTE: This function only checks FIRST LEVEL fields of the input object;
% Input:
%   subj: subject object containing the input information;
%   mandatory: a cell array storing the names of all the mandatory fields;
%   defaults: a structure containing all the default values for the
%             optional input;
% Output:
%   subj: updated subject object (if no error occurs)
%   errMsg: a string describing the latest error. empty if no error occurs
%

errMsg = [];

% check input 
[errMsg] = nargchk(3, 3, nargin);
if ~isempty (errMsg)
    error ('raicar_checkInput takes and only takes three input argument: subject object, mandatory input list, and default settings for optional input');
end

if ~isa (mandatory, 'cell')
    error ('raicar_checkInput requires the second input argument as a cell arrary');
end

if ~isa (defaults, 'struct')
    error ('raicar_checkInput requires the third input argument as a structure');
end

if ~isa (subj, 'struct')
    error ('raicar_checkInput requires the first input argument as a structure');
end


% check mandatory fields
for fd = mandatory
    fdn = cell2mat (fd);
    if ~isfield (subj, fdn); 
        errMsg = sprintf ('Error: input does not define mandatory field "%s".', fdn);
        return;
    elseif isempty (subj.(fdn))
        errMsg = sprintf ('Error: mandatory input "%s" is empty.', fdn);
        return;
    end
end
        
% check optional fields
optional = fieldnames (defaults);
for fd = optional'
    fdn = cell2mat (fd);
    if ~isfield (subj, fdn) || isempty (subj.(fdn))
        subj.(fdn) = defaults.(fdn);
    end
end