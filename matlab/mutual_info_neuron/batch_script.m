global nreps my_path my_path2

nreps = 50; % number of stimulus repetitions

gsyn_scale_factors = [0,1,5,10,20,40,50,55,75,100]; % to scale the synaptic conductance
noise_scale_factors = [0,0.5,1,1.25,1.5,2]; % to scale the background noise

%batch simulations to generate data
for noiseCounter = 1:length(noise_scale_factors)
    
    noise_scaler = noise_scale_factors(noiseCounter);
    
    for gsynCounter = 1:length(gsyn_scale_factors)          
        
        data_store = cell(nreps,16); % preallocate memory
        gsyn_scaler = gsyn_scale_factors(gsynCounter);

        % directory and file paths
        basepath = 'Z:\Oliver\attwell_rotation\matlab\mutual_info_neuron\output\';
        
        if exist(basepath,'dir')==0 % checks what machine you're on
            basepath = '/Users/olivergauld/Desktop/present/UCL/R2/attwell_rotation/matlab/mutual_info_neuron/output';
        end
        
        datafolder = [num2str(nreps) 'Reps\noisescale_' num2str(noise_scaler) '\'];
        RawDatafilename = ['RawData_gsyn_' num2str(gsyn_scaler) 'reps' num2str(nreps) '.mat'];
        SummaryFile = [ '/gsyn_' num2str(gsyn_scaler) 'reps' num2str(nreps) '_SummaryParams.mat'];
        
        my_path = [basepath datafolder RawDatafilename];
        my_path2 = [basepath datafolder SummaryFile];

        if exist([basepath datafolder],'dir') == 0
           mkdir([basepath datafolder]) 
        end
        
        %% if raw data doesnt exist, run the model to generate data
        if exist(my_path, 'file') == 0           
            for my_rep = 1:nreps   
                
                
                %% run the model
                [data, data_AP, APfreq, Injectedcurrent,...
                    spiketrain, gsyn, gNa_synapse, gNa_wholecell, ...
                    gNoise, gTotal, SynapticNaCurrent, ...
                    wholecell_Na_current] = neuron_model(0,noise_scaler,gsyn_scaler);

                % storing lots of variables
                data_store{my_rep,1} = data_AP; % membrane voltage trace with APs
                data_store{my_rep,2} = data;% membrane voltage trace without APs
                data_store{my_rep,3} = APfreq; % Action potential Frequency in Hz
                data_store{my_rep,4} = spiketrain; % input spike train, 

                %% calls energy calc function
                [TotalATP, NaATP, AP_ATP] = energy_calc(SynapticNaCurrent,data_store{my_rep,3});

                data_store{my_rep,5} = NaATP; % calculate ATP used on synaptic Na current and APs
                data_store{my_rep,6} = noise_scaler; % noise scale factor
                data_store{my_rep,7} = gsyn_scaler; % gsyn scale factor           
                data_store{my_rep,8} = gsyn;           
                data_store{my_rep,9} = gNa_synapse;  
                data_store{my_rep,10} = gNa_wholecell; 
                data_store{my_rep,11} = gNoise;        
                data_store{my_rep,12} = gTotal;        
                data_store{my_rep,13} = SynapticNaCurrent; 
                data_store{my_rep,14} = wholecell_Na_current;  
                data_store{my_rep,15} = TotalATP; 
                data_store{my_rep,16} = AP_ATP;              
                
            end 
        
            save(my_path,'data_store');
        end
                
        %% calculate Mutual Information if needed
        if exist(my_path2, 'file') == 0
            AverageCurrentEnergyRate = mean(horzcat(data_store{:,5})); %averages energy per second across all repetitions
            
            [MI, Htotal, final_Hnoise] = MI_calculation(data_store(:,1),5); % calulates Mutual Info
            MI_energy_params = [MI, Htotal, final_Hnoise, AverageCurrentEnergyRate]; % all units in rate per sec
            
            save(my_path2,'MI_energy_params');  

        end
        clear data_store

    end  
end


