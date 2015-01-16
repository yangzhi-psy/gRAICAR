
function [obj, null_interSb_reproMap] = gRAICAR_examRepro (obj, numIter, null_interSb_reproMap)

if nargin == 1
	numIter=1000;
    flag_genNull = 1;
elseif nargin == 2
    flag_genNull = 1;
else
    flag_genNull = 0;
end

obj=load_cmptFile(obj, 0);

% normalize according to new alignment algorithm
obj = normByRow (obj);
obj.result.MICM = obj.result.MICM'+obj.result.MICM;
min_MICM = min (obj.result.MICM(:));
obj.result.MICM = obj.result.MICM - min_MICM;

if flag_genNull == 1
    null_interSb_reproMap = generateNullRepro (obj, numIter);
end

[obj.result.beta_rank_subjLoad, obj.result.sig_subjLoad, obj.result.subjLoad,obj.result.null_subjLoad] = examSigSubjLoad (obj, null_interSb_reproMap);
