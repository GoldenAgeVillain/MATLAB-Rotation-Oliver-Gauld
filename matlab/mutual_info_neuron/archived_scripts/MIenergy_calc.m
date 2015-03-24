function [totalATPuse] = energy_calc(currentTrace, APfreq)


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%% ATP on single ActionPotential %%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        voltjump = 70; % [mV] -50mV ==> + 10mV       
        NaCharge   = 1.6022e-19; % (C) elementary charge of Na+

        %%%%%%%% calculate membrane capacitance %%%%%%%     

        Rm = 90;        % [MOhms]
        tauM = 30;      % [ms]      
        cm = 10;        % [nF/mm2]
        rm = tauM / cm; % [MOhms x mm2]
        Area = rm / Rm; % [mm2]
        Cm = cm * Area; % [nF]
       
        % calculate charge entry needed to raise membrane potential        
        % Q = CV
        
        charge = Cm * voltjump;       % pC = nF * mV
                                      % pC = nA * ms
        charge = (charge)/10^12;      % [C] =  A * s convert pC into Coloumbs
        charge = charge * 1.25;       % [C] 1.25 = Bean and Carter 2009 scale factor
    
        % Calculate no Na+ ions:
        AP_NaEntry = charge/NaCharge;             % average Na entry per sec
        
        % Calculate no ATP molecules needed:
        AP_ATP  = AP_NaEntry/3; % need 1 ATP to pump out 3 Na

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        %%%%%%%%%%%%%%% ATP on current %%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %convert current trace into Amps from nanoamps
        currentTrace = currentTrace * 10^-9; 
        
        %% Parameters
        timeStep   = 0.5; % [ms]

        % Trace-dependent parameters
        trainTime = length(currentTrace)*timeStep/1000; % sec
       
        % Integrate trace:
        integral    = sum(currentTrace)*timeStep;   % A*ms
        totalChargeEntry = integral*1e-3;           % C (A*S)
        chargeEntry = totalChargeEntry/trainTime;   % average charge entry per sec

        % Calculate no Na+ ions:
        NaEntry = chargeEntry/NaCharge;             % average Na entry per sec

        % Calculate no ATP molecules needed:
        currentATPuse  = NaEntry/3;                 % average ATP use per sec
 
        % times by AP freq (in Hz) to get energy use in seconds          
        totalATPuse = currentATPuse + (APfreq * AP_ATP);
end