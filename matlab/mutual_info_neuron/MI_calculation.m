function [MI, Htotal, final_Hnoise] = MI_calculation(all_data_repeats);

% MI = Htotal - Hnoise

global nreps

% organise the data
for loop = 1:size(all_data_repeats,1)
    data_array(loop,:) = all_data_repeats{loop,1}';
end

% parameters
dt = 0.5; % mV
timebin = 3; % ms
wordlength = 5; % in bins i.e. = 15ms
Ts = timebin * wordlength; % duration of 'word' in ms
T = 10000; % total time in ms
APpeak = 10; % mV

%% binarize data
binary_data = zeros(size(data_array));
binary_data(data_array==APpeak)=1;
bin_pos = 1:(timebin/dt):length(binary_data(1,:)); % gets vector start position of each 3ms time bin

%% bin data in 3ms bins 'downsampling'
for xx = 1:nreps
    for x = 1:length(bin_pos)
        row = binary_data(xx,:);
        try
            if any(row(bin_pos(x):bin_pos(x)+((timebin/dt)-1)))==1        
               binned_data(xx,x)=1;
            else
               binned_data(xx,x)=0;
            end        
        catch % e.g. if there is a remainder, this prevents loop error
            binned_data(xx,x)=0;
        end
    end
end

%% reads 'words' over all response repetitions
for x = 1:nreps
    for i = 1:length(binned_data(1,:))-(wordlength-1)
        noisewords{x,i} = num2str(binned_data(x,i:i+wordlength-1));
    end
end
 
%% calculate Htotal (calculates for each repetition then averages)
for x = 1:nreps % loop through all repetitions
    
     words = noisewords(x,:);
     response_probs = sort(countmember(unique(words),words),'descend')/length(noisewords); % vector of the word probabilities present in the column

     for i = 1:length(response_probs)        
         H(i) = response_probs(i)*log2(response_probs(i));
     end

     entropy(x) = -sum(H);
     entropy_rate(x) = ((-1/((Ts/1000)))*sum(H)); % this equals rate in  bits/secs.
     clear H
end

Htotal = mean(entropy_rate); % takes the mean of all 50 repetitions

%% Hnoise, takes column responses for each t step then calculates entropy and averages
for i = 1:length(noisewords)

    column = noisewords(:,i);
    column_words = unique(column)'; % finds unique 'words' in the column
    column_words_freq = countmember(unique(column_words),column); % counts unique 'words'
    Hnoise_probs = sort(column_words_freq,'descend')/nreps; % vector of all words probabilities

    for ii = 1:length(Hnoise_probs)
        H(ii) = Hnoise_probs(ii)*log2(Hnoise_probs(ii));
    end

    H=sum(H);
    H = H*(1/(Ts/1000)); % divide by 1000 to get rate per sec (Ts is millisecss)
    Hnoise(i)=H;
    clear H
end

final_Hnoise = -sum(Hnoise)/length(Hnoise);
MI = Htotal - final_Hnoise;

end
