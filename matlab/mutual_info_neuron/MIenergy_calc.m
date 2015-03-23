function [totalATPuse] = MIenergy_calc(currentTrace, APfreq)

% input = post synaptic currentTrace and number of Action potentials
global  Cm

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%% ATP on single ActionPotential %%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        voltjump = 60; % [mV] -50mV ==> + 10mV
        
        NaCharge   = 1.6022e-19; % (C) elementary charge of Na+

        Rm = 90;        % MOhms
        tauM = 30;      % ms
       
        %% calculate membrane capacitance         
        cm = 10; %[nF/mm2]
        rm = tauM / cm; %[MOhms x mm2]
        Area = rm / Rm; % [mm2]
        Cm = cm * Area; % [nF]
       
        % Q = CV
        charge = Cm * voltjump;       % pC = nF * mV
                                      % pC = nA * ms
        charge = (charge)/10^12;      % [C] =  A * s convert picoCs into Coloumbs
        charge = charge * 1.25;       % [C] 1.25 = Bean and Carter 2009 scale factor
    
        % Calculate no Na+ ions:
        AP_NaEntry = charge/NaCharge;             % average Na entry per sec
        
        % Calculate no ATP molecules needed:
        AP_ATP  = AP_NaEntry/3; % need 1 ATP to pump out 3 Na ions

        %%%%%%%% ATP on current %%%%%%%%
        
        %convert current trace into Amps from nanoamps
        currentTrace = currentTrace * 10^-9; % added because currentTrace is initially in nanoAmps
        
        %% Parameters
        timeStep   = 0.5;

        % Trace-dependent parameters
        trainTime = length(currentTrace)*timeStep/1000; % sec
       
        % Integrate trace:
        integral    = sum(currentTrace)*timeStep;   % A*ms
        totalChargeEntry = integral*1e-3;           % C (A*S)
        chargeEntry = totalChargeEntry/trainTime;   % average charge entry per sec

        % Calculate no Na+ ions:
        NaEntry = chargeEntry/NaCharge;             % average Na entry per sec

        % Calculate no ATP molecules needed:
        currentATPuse  = NaEntry/3;                        % average ATP use per sec

        totalATPuse = currentATPuse + (APfreq * AP_ATP); % times by AP freq to get energy use in seconds
            
end