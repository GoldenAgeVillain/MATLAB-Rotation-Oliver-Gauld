function [spikeTrainRaw, spikeTrain1Sec, countTotal, count1sec, epsp, gsyn] = rand_spike_train();

global DT dt

DT = 10000; %[ms]

% bins, in seconds
dt = 0.05;        % [ms]
bins_per_sec = 1000 * (1/dt); 

% make random spike train
spikeTrainRaw   =  rand((bins_per_sec * (DT/1000) + 1),1); % random numbers between 0 and 1

spikeFreq       =  20; %[Hz]

% probability of getting spike in time bin 0.05ms
prob = (spikeFreq / 1000) * dt;                                                
spikeTrainRaw   =  double(spikeTrainRaw < prob); %threshold

% plot total
%figure;plot(spikeTrainRaw);

% plot 1st second
spikeTrain1Sec  =  spikeTrainRaw(1:bins_per_sec);                
%figure;plot(spikeTrain1Sec) 

% count spikes
countTotal      =  length(spikeTrainRaw(spikeTrainRaw==1))  ;
count1sec       =  length(spikeTrain1Sec(spikeTrain1Sec==1));


%% parameters for epsc 
tau = 10;                   %[ms]
epsc_amp = 0.4;             %[nA]
epsc_duration = 2;         %[ms]
wave_length = (epsc_duration/1000)/dt; % defines length of the epsp in terms of number of 'dt' timesteps
t = 0:wave_length;          %[ms]
epsp = epsc_amp*exp(-t/tau);% exponential decay function

gsyn = conv(spikeTrainRaw,epsp,'same'); % convolve spike train with epsp
plot((dt:dt:(bins_per_sec*dt)),gsyn(1:bins_per_sec))
ylim([0 3]);

end