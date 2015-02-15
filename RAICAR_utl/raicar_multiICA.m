function raicar_multiICA (subj)
%
% function raicar_multiICA (subj)
% 
% Author: Zhi Yang
% Version: 2.0
% Last change: May 06, 2007
% 
% Purpose: 
%   Repeat ICA multiple times. According to the subj.setup.initOption, 
%   raicar_multiICA use different initialization and/or different resample 
%   of the data to perform each ICA decomposition.
% Input:
%   subj: subject object. The following input field will affect this
%   function:
%       subj.result.forIca : input data for ICA;
%       subj.setup.trials  : number of realizations (repetitions);
%       subj.initOption    : options for initializing the ICA decomposition
%           'randinit' (default): randomly generate the inital guess of
%                                 ICA,using current time as random seed;
%           'bootstrap'         : randomly resample the data and perform
%                                 the ICA using the result of the first ICA
%                                 as initial guess (so that the initial
%                                 guesses are the same across different
%                                 ICA realizations);
%           'both'              : randomly resample the data as well as
%                                 randomly generate the initial guess for
%                                 each ICA realization;
%       subj.setup.rlPrefix: prefix for the genearated ICA results (.mat);
%       subj.setup.start   : starting point of the index of the ICA realizations;
%       subj.setup.ICAoption: options for FastICA;
% Output:
%   None. But the ICA decomposition results will be written out to hard
%   disk, named by the "subj.setup.rlPrefix_ICA_run";
%

fprintf ('\n Computing multiple ICA realizations (this may take quite a while)...\t');

initCond = [];
flagResample = 0;
[vectorSize, numSamples] = size (subj.result.forIca);
numOfIC = vectorSize;
subj.result.forIca = double (subj.result.forIca);
origData = [];

% prepare the initialization
switch subj.setup.initOption
    case 'bootstrap'
        flagResample = 1;
        origData = subj.result.forIca;
        if strcmp (subj.setup.ICAOption.approach, 'symm')
            initCond = orth (randn (vectorSize, numOfIC));
        elseif strcmp (subj.setup.ICAOption.approach, 'defl')
            initCond = randn (vectorSize, 1);
        end
    case 'both'
        flagResample = 1;
        origData = subj.result.forIca;
        initCond = [];
    case 'randinit'
        flagResample = 0;
        initCond = [];
    otherwise
        error ('raicar_multiICA: unrecognized initOption %s', subj.setup.initOption);
end

% prepare ICA command
icaCmd = [];
optionName = fields (subj.setup.ICAOption);
optionValue = struct2cell (subj.setup.ICAOption);

for i = 1:length (optionName)
    name = cell2mat (optionName(i));
    name = strcat ('''', name, '''');
    value = cell2mat (optionValue(i));
    if isnumeric (value)
        value = num2str (value);
    else
        value = strcat ('''', value, '''');
    end
    if i == 1
	icaCmd = sprintf (', %s, %s', name, value);
    else
        icaCmd = sprintf ('%s, %s, %s', icaCmd, name, value);
    end
end
% icaCmd = sprintf ('[icasig, A, W, flagConverge] = fastica_varianceThr (subj.result.forIca, %s, initCond, %s, %s%s);', '''initGuess''', '''verbose''', '''off''', icaCmd);
icaCmd = sprintf ('[icasig, A, W, flagConverge] = fastica (subj.result.forIca, %s, initCond, %s, %s%s);', '''initGuess''', '''verbose''', '''off''', icaCmd);
icaCmd,

% perform ICA 
for i=1+subj.setup.start-1:subj.setup.trials+subj.setup.start-1
    flagConverge = 0;
    if flagResample == 1
	old_forIca = subj.result.forIca;
        subj.result.forIca = raicar_resample (subj.result.forIca);
    end
    while (flagConverge ==0)
        fprintf ('\n ICA run%d: \n', i);
        eval (icaCmd);
    end
    if flagResample == 1
        icasig = W*origData;
	subj.result.forIca = old_forIca;
    end
    filename = strcat (subj.setup.rlPrefix, num2str (i),'.mat');
    save (filename, 'icasig', 'A', 'W');
end 

fprintf ('\tsuccess\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub-functions *****************************

function data = raicar_resample (data)
%
% function resampled = raicar_resample (data)
%
% Purpose:
%   bootstrap data: random sample the data
% Input:
%   data: data matrix to be resampled. each column is a sample
% Output:
%   data: resampled data
%

numSamples = size (data, 2);
rand('state', sum(100*clock));
index = round (rand (numSamples, 1)*numSamples+0.5);
data = data (:, index);

