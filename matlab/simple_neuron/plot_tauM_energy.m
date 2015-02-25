function [] = plot_tauM_energy()

parameters_simple_neuron;

cmap = hsv(8);% create random plot colour
plot_counter = 1;
for myvar = 1:2 % switches between tau and threshold variables
    if myvar == 1
        selector = tm;
%        scaling = [0.6 0.7 0.8 0.85 0.9 1 1.1 1.2 1.4 1.8 2.2 2.5 3 3.1 3.3 3.5];%% for tauM varies input conductance 

        scaling = [0.6 0.7 0.8 0.85 0.875 0.9 0.95 1 1.1 1.2 1.4 1.8 2.2 2.5 3 3.1 3.3 3.5];%2.2 is new    
    elseif myvar ==2
        scaling = [0.2 0.4 0.45 0.5 0.7 0.8 0.815 0.82 0.8225 0.825 0.84 0.85 0.875 0.9 1 1.1 1.2 1.3 1.4 1.6 1.8 2 2.25 2.3 2.35 2.5 3 4 5 7 9]; % for Vthresh varies input conductance
        selector = thresholds;
        dist_from_threshold = abs(-70.-(thresholds));% this is jsut used as x-axis scale for one of the plots
    elseif myvar ==3
        %% Rm
        selector = Rm;
        scaling = [0.6 0.7 0.8 0.85 0.875 0.9 0.95 1 1.1 1.2 1.4 1.8 2.2 2.5 3 3.1 3.3 3.5];%2.2 is new    

    end
      
    for myplot = 1:4 % for each of the 4 plots per variable
        for x = 1:length(selector)
            xx = selector(x)

            if myvar == 1
                load(['output/simulation_results/largescalerange/tm' num2str(xx) '.mat']);% load file
            elseif myvar ==2
                load(['output/simulation_results/largescalerange/Vthresh' num2str(xx) '.mat']);% load file
            elseif myvar ==3
                load(['output/simulation_results/largescalerange/Rm' num2str(xx) '.mat']);% load file
            end

            for i = 1:length(scaling)
                s = (data{i,1}{1,4} / DT) * time_bin; % [deltaT] calulates probability of 's' given mean firing rate
                if s >= 1
                    H(i) = 0; % in the event that frequency is >= 333Hz i.e. probality of AP occuring in DeltaT
                else
                    H(i) = -s*log2(s)-(1-s)*log2(1-s); % bits per deltaT
                end
                energy(i) = (data{i,5}); % [deltaT]
                H(isnan(H))=0;
                energy(isnan(energy))=0;
                entropy_rate(i) = H(i) * (DT/time_bin); % bits per second
                freq(i) = data{i}{1,4}; % x-axis
            end
            
            energy(freq>333)=[];
            entropy_rate(freq>333)=[];
            H(freq>333)=[];
            freq(freq>333)=[];

            hold on
            subplot(2,4,plot_counter)
            if myplot ==1
                plot(freq,(energy),'Color',cmap(x,:))
                hold on 
            elseif myplot ==2
                plot(freq,(entropy_rate),'Color',cmap(x,:))
                xlim([0 333])
                hold on    
            elseif myplot ==3
                plot(freq,(entropy_rate./energy),'Color',cmap(x,:))
                hold on 
                xlim([0 333])
                optimum_freq(x) = freq(find((entropy_rate./energy)==max(entropy_rate./energy)));
            elseif myplot == 4
                hold on
      
                    f = fit(selector',optimum_freq','exp1');                   
                    plot(f,selector,optimum_freq)    
                ylim([10 90])
            end
    
        end
        % only need legend for plots 1,2,3,5,6,7
        if myplot < 4
            if myvar ==1
                Legend=cell(length(selector),1);
                for i = 1:(length(selector))
                   Legend{i} =  strcat('tauM',  num2str(selector(i)), 'ms') ;
                end
            else 
                Legend=cell(length(selector),1);
                for i = 1:(length(selector))
                   Legend{i} =  strcat('Vthresh', num2str(selector(i)),'mV') ;
                end
            end
            legend(Legend)
        end
    lblY     = {'Energy [ATP]','Entropy rate [H/seconds]','Entropy rate / Energy use','Frequency [Hz]'};
    lblX     = {'Frequency [Hz]','Frequency [Hz]','Frequency [Hz]','Tau [ms]';'Frequency [Hz]','Frequency [Hz]','Frequency [Hz]','AP threshold [mV]'};    
    Title    = {'Energy use, Vthresh == -50mv','Entropy Rate, Vthresh == -50mv' ...
        ,'Efficiency, Vthresh == -50mv','Peak efficieny. vs tau','Energy, Tau == 30ms','Entropy Rate, Tau == 30ms' ...
        ,'Efficiency, Tau == 30ms','Peak efficiency vs. AP threshold'};
    ylabel(lblY(myplot)); xlabel(lblX(myvar,myplot));
    title(Title(plot_counter))
    plot_counter = plot_counter + 1;
    end
    clear optimum_freq
end
end
