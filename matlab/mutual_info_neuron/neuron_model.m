function [data, data_AP, APfreq, iInj_plot,spiketrain, gsyn] = neuron_model(switchPlot,noise_scaler,gsyn_scaler);

global tstart dt DT

dt = 0.5; % ms
how_many_seconds = 10; % [seconds]
EAMPA = 0;      % mV
EL = -70;       % mV
s0 = EL;        % mV

Vthresh = -50;  % mV
Vspike = 10;    % mV
Rm = 90;        % MOhms
tauM = 30;      % ms

seed    = 62;
rng(seed);          % seed the RNG

% generate spike train
[spiketrain, gsyn] = rand_spike_train;

DT = how_many_seconds * 1000; % ms

rng('shuffle'); % restores rand generator for random syn noise
gNoise_mean = 3.45;
gNoise = gNoise_mean+3.45*randn(length(gsyn),1);
gNoise(gNoise < 0)=0;% [nS]

gTotal = (gsyn*gsyn_scaler) + (gNoise*noise_scaler);


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
    tlast =  2*dt + round((max(time)-0.24999)/0.5)*0.5;% grabs stoptime, to feed into next loop as starttime
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
        iInj    = -gTotal(floor(t/dt)+1)*(V-EAMPA); % nS * mV = [pA]
        iInj = iInj / 1000; % [nA]
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
    
    subplot(4,1,1)
    plot(spiketrain)
    title('Input stimulus')
    xlim([0 length(spiketrain)])   
    ylabel('Action potential');

    subplot(4,1,2)
    plot(gTotal)
    xlim([0 length(spiketrain)])
    title('total postsynaptic conductance (synaptic + noise)')
    ylabel('Conductance [nS]');
        
    subplot(4,1,3)
    plot(iInj_plot)
    xlim([0 length(spiketrain)])
    title('postsynaptic current (EPSC)')
    ylabel('Current [nA]');
 
    subplot(4,1,4)   
    lblY     = {'Voltage [mV]'};
    lblX     = {'Time [ms]'};    
    plot(data_AP)     
    xlim([0 length(spiketrain)])
    title('post-synaptic membrane response')

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
