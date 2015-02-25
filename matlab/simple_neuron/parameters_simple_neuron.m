tm = [10 15 20 25 30 35 40];
Rmem = [40 50 60 70 80 90 100];
thresholds = [-60 -55 -50 -45 -40 -35];

%scaling = [0.6 0.7 0.8 0.85 0.875 0.9 0.95 1 1.1 1.2 1.4 1.8 2.2 2.5 3 3.1 3.3 3.5];%tauM
scaling = [0.6 0.7 0.8 0.85 0.875 0.9 0.95 1 1.1 1.2 1.4 1.8 2.2 2.5 3 3.1 3.3 3.5];%Rm
        
%scaling = [0.2 0.4 0.45 0.5 0.7 0.8 0.815 0.82 0.8225 0.825 0.84 0.85 0.875 0.9 1 1.1 1.2 1.3 1.4 1.6 1.8 2 2.25 2.3 2.35 2.5 3 4 5 7 9]; % for Vthresh varies input conductance

time_bin = 3; % ms

DT = 1000;
dt = 0.05;

%% membrane parameters
EL = -70;           % [mV]
EAMPA = 0;          % [mV]
Vthresh = -50;      % AP threshold [mV]
tauM = 30;          % membrane time constant [ms]
%Rm=90;              % total membrane resistance [Mega Ohms]
Vspike = 20;        % AP spike value [mV]
s0 = EL;            % membrane potential at t=0 (resting potential) [mV]
