function [subj] = raicar_crcm (subj)
%
% function [subj] = raicar_crcm (subj)
%
% Author: Zhi Yang
% Version: 2.0
% Last change: June 07, 2007
% 
% Purpose: 
%   construct the cross-realization correlation matrix (CRCM) from the ICA
%   repetitions, and determine the spatial correlation coefficient (SCC)
%   threshold, if it is not specified.
% Input:
%   subj: subject object. The following input field will affect this
%   function:
%       subj.setup.rlPrefix: prefix for the individual ICA realizations (.mat);
%       subj.setup.trials  : number of realizations (repetitions);
%       subj.setup.start   : starting point of the index of the ICA realizations;
%       subj.result.CRCMNm : name of the generated CRCM (and result
% Output:
%   subj: subject object. The following input field will be added/modified in this
%   function:
%       subj.result.threshold  : if not specified, will be calculated from the
%                                SCC histogram.
%       subj.result.crcm       : store the CRCM. if subj.setup.sparse is
%                                nonzero, this will be a sparse matrix
%   The CRCM, SCC histogram and SCC threshold will be written out to hard disk, named by 
%   "subj.setup.CRCMNm.mat";
% 

fprintf ('\n Computing CRCM...\t');
% initialize
warning ('off', 'MATLAB:divideByZero');
warning ('off', 'MATLAB:log:logOfZero');
cumHist = zeros (1, 100);
start = subj.setup.start;
matprefix = subj.setup.rlPrefix;
if subj.setup.sparse ~= 0
    subj.result.CRCM = sparse (1,1);
end

% compute CRCM
for r = 1:subj.setup.trials
    fprintf ('\n Step: %d of %d\n\t', r, subj.setup.trials);
    tic

    % get the reference realization
    matNm = strcat (matprefix, num2str (r+start-1), '.mat');
    load (matNm);
    

    %%%%%%%%%%%%%%%% tmp %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %if r ~= 1
%	icasig = icasig2;
%        A = A2;
%        W = W2;
%    end
    %%%%%%%%%%%%%%% end of tmp %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    compMap = icasig;
    clear icasig* W* A*;
    
    % record numIC for each trial
    subj.result.numIC(r) = size (compMap, 1);

    % go through all other realizations
    for i = r+1:subj.setup.trials
        matNm = strcat (matprefix, num2str (i+start-1), '.mat');
        load (matNm);
    %%%%%%%%%%%%%%%% tmp %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    if i ~= 1
%	icasig = icasig2;
%        A = A2;
%        W = W2;
%    end
    %%%%%%%%%%%%%%% end of tmp %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        compMap2 = icasig;
        clear icasig* W* A*;
        subj.result.numIC(i) = size (compMap2, 1);
        
        % calc cc matrix
        %[spatialCc, numIC1, numIC2] = raicar_calcMutualInfo (compMap, compMap2);
        [spatialCc, numIC1, numIC2] = raicar_calcSpatialCc (compMap, compMap2);
        spatialCc = abs (spatialCc);

        % accumulate histogram
        cumHist = cumHist + hist (spatialCc(:), 0.01:0.01:1);
        
        if subj.setup.sparse ~= 0
            % using 0.3 as threshold to save RAM
            spatialCc (spatialCc < 0.3) = 0;
	    spatialCc = sparse (spatialCc);
	end
        subj.result.CRCM(sum (subj.result.numIC(1:r-1))+1:sum (subj.result.numIC(1:r)), ...
                sum (subj.result.numIC(1:i-1))+1:sum (subj.result.numIC(1:i))) = spatialCc;
            
        subj.result.CRCM(sum (subj.result.numIC(1:i-1))+1:sum (subj.result.numIC(1:i)), ...
                sum (subj.result.numIC(1:r-1))+1:sum (subj.result.numIC(1:r))) = ... 
        subj.result.CRCM(sum (subj.result.numIC(1:r-1))+1:sum (subj.result.numIC(1:r)), ...
                sum (subj.result.numIC(1:i-1))+1:sum (subj.result.numIC(1:i)))';
            
            %subj.result.CRCM(numIC1*(r-1)+1:numIC1*r, numIC2*(i-1)+1:numIC2*i) = ...
            %    sparse (spatialCc);
            %subj.result.CRCM(numIC2*(i-1)+1:numIC2*i, numIC1*(r-1)+1:numIC1*r) = ... 
            %   subj.result.CRCM(numIC1*(r-1)+1:numIC1*r, numIC2*(i-1)+1:numIC2*i)'; 
        clear spatialCc;
        fprintf ('.');
    end
    fprintf ('\n\t');
    toc,
end
fprintf ('\tsuccess\n');

% determine the SCC threshold
if isempty (subj.setup.threshold)
    fprintf ('\n Determining SCC threshold...\t');
    
    % get histogram
	logfreqdist = log (cumHist);
	logfreqdist (logfreqdist == -Inf) = 0; 	

	% determined threshold
	[lmval, indinv] = lmin (fliplr (logfreqdist), 4);
	[v, tmp] = min (lmval);
	indinv = indinv (tmp);
	[lmval, indseq] = lmin (logfreqdist, 4);
	[v, tmp] = min (lmval);
	indseq = indseq(tmp);
	subj.result.threshold = floor ((101-indinv+indseq)/2)/100;

	% chech whether the threshold is available
    if isempty (subj.result.threshold)
		[lmval, indinv] = lmin(fliplr (logfreqdist), 1);
		[v, tmp] = min (lmval);
		indinv = indinv(tmp);
		[lmval, indseq] = lmin(logfreqdist, 1);	 
		[v, tmp] = min (lmval);
		indseq = indseq(tmp);
		subj.result.threshold = floor ((101-indinv+indseq)/2)/100;
    end
    fprintf ('\tsuccess\n');
else
    subj.result.threshold = subj.setup.threshold;    
    logfreqdist = 0;
end

% save CRCM
 fprintf ('\n Saving CRCM backup...\t');
fn = [subj.setup.outPrefix, '_CRCM.mat'];
CRCM = subj.result.CRCM;
thr = subj.result.threshold;
numIC = subj.result.numIC;
save (fn, 'CRCM', 'logfreqdist', 'thr', 'numIC');
fprintf ('\tsuccess\n');
