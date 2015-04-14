global nreps

nreps = 500;

gsyn_scale_factors = [30,20,10, 0,1,5,40,50,55,75,100];

Excitatory_synapses = [200 160 120 0 240 280 ];
Inhibitory_synapses = 0;

%% batch simulations to generate data

for pp = 1:length(Excitatory_synapses)
    ExSyns = Excitatory_synapses(pp);
    
    for p = 1:length(gsyn_scale_factors)
        gsyn_scaler = gsyn_scale_factors(p);
       
        % directory and file paths
        basepath = 'Z:\Oliver\attwell_rotation\matlab\mutual_info_neuron\output\';
        
        if exist(basepath,'dir')==0 % checks what machine you're on
            basepath = '/Users/olivergauld/Desktop/present/UCL/R2/attwell_rotation/matlab/mutual_info_neuron/output';
        end
        
        datafolder = ['/London_model2/' num2str(nreps) 'reps/ExSyn_num' num2str(ExSyns) '/'];
        RawDatafilename = ['RawData_gsyn_' num2str(gsyn_scaler) 'reps' num2str(nreps) '.mat'];
        SummaryFile = ['gsyn_' num2str(gsyn_scaler) 'reps' num2str(nreps) '_SummaryParams.mat'];
    
        my_path = [basepath datafolder RawDatafilename];
        my_path2 = [basepath datafolder SummaryFile];

        if exist([basepath datafolder],'dir') == 0
           mkdir([basepath datafolder]) 
        end
        
           %% if raw data doesnt exist, run the model to generate data
        if exist(my_path, 'file') == 0  
        for i = 1:nreps   
            
            [data, data_AP, APfreq, iInj_plot,spiketrain,...
                gsyn, gNa_synapse, gNa_wholecell, totalcond,...
                gTotal, Synaptic_Na_current,wholecell_Na_current] = London_neuron_model(1,ExSyns,gsyn_scaler,i);
            
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
                    save(my_path,'data_store');

        end
             
        %% calculate Mutual Information if needed
        if exist(my_path2, 'file') == 0
            AverageCurrentEnergyRate = mean(horzcat(data_store{:,5})); %averages energy per second across all repetitions
            
            [MI, Htotal, final_Hnoise] = MI_calculation(data_store(:,1),5); % calulates Mutual Info
            MI_energy_params = [MI, Htotal, final_Hnoise, AverageCurrentEnergyRate]; % all units in rate per sec
            
            save(my_path2,'MI_energy_params');  

        end
    end
end

