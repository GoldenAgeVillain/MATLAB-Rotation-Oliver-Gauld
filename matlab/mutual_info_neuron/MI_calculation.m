function [MI, Htotal, final_Hnoise] = MI_calculation(all_data_reps, spiketrain);

global nreps

% all_data_reps=data_store(:,1);
% spiketrain=data_store{1,4};

for loop = 1:size(all_data_reps,1)

data_array(loop,:) = all_data_reps{loop,1}';

end

%% parameters
dt = 0.5; % mV
timebin = 3; % ms
wordlength = 5; % in bins i.e. = 15ms
Ts = timebin * wordlength; % duration of 'word' in ms
T = 10000; % total time in SECONDS
APpeak = 10; % mV

% binarize data
binary_data = zeros(size(data_array));
binary_data(data_array==APpeak)=1;
bin_pos = 1:(timebin/dt):length(binary_data(1,:)); % gets vector start position of each 3ms time bin

%% bin data in 3ms bins 'downsampling'
for xx = 1:nreps
    for x = 1:length(bin_pos)
        row = binary_data(xx,:);
        try
            if any(row(bin_pos(x):bin_pos(x)+((timebin/dt)-1)))==1 % '=5' refers to n-1 where n = 6 T/dt (3ms/0.5ms)       
               binned_data(xx,x)=1;
            else
               binned_data(xx,x)=0;
            end        
        catch % e.g. if there is a remainder, this prevents loop error
            binned_data(xx,x)=0;
        end
    end
end

%% bin input spike train 'downsampling'
for x = 1:length(bin_pos)
        row = spiketrain(:);
        try
            if any(row(bin_pos(x):bin_pos(x)+((timebin/dt)-1)))==1        
               binned_spiketrain(x)=1;
            else
               binned_spiketrain(x)=0;
            end        
        catch
            binned_spiketrain(x)=0;
        end
end
    
%% reads 'words' in stimulus input
for p = 1:length(binned_spiketrain)-(wordlength-1)
   all_words{p} = num2str(binned_spiketrain(p:p+wordlength-1));
end

individual_words = unique(all_words)'; % finds unique 'words'
word_freq = countmember(unique(all_words),all_words); % gets frequency for each unique 'word'

[~,I] = sort(word_freq,'descend'); %rank frequences high to low and gets index order
individual_words_ordered = individual_words;
individual_words_ordered = individual_words_ordered(I,:); %reorders the words for graph labels high freq to low freq

% calculate probality distribution
probs = sort(word_freq,'descend')/length(all_words); % vector of all words probabilities

% stimulus input entropy calculation
for i2 = 1:length(probs)
    Hinput(i2) = probs(i2)*log2(probs(i2));
end

input_entropy  = -sum(Hinput);
input_entropy_rate = (-1/(Ts/1000))*sum(Hinput); % Ts is in ms, divide by 1000 to get entropy rate per sec

%% graphing prob histogram
bar(probs); % plot freq hist
set(gca,'Xtick',1:length(individual_words),'XTickLabel',individual_words_ordered);
rotateXLabels(gca,45)
title('Probability distribution for fixed input stimulus','FontSize',20)
ylabel('P(word)','FontSize',20);
xlabel('words','FontSize',20);

%% for Noise, reads words over all response repetitions
for x = 1:nreps
    for i3 = 1:length(binned_spiketrain)-(wordlength-1)
        noisewords{x,i3} = num2str(binned_data(x,i3:i3+wordlength-1));
    end
end
 
%% calculate Htotal (calculates for each repetition then averages)
for x = 1:nreps
    
     word = noisewords(x,:);
     noiseprobs = sort(countmember(unique(word),word),'descend')/length(binned_spiketrain); % vector of all words probabilities

     %% response entropy calculation
     for i4 = 1:length(noiseprobs)        
         H(i4) = noiseprobs(i4)*log2(noiseprobs(i4));
     end

     entropy(x) = -sum(H);
     entropy_rate(x) = ((-1/((Ts/1000)))*sum(H)); % this equals rate in  bits/secs. times1000 for bits/sec
     clear H

end

Htotal = mean(entropy_rate); % takes the mean of all 50 repetitions


%% Hnoise, takes column responses for each t step then calculates entropy and averages
for i5 = 1:length(all_words)

    column = noisewords(:,i5);
    x = unique(column)'; % finds unique 'words' in the column
    y = countmember(unique(x),column); % counts unique 'words'
    Hnoise_probs = sort(y,'descend')/nreps; % vector of all words probabilities

    for ii = 1:length(Hnoise_probs)
        H(ii) = Hnoise_probs(ii)*log2(Hnoise_probs(ii));
    end

    H=sum(H);
    H = H*(1/Ts);
    Hnoise(i5)=H;
    clear H
end

final_Hnoise = -sum(Hnoise)*(timebin/T); % average of all noise CHECK RATE UNITS
MI = Htotal - final_Hnoise;

%data_fraction_entropy_estimation(all_words, wordlength, Ts, T)



% V = (0.05:0.05:1)'; % this scales the data for visualisation
% for i = 1:length(V)
%     D(i,:) = (binned_data(i,:).*V(i));
% end

% %% raster plot
% subplot(2,1,1)
% plot(binned_spiketrain,'-b')
% ylim([0 3])
% for i = 1:reps
%     subplot(2,1,2)
%     %D(D==0)=NaN; % set 0's to nans so they don't get plotted 
%     plot(D(i,:),'.r')
%     hold on
% end

end