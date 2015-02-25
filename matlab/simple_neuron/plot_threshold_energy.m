function [] = plot_threshold_energy()
%% entropy calculation
global DT time_bin scaling thresholds
parameters_simple_neuron;

cmap = hsv(8);% create random plot colour
for x = 1:length(thresholds)
    Vthresh = thresholds(x)
    load(['output/simulation_results/Vthresh' num2str(Vthresh) '.mat']);% load file

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
    hold on
    plot(freq,entropy_rate,'Color',cmap(x,:),'MarkerSize',12)
    hold on
end

Legend=cell(length(thresholds),1);

for i = 1:(length(thresholds))
   Legend{i} =  strcat('Vthresh', num2str(thresholds(i))) ;
end

legend(Legend)
lblY     = {'entropy rate [H/S] / energy use [ATP]'};
lblX     = {'Frequency [Hz]'};    
ylabel(lblY(1)); xlabel(lblX(1));

end

