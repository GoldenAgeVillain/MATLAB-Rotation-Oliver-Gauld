% this loads MI and energy data generated by the batch script and makes plots 

gsyn_scale_factors = [1,5,10,15,20,25,30,50,70,90, 100];
noise_scale_factors = [1,1.125,1.25];

for pp = 1:length(noise_scale_factors)
    noise_scaler = noise_scale_factors(pp);
    
    for p = 1:length(gsyn_scale_factors)
        gsyn_scaler = gsyn_scale_factors(p);
   
        fname2 = ['output/new_noise_model/noisescale_' num2str(noise_scaler) '/gsyn_' num2str(gsyn_scaler) '_SummaryParams.mat'];
        load(fname2);

        MI_data(pp,p) = MI_energy_params(1); 
        Energy_data(pp,p)= MI_energy_params(4);
        Hnoise_data(pp,p) = MI_energy_params(3);
        Htotal_data(pp,p) = MI_energy_params(2);

        fname1 = ['output/new_noise_model/noisescale_' num2str(noise_scaler) '/gsyn_' num2str(gsyn_scaler) '.mat'];
        load(fname1)
        
        mean_freq_Hz(pp,p) = mean(horzcat(data_store{:,3}));
        
        
    end
end

EnergyEfficiency = MI_data ./ Energy_data;

xaxis = 2.*gsyn_scale_factors; % to get x axis ticks, 2 = original amplitude of EPSConductance wave
cc=hsv(length(noise_scale_factors));
mark = {'-o','-x','-d'};

% plots for each noise level
for myplot = 1:length(EnergyEfficiency(:,1))
    % xaxis is gSyn in nS
    % Mutual Info
    
   subplot(2,2,1)
      plot(xaxis,MI_data(myplot,:),mark{myplot},'color',cc(myplot,:))
      hold on     
      title('Mutual Info')
      ylabel('bits/sec')
      xlabel('gsyn [nS]')
      legend
    % Energy
   subplot(2,2,2)
      plot(xaxis,Energy_data(myplot,:),mark{myplot},'color',cc(myplot,:))
      hold on   
      title('ATP')
      ylabel('ATP/sec')
      xlabel('gsyn [nS]')

   % MI / Energy
   subplot(2,2,3)
      plot(xaxis,EnergyEfficiency(myplot,:),mark{myplot},'color',cc(myplot,:))
      hold on   
      title('Information Efficiency')
      ylabel('bits/ATP')
      xlabel('gsyn [nS]')

   %AP freq
   subplot(2,2,4)
      plot(xaxis,mean_freq_Hz(myplot,:),mark{myplot},'color',cc(myplot,:))
      hold on  
      title('AP freq.')
      xlabel('gsyn [nS]')
      ylabel('Freq. Hz')

end



