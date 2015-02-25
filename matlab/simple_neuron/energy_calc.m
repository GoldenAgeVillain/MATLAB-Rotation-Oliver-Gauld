function [totalATPuse] = energy_calc(tm,scalefactor)
global data Cm dt DT

        %% energy for 1 AP
        voltjump = 70; % [mV] -50mV ==> + 20mV
        NaCharge   = 1.6022e-19; % (C) elementary charge of Na+
        
        charge = Cm * voltjump;       % pC = nF * mV
                                      % pC = nA * ms
        charge = (charge)/10^12;      % [C] =  A * s 
        charge = charge * 1.25;       % [C] 1.25 = Bean and Carter 2009 scale factor
    
        % Calculate no Na+ ions:
        NaEntry = charge/NaCharge;             % average Na entry per sec
        
        % Calculate no ATP molecules needed:
        AP_ATP  = NaEntry/3;    

        currentTrace = (data{scalefactor,1}{1,5});
        AP_number = (data{scalefactor,1}{1,4});

        currentTrace = currentTrace * 10^-9; % added because currentTrace is initially in nanoAmps
        [ATPuse] = ATPOnCurrent(currentTrace);
        totalATPuse = ATPuse + (AP_number * AP_ATP);

end