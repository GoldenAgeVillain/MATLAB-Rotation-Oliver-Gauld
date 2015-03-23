function [output] = data_fraction_entropy_estimation(words, wordlength, worddur, totaldur);
% words should be a cell array of binary word strings
% word length = number of time bins
% word dur = word length * time bin duration (should be x * 3ms)
% totaldur = stimulus/response duration in SECONDS

% this function plots a graph of entropy as a function of data size. See
% figure 2 inset from Strong et al. 1998.

for s = 1:4
    
    for x = 1:100
        
    data_fractions{1,:} = datasample(words,(length(words)));% whole
    data_fractions{2,:} = datasample(words,round(length(words)/2));% half
    data_fractions{3,:} = datasample(words,round(length(words)/3));% third
    data_fractions{4,:} = datasample(words,round(length(words)/4));% quarter
    
    words2 = data_fractions{s,:};

    unique(words2)'; % finds unique 'words'
    countmember(unique(words2),words2); % counts unique 'words'
    words_and_count = {unique(words2)', countmember(unique(words2),words2)'};

    [~,I] = sort(words_and_count{:,2},'descend'); %rank frequences high to low
    mywords = words_and_count{1};
    mywords = mywords(I,:); %reorders the words

    probs = sort(countmember(unique(words2),words2),'descend')/(length(data_fractions{1,:})+(wordlength - 1)); % vector of all words probabilities

    %% stimulus input entropy calculation
    for i = 1:length(probs)
        H(i) = probs(i)*log2(probs(i));
    end

    entropy = (length(data_fractions{1,:})+(wordlength - 1))*((-1/worddur)*sum(H));
    entropy_rate = entropy/(totaldur); %1663 = number of bins, 5 = total duration in seconds

    myvar(x)=entropy;
    myvar2(x)=entropy_rate;
    end

    output(s)=mean(myvar);
    output2(s)=mean(myvar2);

end

%% plot
    [poly,x] = fit((1:(length(data_fractions)))',output',  'poly2' ); % calculate quadratic line fit
    plot(output,'.r','MarkerSize',20)  
    xlim([0 5])
    hold on
    plot(poly,'b')
    title('Dependence of entropy on data size fraction','FontSize',20)
    xlabel('Inverse data fraction','FontSize',20)
    ylabel('Entropy [bits]','FontSize',20)
end