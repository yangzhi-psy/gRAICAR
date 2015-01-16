function [RC_start, RC_end] = getRCRange (trialTab, block_start, block_end)

% function getBlockRange (block_start, block_end)
% converts block index into component(RC) index in MICM 
% trialTab: table containing subject index, realization (trial) index, and number of ICs for the RCs, see obj.result.trialTab
% block_start and block_end: start and end of the block range
% RC_start and RC_end: start and end of the RC index
       RC_start = sum (trialTab(1:block_start-1, 3))+1;
       RC_end = sum (trialTab(1:block_end, 3));

