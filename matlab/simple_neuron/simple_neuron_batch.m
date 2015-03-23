clear all;

global scaling tauM scalefactor DT Cm data Vthresh Rm dt tpan s0 EAMPA EL Vspike thresholds time_bin
parameters_simple_neuron;


for i = 1:length(Rmem)
 %  tauM = tm(i); % [ms]
 %  Vthresh = thresholds(i);
   Rm = Rmem(i);
  %load(['output/simulation_results/largescalerange/Vthresh' num2str(Vthresh) '.mat']);% load file

   for ii =1:length(scaling)
       scalefactor = scaling(ii);
       [time,S,data_AP,frequency, current, ind]=simple_neuron(0);
       dataloop = {time, S, data_AP, frequency, current, ind};
       
       data{ii,1}=dataloop;
       data{ii,2}=scalefactor;
       data{ii,3}=tauM;
       data{ii,4}=DT;
       data{ii,6}=Vthresh;
       
       %% calculate membrane capacitance         
       cm = 10; %[nF/mm2]
       rm = tauM / cm; %[MOhms x mm2]
       Area = rm / Rm; % [mm2]
       Cm = cm * Area; % [nF]
       
       data{ii,7}=Cm;
       data{ii,5} = energy_calc(i,ii); % total ATP used 
   end
       filename = ['output/simulation_results/largescalerange/Vthresh' num2str(Vthresh) '.mat'];
       filename = ['output/simulation_results/largescalerange/tm' num2str(tauM) '.mat'];
       filename = ['output/simulation_results/largescalerange/Rm' num2str(Rm) '.mat'];

       save(filename,'data');
end
