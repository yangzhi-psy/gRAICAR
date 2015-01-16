function gRAICAR_run (settings)

[pass, settings] = gRAICAR_check_settings (settings);

if pass == 1
    % start step 1

    [status, exeption] = gRAICAR_step1(settings);
    if status == 0  % check error
       rethrow (exeption);
    end

    % start step 2
    [status, exeption] = gRAICAR_step2(settings);
    if status == 0
        rethrow (exeption);
    end

    % start step 3
    [status, exeption] = gRAICAR_step3(settings);
    if status == 0
        rethrow (exeption);
    end
else
    
    fprintf ('\n-------------------------\n');
    fprintf (' Input check failed \n');
    fprintf ('-------------------------\n');
end