global nreps

nreps = 500;

gsyn_scale_factors = [0,1,5,10,20,40,50,55,75,100];
noise_scale_factors = 1;%[0,0.5,1,1.25,1.5,2];

Excitatory_synapses = 160
Inhibitory_synapses = 0

%% batch simulations to generate data

for pp = 1:length(Excitatory_synapses)
    ExSyns = Excitatory_synapses(pp);
    
    for p = 1:1;%length(gsyn_scale_factors)
        gsyn_scaler = gsyn_scale_factors(p);

        for i = 1:nreps   
            
           % old one [data, data_AP, APfreq, current,spiketrain, gsyn, gNa_synapse, gNa_wholecell, gNoise, gTotal, SynNaCurr, wholecell_Na_current] = neuron_model(0,noise_scaler,gsyn_scaler);

            [data, data_AP, APfreq, iInj_plot,spiketrain, gsyn, gNa_synapse, gNa_wholecell, totalcond, gTotal, Synaptic_Na_current,wholecell_Na_current] = London_neuron_model(0,1,0,i);
            
            data_store{i,1} = data_AP; % membrane voltage trace with APs
            data_store{i,2} = data;% membrane voltage trace without APs
            data_store{i,3} = APfreq; % Action potential Frequency in Hz
            data_store{i,4} = spiketrain; % input spike train, 
            
            %% calls energy calc function
            [TotalATP, NaATP, AP_ATP] = energy_calc(Synaptic_Na_current,data_store{i,3});
            
            data_store{i,5} = NaATP; % calculate ATP used on synaptic Na current and APs
            data_store{i,6} = ExSyns; % noise scale factor
            data_store{i,7} = gsyn_scaler; % gsyn scale factor           
            data_store{i,8} = gsyn;           
            data_store{i,9} = gNa_synapse;  
            data_store{i,10} = gNa_wholecell; 
            data_store{i,11} = totalcond;        
            data_store{i,12} = gTotal;        
            data_store{i,13} = Synaptic_Na_current; 
            data_store{i,14} = wholecell_Na_current;  
            data_store{i,15} = TotalATP; 
            data_store{i,16} = AP_ATP;              
        end
        
        %% save data array
        mkdir(['TESToutput4/repetitions/noisescale_' num2str(ExSyns)])
        fname1 = ['TESToutput4/repetitions/noisescale_' num2str(ExSyns) '/gsyn_' num2str(gsyn_scaler) 'reps' num2str(nreps) '.mat'];
        save(fname1,'data_store');

        %% calculate and save MI and energy parameters
        AverageEnergyRate = mean(horzcat(data_store{:,5})); %averages energy per second across all repetitions

        [MI, Htotal, final_Hnoise] = MI_calculation(data_store(:,1),5); % calulates Mutual Info

        MI_energy_params = [MI, Htotal, final_Hnoise, AverageEnergyRate]; % all units in rate per sec
        fname2 = ['TESToutput4/repetitions/noisescale_' num2str(ExSyns) '/gsyn_' num2str(gsyn_scaler) 'reps' num2str(nreps) '_SummaryParams.mat'];
        save(fname2,'MI_energy_params');
        
    end
end

