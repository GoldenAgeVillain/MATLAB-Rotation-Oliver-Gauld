function [spiketrain, gsyn] = rand_spike_train();

global DT dt

DT = 1000; %[ms]
dt = 0.5; % [ms]
bins_per_sec = 1000 * (1/dt);

ii=1;

for i = 1:10

    % make random spike train
    spikeTrainRaw = rand((bins_per_sec * (DT/1000)),1); % random numbers between 0 and 1
    spikeTrainRaw(1:6) = 1; % set to 1 avoids APs in first 3ms of sequence
    spikeFreq = 20; %[Hz]

    % probability of spike in time step 0.05ms
    prob = (spikeFreq / 1000) * dt; 
    spikeTrainRaw = double(spikeTrainRaw < prob); %threshold

    % this ensures spikes are at least 3ms (6*0.05ms) away from each other

    while any(diff(find(spikeTrainRaw == 1)) <= 6) 
        % make random spike train
        spikeTrainRaw = rand((bins_per_sec * (DT/1000)),1); % random numbers between 0 and 1
        spikeTrainRaw(1:6) = 1; 
        % probability of spike in time bin 0.05ms
        prob = (spikeFreq / 1000) * dt; 
        spikeTrainRaw = double(spikeTrainRaw < prob); %threshold
    end 

    spiketrain(ii:i*length(spikeTrainRaw),1) = spikeTrainRaw;
    ii = ii + length(spikeTrainRaw);
    
end

%% parameters for epsc 

tmax=8; % [ms]
t=0:dt:tmax;
tau=0.5; % [ms] Renaud uses 2.5 for tau in the past, but this time constant is modelled differently h
ts=1;
tr=t(round(ts):length(t));

% Alpha function
galpha=zeros(size(t));
galp=tau/exp(1);
gamplitude = 2; % [nS]
galpha(round(ts):length(t))=gamplitude.*tr.*exp(-tr/tau)/galp;

epsp = galpha;

gsyn = conv(spiketrain,epsp); % convolve spike train with epsp
gsyn(length(gsyn)-14:length(gsyn))=[]; % this is needed to make sure vector is correct length

end