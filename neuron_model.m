function [tspan1,gsyn, data_AP, APfreq, iInj_plot, ind] = neuron_model(switchPlot)

global tstart dt DT AP starthere tlast tauM scalefactor Rm Vthresh tm s0 EAMPA EL Vspike thresholds scaling;

%% generate a random conductance
seed    = 62;
rng(seed);          % seed the RNG

dt = 0.05; % ms
how_many_seconds = 10; % [seconds]
DT = how_many_seconds * 1000; % ms
EAMPA = 0;
EL = -70;
s0 = EL;

Vthresh = -50;
Vspike = 10;
Rm = 90;
tauM = 30;

gNoise = 0.001+0.12*randn((DT/dt+1),1);
gNoise(gNoise < 0)=0;% [mS]
gNoise = (gNoise/10);
gNoise = gNoise * 0.65;

[spikeTrainRaw, spikeTrain1Sec, countTotal, count1sec, epsp, gsyn] = rand_spike_train;

gCond = gNoise + gsyn;


options = odeset('MaxStep',dt,'RelTol',1e-03,'OutputFcn',@myfun,'Event',@myEvent);
tspan1   = 0:dt:DT;% to get full length of array
tstart  = clock;
data = zeros(size(tspan1));

%% loop setting parameters
tlast = 0; starthere = 0; AP = -1;% set to -1 because AP = AP + 1 is called when the while loop breaks naturally 

%% integrating loop
while tlast < DT    % loops until target time reached
    tspan = tlast:dt:DT;
    [time, S] = ode15s(@fxn,tspan,s0,options);% options specify pause and reset if solution > Vthresh
    data((starthere+1):(length(S)+starthere))=S;% concatenates data array over loop
    tlast =  2*dt + round((max(time)-0.024999)/0.05)*0.05;% grabs stoptime, to feed into next loop as starttime
    starthere = starthere+length(S);
    AP = AP +1;% counts spikes
end

if AP > 0
    APfreq = AP /(DT/1000);% in Hz
else
    APfreq = 0;% threshold not reached
end

%% stop event
function [value,isterminal,direction] = myEvent(~,s)
    r          = double((s) > Vthresh);
    value      = r;
    isterminal = r;
    direction  = 0;
end

%% main nested subfunction
    function ds = fxn(t,s)
        V = s(1);
        iInj    = -gCond(floor(t/dt)+1)*(V-EAMPA); % [nA]
        iInj_plot(floor(t/dt)+1)=iInj; % creates vector for plotting current inject over time
        ds(1) = (EL - V + (Rm * iInj))/tauM;       % solves for V      
        ds     = ds';                               % transpose the vector of derivatives
        ds(isnan(ds)) = 0;                          % avoids NaN in the vector of derivatives
        ds(isinf(ds)) = 0;                          % avoids Inf in the vector of derivatives           
    end

%% add spikes into data
data = data'; % flip it
ind = zeros(length(data),1); % create index for threshold
ind(data >= Vthresh) = 1; 
data_AP = data;
data_AP(ind==1)= Vspike; % apply index

%% figure
if switchPlot == 1
    figure;
    lblY     = {'V [mV]'};
    lblX     = {'Time [ms]'};    
    plot(data_AP)     
    ylabel(lblY(1));
    xlabel(lblX(1));
end

end

% subfunction for output
function status = myfun(t,s,flag)
global tstart DT;
eta = (clock-tstart)*[0 0 24*60*60 60*60 60 1]';
fprintf([...
    't = ' num2str(t,'%0.2f') ' ms || ' num2str(100*t/DT,'%0.2f')...
    '%% completed || ETA = ' num2str(eta*(DT-t)./(t*60),'%03.2f') ' min\n']);
status = 0;
end
