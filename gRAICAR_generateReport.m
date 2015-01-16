function gRAICAR_generateReport (obj, threshold, compPerPage)


% check whether the output directory exists
dirNm = strcat (obj.setup.outPrefix, '_webreport');
count = 1;
while exist (dirNm, 'dir')
    dirNm = strcat (dirNm, num2str (count));
    count = count + 1;
end
mkdir (dirNm);
    
% generate the index page: 00index.html
totalComp = length (obj.result.foundRepro);
indexNm = strcat (dirNm, '/00index');
generateIndex (totalComp, indexNm, compPerPage);

% plot meanNMI rank
h = figure ('Visible', 'off', 'Position', [0,0,3,3], 'unit', 'inch');
set (gca, 'Position', [0.2, 0.15, 0.75, 0.75]);
bar (obj.result.meanRepro)
xlabel ('Subject');
ylabel ('Mean similarity');
fn = sprintf ('%s/rank_meanSim.png', dirNm);
print (h, '-dpng', fn);

% plot ratio of significant subjects
set (gca, 'Position', [0.2, 0.15, 0.75, 0.75]);
bar (1-obj.result.beta_rank_subjLoad)
xlabel ('Subject');
ylabel ('Ratio of significant subjects');
fn = sprintf ('%s/rank_betaRank.png', dirNm);
print (h, '-dpng', fn);

% generate plots for each component
load (sprintf('%s_aveMap.mat', obj.setup.outPrefix));
load anat2D.mat;    % predefined anat underlay
sz = size (map4D);

h = figure ('Visible','off','Position',[0,0,7.5, 7.5/610*365], 'unit', 'inch');
for comp = 1:totalComp
    fprintf ('\tgenerating figures %d of %d\r', comp, totalComp);
	clf;
    
    % plot component map
    set (h, 'unit', 'inch');
    set (h, 'PaperPosition', [0, 0, 7.5, 7.5/610*365]); 
    set (gca, 'unit', 'normalized');
    set (gca, 'Position', [0, 0, 1,1]); 
    toshow = map4D(:,:,2:51,comp);
    toshow(isnan(toshow)) = 0;
    map2D = raicar_toMosaic(flipdim(toshow,2),10);
    figure (h);
    set (h, 'Visible', 'off');
	raicar_render (map2D, anat2D, threshold)
	fn = sprintf ('%s/map_AC%d.png', dirNm, comp);
	print (h, '-dpng', fn);

    % plot unthresholded component map
	clf;
    set (gcf, 'unit', 'inch');
    set (gcf, 'PaperPosition', [0, 0, 7.5, 7.5/610*365]); 
    set (gca, 'unit', 'normalized');
    set (gca, 'Position', [0, 0, 1,1]); 
    figure (h);
    set (h, 'Visible', 'off');
	raicar_render (map2D, anat2D, 0);
	fn = sprintf ('%s/map_AC_nothresh%d.png', dirNm, comp);
	print (h, '-dpng', fn);

    % plot subject load
    clf;
    set (gcf, 'unit', 'inch');
    set (gcf, 'PaperPosition', [0, 0, 3, 3]); 
    set (gca, 'Position', [0.2, 0.15, 0.75, 0.75]);
    figure (h);
    set (h, 'Visible', 'off');
    bar (obj.result.subjLoad(:,comp))
    xlabel ('Subject');
    ylabel ('Subject contribution');
    fn = sprintf ('%s/subjLoad_AC%d.png', dirNm, comp);
	print (h, '-dpng', fn);
   
    % plot significance of subject load
    clf;
    set (gcf, 'unit', 'inch');
    set (gcf, 'PaperPosition', [0, 0, 3, 3]); 
    set (gca, 'Position', [0.2, 0.15, 0.75, 0.75]);
    figure (h);
    set (h, 'Visible', 'off');
    bar (obj.result.sig_subjLoad(:,comp))
    xlabel ('Subject');
    ylabel ('Confidence of contribution');
    fn = sprintf ('%s/sig_subjLoad_AC%d.png', dirNm, comp);
	print (h, '-dpng', fn);
    
    % plot similarity matrix
    clf;
    set (gcf, 'unit', 'inch');
    set (gcf, 'PaperPosition', [0, 0, 4, 3]); 
%     set (gca, 'Position', [0.2, 0.1, 0.7, 0.85]);
    repMtx = obj.result.foundRepro{comp};
    repMtx = repMtx + repMtx';
    figure (h);
    set (h, 'Visible', 'off');
    imagesc(repMtx);colormap jet;colorbar;axis image
    set (gca, 'xtick', 1:obj.setup.subNum, 'ytick', 1:obj.setup.subNum);
    xlabel ('Subject');
    ylabel ('Subject');
    fn = sprintf ('%s/simMtx_AC%d.png', dirNm, comp);
	print (h, '-dpng', fn);
    
end
fprintf ('\tsuccess\n');

close (h);
	
