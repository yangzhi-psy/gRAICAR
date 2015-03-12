function gRAICAR_distrCompNMI (inPrefix, cuefile)

% example usage
% gRAICAR_distrCompNMI ('/data0/yangz/nki_lifespan/gRAICAR_30_40/task','/data0/yangz/nki_lifespan/gRAICAR_30_40/progress.log');

inFn = sprintf ('%s_configFile.mat', inPrefix);
load (inFn);

step = obj.setup.step;
% read the progress
cont = 1;
while cont == 1
go = 0;
    while go == 0
        try
            cue = load (cuefile, '-ascii');  % cue is the current ptr
            ptr = cue;
            cue = ptr+step;
            % update progress file
            save (cuefile, 'cue', '-ascii');
            go = 1;
        catch
            fprintf ('warning: reading progress file failed!\n');
        end
    end
   
    % computation
    % determine the length of the loop
    cont = coreCompNMI (obj, ptr);
end

% update computing core log
PATHSTR = fileparts(cuefile);
fn = fullfile (PATHSTR, 'distComp.log');
prog = load (fn, '-ascii'); 
prog = prog+1;
save (fn, 'prog', '-ascii');
