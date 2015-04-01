global nreps

nreps = 50;

gsyn_scale_factors = [1,5,10,15,20,25,30];
noise_scale_factors = [1,1.125,1.25];

%% run simulations to generate data

for pp = 1:length(noise_scale_factors)
    noise_scaler = noise_scale_factors(pp);
    
    for p = 1:length(gsyn_scale_factors)
        gsyn_scaler = gsyn_scale_factors(p);

        for i = 1:nreps   
            
            [data, data_AP, APfreq, iInj_plot,spiketrain, gsyn] = neuron_model(1,noise_scaler,gsyn_scaler);

            data_store{i,1} = data_AP; % membrane voltage trace with APs
            data_store{i,2} = data;% membrane voltage trace without APs
            data_store{i,3} = APfreq; % Action potential Frequency in Hz
            data_store{i,4} = spiketrain; % input spike train, 
            data_store{i,5} = energy_calc(iInj_plot,data_store{i,3}); % calculate ATP used on current and APs
            data_store{i,6} = noise_scaler; % noise scale factor
            data_store{i,7} = gsyn_scaler; % gsyn scale factor           
            
        end
        
        %% save data array
        mkdir(['output/new_noise_model/noisescale_' num2str(noise_scaler)])
        fname1 = ['output/new_noise_model/noisescale_' num2str(noise_scaler) '/gsyn_' num2str(gsyn_scaler) '.mat'];
        save(fname1,'data_store');

        %% calculate and save MI and energy parameters
        AverageEnergyRate = mean(horzcat(data_store{:,5})); %takes mean energypersecond across all repetitions
        [MI, Htotal, final_Hnoise] = MI_calculation(data_store(:,1)); % calulates Mutual Info
        MI_energy_params = [MI, Htotal, final_Hnoise, AverageEnergyRate]; % all units in rate per sec
        fname2 = ['output/new_noise_model/noisescale_' num2str(noise_scaler) '/gsyn_' num2str(gsyn_scaler) '_SummaryParams.mat'];
        save(fname2,'MI_energy_params');
    end
end
