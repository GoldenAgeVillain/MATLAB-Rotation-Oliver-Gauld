global nreps

nreps = 50;

gsyn_scale_factors = [0,1,5,10,20,40,50];
noise_scale_factors = [0,0.5,1,1.5];

%% run simulations to generate data

for pp = 4:length(noise_scale_factors)
    noise_scaler = noise_scale_factors(pp);
    
    for p = 1:length(gsyn_scale_factors)
        gsyn_scaler = gsyn_scale_factors(p);

        for i = 1:nreps   
            
            [data, data_AP, APfreq, current,spiketrain, gsyn, gNa_synapse, gNa_wholecell, gNoise, gTotal, SynNaCurr, wholecell_Na_current] = neuron_model(0,noise_scaler,gsyn_scaler);

            data_store{i,1} = data_AP; % membrane voltage trace with APs
            data_store{i,2} = data;% membrane voltage trace without APs
            data_store{i,3} = APfreq; % Action potential Frequency in Hz
            data_store{i,4} = spiketrain; % input spike train, 
            data_store{i,5} = energy_calc(SynNaCurr,data_store{i,3}); % calculate ATP used on synaptic Na current and APs
            data_store{i,6} = noise_scaler; % noise scale factor
            data_store{i,7} = gsyn_scaler; % gsyn scale factor           
            data_store{i,8} = gsyn;           
            data_store{i,9} = gNa_synapse;  
            data_store{i,10} = gNa_wholecell; 
            data_store{i,11} = gNoise;        
            data_store{i,12} = gTotal;        
            data_store{i,13} = SynNaCurr; 
            data_store{i,14} = wholecell_Na_current;        
            data_store{i,15} = syntotalcurrent;               
        end
        
        %% save data array
        mkdir(['output/new_noise_model300315/noisescale_' num2str(noise_scaler)])
        fname1 = ['output/new_noise_model300315/noisescale_' num2str(noise_scaler) '/gsyn_' num2str(gsyn_scaler) '.mat'];
        save(fname1,'data_store');

        %% calculate and save MI and energy parameters
        AverageEnergyRate = mean(horzcat(data_store{:,5})); %averages energy per second across all repetitions

        [MI, Htotal, final_Hnoise] = MI_calculation(data_store(:,1),5); % calulates Mutual Info

        MI_energy_params = [MI, Htotal, final_Hnoise, AverageEnergyRate]; % all units in rate per sec
        fname2 = ['output/new_noise_model300315/noisescale_' num2str(noise_scaler) '/gsyn_' num2str(gsyn_scaler) '_SummaryParams.mat'];
        save(fname2,'MI_energy_params');
        
    end
end
