global nreps

nreps = 50;

gsyn_scale_factors = [1,5,10,15,20];
noise_scale_factors = [0.5,1,1.5,2];

%% run simulations to generate data

for pp = 4:length(noise_scale_factors)
    noise_scaler = noise_scale_factors(pp);
    
    for p = 1:length(gsyn_scale_factors)
        gsyn_scaler = gsyn_scale_factors(p);

        fname1 = ['output/noise_' num2str(noise_scaler) '/gsyn_' num2str(gsyn_scaler) '.mat'];
        load(fname1);

        %% calculate and save MI and energy parameters
        AverageEnergyRate = mean(horzcat(data_store{:,5})); %takes mean energypersecond across all repetitions
        [MI, Htotal, final_Hnoise] = MI_calculation(data_store(:,1),data_store{1,4}); % calulates Mutual Info
        MI_energy_params = [MI, Htotal, final_Hnoise, AverageEnergyRate]; % all units in rate per sec
        fname2 = ['output/noise_' num2str(noise_scaler) '/gsyn_' num2str(gsyn_scaler) 'MIandEnergySummaryParams.mat'];
        save(fname2,'MI_energy_params');
    end
end
