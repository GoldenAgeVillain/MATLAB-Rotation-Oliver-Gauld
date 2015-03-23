function [spikeTrainRaw, spikeTrain1Sec, countTotal, count1sec, epsp, gsyn] = rand_spike_train();

    global DT dt

    DT = 1000;        % [ms]
    dt = 0.05;        % [ms]
    bins_per_sec = 1000 * (1/dt);

    % make random spike train
    spikeTrainRaw   =  rand((bins_per_sec * (DT/1000) + 1),1);
    spikeFreq       =  20; %[Hz]

    % probability of spike in time bin 0.05ms
    prob = (spikeFreq / 1000) * dt;                                                
    spikeTrainRaw   =  double(spikeTrainRaw < prob); %threshold

    % this ensures spikes are at least 3ms (60*0.05ms) away from each other
    while any(diff(find(spikeTrainRaw == 1)) <= 60) 
        % make random spike train
        spikeTrainRaw   =  rand((bins_per_sec * (DT/1000) + 1),1); % random numbers between 0 and 1

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

end
