function [spiketrain, spikeTrain1Sec, countTotal, count1sec, epsp, gsyn] = rand_spike_train();

    global DT dt

    DT = 1000;        % [ms]
    dt = 0.05;        % [ms]
    bins_per_sec = 1000 * (1/dt);

<<<<<<< HEAD
    % make random spike train
    spikeTrainRaw   =  rand((bins_per_sec * (DT/1000) + 1),1);
=======
% bins, in seconds
dt = 0.5;        % [ms]
bins_per_sec = 1000 * (1/dt);

ii=1;

for i = 1:10
    
    % make random spike train
    spikeTrainRaw   =  rand((bins_per_sec * (DT/1000)),1); % random numbers between 0 and 1
    spikeTrainRaw(1:6) = 1; % set to 1 avoids APs in first 3ms of sequence
>>>>>>> 7827065f008a28a348d067396df6029a36f3c1a7
    spikeFreq       =  20; %[Hz]

    % probability of spike in time step 0.05ms
    prob = (spikeFreq / 1000) * dt;                                                
    spikeTrainRaw   =  double(spikeTrainRaw < prob); %threshold
<<<<<<< HEAD
=======

    % this ensures spikes are at least 3ms (6*0.05ms) away from each other
    while any(diff(find(spikeTrainRaw == 1)) <= 6) 
        % make random spike train
        spikeTrainRaw   =  rand((bins_per_sec * (DT/1000)),1); % random numbers between 0 and 1
        spikeTrainRaw(1:6) = 1; 

        % probability of spike in time bin 0.05ms
        prob = (spikeFreq / 1000) * dt;                                                
        spikeTrainRaw   =  double(spikeTrainRaw < prob); %threshold
    end    
    spiketrain(ii:i*length(spikeTrainRaw),1) = spikeTrainRaw;
    ii = ii + length(spikeTrainRaw);
end
spikeTrain1Sec  =  spikeTrainRaw(1:bins_per_sec);                
>>>>>>> 7827065f008a28a348d067396df6029a36f3c1a7

    % this ensures spikes are at least 3ms (60*0.05ms) away from each other
    while any(diff(find(spikeTrainRaw == 1)) <= 60) 
        % make random spike train
        spikeTrainRaw   =  rand((bins_per_sec * (DT/1000) + 1),1); % random numbers between 0 and 1

<<<<<<< HEAD
        spikeTrainRaw   =  double(spikeTrainRaw < prob); %threshold
    end    

    spikeTrain1Sec  =  spikeTrainRaw(1:bins_per_sec);                

    % count spikes
    countTotal      =  length(spikeTrainRaw(spikeTrainRaw==1))  ;
    count1sec       =  length(spikeTrain1Sec(spikeTrain1Sec==1));


    %% parameters for epsc 
    tau = 1 /0.05;                    %[ms]Tdecay
    epsp_cond_max = 2;                %[nS] peak conductance
    epsp_duration = 4;                %[ms]
    wave_length = (epsp_duration)/dt; % defines length of the epsp in terms of number of 'dt' timesteps
    t = 0:dt:epsp_duration;              %[ms]
% %     epsp1 = epsp_cond_max*exp(-t/tau); % exponential decay function 
% %   epsp = [0 0.5 1 1.5 2 epsp1];

    epsp = ((2*t)./1).*exp(-t./1);
    
    gsyn = conv(spikeTrainRaw,epsp,'same'); % convolve spike train with epsp
    plot((dt:dt:(bins_per_sec*dt)),gsyn(1:bins_per_sec))
    ylim([0 3]);
=======
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
%plot((dt:dt:(bins_per_sec*dt)),gsyn(1:bins_per_sec))
%ylim([0 gamplitude]);
>>>>>>> 7827065f008a28a348d067396df6029a36f3c1a7

end
