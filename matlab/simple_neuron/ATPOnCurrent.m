function [ATPuse] = ATPOnCurrent(currentTrace)

% currentTrace is any current trace in Amps (real synaptic input or current injected by dynamic clamp)
% Whole trace is integrated for total charge entry
% Divide by Na charge, divide by 3 ATPs, average over time --> ATPs/sec

%% Parameters
timeStep   = 0.05;
NaCharge   = 1.6022e-19; % (C) elementary charge of Na+

% Trace-dependent parameters
trainTime = length(currentTrace)*timeStep/1000; % sec

%% Calculate energy use
% Invert trace:
%currentTrace = -currentTrace;

% % Remove low-level noise:
% noiseThresh = std(currentTrace)*1; % anything smaller than 1 SD set to 0
% for k = 1:length(currentTrace);
%     if currentTrace(k) < noiseThresh
%         currentTrace(k) = 0;
%     end
% end
% Integrate trace:

integral    = sum(currentTrace)*timeStep;   % A*ms
totalChargeEntry = integral*1e-3;           % C (A*S)
chargeEntry = totalChargeEntry/trainTime;   % average charge entry per sec

% Calculate no Na+ ions:
NaEntry = chargeEntry/NaCharge;             % average Na entry per sec

% Calculate no ATP molecules needed:
ATPuse  = NaEntry/3;                        % average ATP use per sec

%% OPTIONAL
% % Integrate trace in portions to look at EPSC rundown over time:
% stepInts = [];
% for l = 1:100000:2500000
%     int = sum(currentTrace(l:l+100000-1));
%     stepInts = cat(1,stepInts,int);
% end
% figure; plot(stepInts);
% [r,p] = corr(stepInts,[1:25]');
% txstr(1) = {['\bf' dateDirectory ' ' cellDirectory '\rm']};
% txstr(2) = {['r = ' num2str(r)]};
% txstr(3) = {['p = ' num2str(p)]};
% title(txstr);
% xlabel('trains 1-25 in sequence');
% ylabel('average charge entry per train');

