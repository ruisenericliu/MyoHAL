% Temporary file 
% Maximums for Calibration from Participants 

% Participant 078
EMG78 = [57.2231  105.9321   92.7273   65.5884   73.5683   97.0909 ...
    77.3721   79.4111];

wmax78 =  66.1136;

% Particpant 026
EMG26 = [ 98.0465   92.6154   88.0399  108.2185  118.4388 ...
    101.9256  102.0554   99.0831 ];

wmax26 = 60.8644;


% Particpant 020
EMG20 = [ 85.5527  100.7724   87.2044   65.7170 ...
    67.8195   84.9353   93.5929   91.7870 ];

wmax20 = 67.886;

% Particpant 008

EMG08 = [ 107.7944   84.2919   86.5847   76.2229  ...
    103.6466  105.7793  109.2416  103.9364 ] ; 

wmax08 = 80.6700; 

maxes = [EMG78;EMG26;EMG20;EMG08];
    
sums = [wmax78;wmax26;wmax20;wmax08];

disp = [maxes, sums];

means = [mean(EMG78); mean(EMG26); mean(EMG20); mean(EMG08)];
