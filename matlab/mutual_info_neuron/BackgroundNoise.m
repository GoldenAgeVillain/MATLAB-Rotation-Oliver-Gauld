function [Excitatory_cond,Inhib_cond] = BackgroundNoise(num_syn,num_Inhib_syn)

    % What am I doing?
    % simulating noise input into the model, by modelling background
    % synaptic activity (excitatory and inhibitory synapses)
    % using parameters from London 2002.
    % they use 400 excitatory synapses EACH with firing rate of 10Hz, gSyn
    % max = 2nS, time to rise = 0.5ms. And 100 Inhibitory synapses each
    % with a firing rate of 65Hz, gSyn max = 5nS, time to rise = 0.75ms
    DT = 1000;
    dt = 0.5; % [ms]
    bins_per_sec = 1000 * (1/dt);

    if num_syn ~= 0 
    for synloop = 1:num_syn
        ii=1;
        for i = 1:1

            % make random spike train
            spikeTrainRaw = rand((bins_per_sec * (DT/1000)),1); % random numbers between 0 and 1
      %      spikeTrainRaw(1:6) = 1; % set to 1 avoids APs in first 3ms of sequence
            spikeFreq = 10; %[Hz]

            % probability of spike in time step 0.05ms
            prob = (spikeFreq / 1000) * dt; 
            spikeTrainRaw = double(spikeTrainRaw < prob); %threshold

            % this ensures spikes are at least 3ms (6*0.05ms) away from each other
            % and ensures there are the specified frequency/number of spikes
            while any(diff(find(spikeTrainRaw == 1)) <= 6)  || ((length(find(spikeTrainRaw==1)))~=spikeFreq)
                spikeTrainRaw = rand((bins_per_sec * (DT/1000)),1); % random numbers between 0 and 1
            %    spikeTrainRaw(1:6) = 1; 
                prob = (spikeFreq / 1000) * dt; 
                spikeTrainRaw = double(spikeTrainRaw < prob); %threshold
            end 

            spiketrain(ii:i*length(spikeTrainRaw),1) = spikeTrainRaw;
            ii = ii + length(spikeTrainRaw);

        end

        tmax=20; % [ms]
        t=0:dt:tmax;
        tau=0.5; % [ms] Renaud uses 2.5 for tau in the past, but this time constant is modelled differently h
        ts=1;
        tr=t(round(ts):length(t));

        % Alpha function
        galpha=zeros(size(t));
        gamplitude = 2; % [nS]
        galpha(round(ts):length(t))=gamplitude.*(tr/tau).*exp(1-(tr/tau));

        epsp = galpha;
        gsyn = conv(spiketrain,epsp); % convolve spike train with epsp

        excitatory_synapses(synloop,:)=gsyn';
        clear spiketrain
    clear synloop

    end


    for i = 1:length(excitatory_synapses)
        Excitatory_cond(i) = sum(excitatory_synapses(:,i));
    end

    else
        Excitatory_cond = zeros(1,2001)
    end

    if num_Inhib_syn ~= 0
        for synloop = 1:num_Inhib_syn
        ii=1;

            for i = 1:1

                % make random spike train
                spikeTrainRaw = rand((bins_per_sec * (DT/1000)),1); % random numbers between 0 and 1
                spikeTrainRaw(1:6) = 1; % set to 1 avoids APs in first 3ms of sequence
                spikeFreq = 65; %[Hz]

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

            tmax=20; % [ms]
            t=0:dt:tmax;
            tau=0.75; % [ms] Renaud uses 2.5 for tau in the past, but this time constant is modelled differently h
            ts=1;
            tr=t(round(ts):length(t));

            % Alpha function
            galpha=zeros(size(t));
            gamplitude = 5; % [nS]
            galpha(round(ts):length(t))=gamplitude.*(tr/tau).*exp(1-(tr/tau));

            epsp = galpha;

            gsynInhib = conv(spiketrain,epsp); % convolve spike train with epsp
            %gsynInhib(length(gsynInhib)-14:length(gsynInhib))=[]; % this is needed to make sure vector is correct length




        Inhibitory_synapses(synloop,:)=gsynInhib';
        clear spiketrain

        end


        for i = 1:length(Inhibitory_synapses)
        Inhib_cond(i) = sum(Inhibitory_synapses(:,i));
        end

    else
        Inhib_cond = zeros(size(Excitatory_cond));
end