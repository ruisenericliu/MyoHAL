%% SpeedCalibration.m 
% Ruisen (Eric) Liu 
% 06/27/17
% This script will be used to compare video analysis speed data 
% with the acceleration data from the armband

% Experiment Setup: 
% 
% Oguz wore the Myo armband on his right arm, with sensor 4 aligned on the 
% inner wrist. He moved 10 weighted bottles in a 38 second interval. 
%
% Video: 062717Oguz1 - Video analysis software: 24 frames per second  
% Syncing baseline: Made a closed fist 3 times.
% 
% The first closed fist ? started around 100 - 4.1667.
% The second closed fist ? around 156 -  6.5.
% The last closed fist ? around 216 - 9.0
% These numbers are - counted from software that uses 29 FPS.

%
% Acceleration Data from Myo: 50 Hz
% EMG Data from Myo: 200 Hz 

% 1st fist: 0.8054s
% 2nd fist: 2.801s
% 3rd fist: 4.922s

%% offset estimate between video and Myo 
%vid_mark = [85/24, 130/24,180/24]; % minimum estimate 
vid_mark = [100/29, 156/29, 216/29]; % software estimates at 29 FPS.
guess_mark = [0.8054, 2.801, 4.922];
offset = mean(vid_mark - guess_mark); % Myo is ~ 2.58s delayed. 


%% File for Myo Accel Reading - 50 Hz
% 3 axis accelerometer

str_acc = 'accelOguzCut';
base_acc = csvread(strcat('06271/',str_acc,'.csv'));

length_acc = size(base_acc,1);
num_acc_signals = size(base_acc,2);

%% File for Myo EMG Reading - 200 Hz 
% 8 emg sensors 
str_emg = 'emgOguzCut';
base_emg = csvread(strcat('06271/',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

%% File for Video Speed - 24 Hz 
% frame #, velocity

str_vid = 'speedOguz.csv';
base_vid = csvread(strcat('06271/',str_vid,'.csv'));

Fsv = 24; %hz 
length_vid = size(base_vid,1);

%% Filter the EMG signal 
% and estimate the time of the 3 closed fists

% rectify the signal 
rect_signal  = abs(base_emg);

%Incoming signal is at 200 Hz   
Fse = 200;

% %% Butterworth low-pass filter for EMG signal
order_e=4;
wn_e=10/(Fse/2);
[b_e,a_e]=butter(order_e, wn_e, 'low');

% Filtering all 8 EMG signals
filt_emg_signal = zeros(length_emg, num_emg_signals);
for i=1:num_emg_signals
  filt_emg_signal(:,i)=filter(b_e,a_e,rect_signal(:,i)); 
    
end

% Saved Filtered Data for Oguz 

csvwrite('06271/filtEMGOguz.csv', filt_emg_signal);

%% Temporary plot to estimate beginning  fist times 
% % Weighting EMG values
% 
% %weight order - based on positions of myo and physiology;
% weights=[.20, .20, .05, .05, .10, .10, .10, .20];
% 
% sum_EMG= zeros(length_emg,1);
% for i=1:length_emg
%     temp_sum=0;
%     for j=1:num_emg_signals
%     temp_sum = temp_sum + filt_emg_signal(i,j)*weights(j);
%     end
%     sum_EMG(i)=temp_sum;
%     
% end
% 
% % Plot 
% 
% y_max=127;
% T_e=round(2000/Fse);
% figure(20);
% x_e=linspace(0,T_e,2000);
% plot(x_e,sum_EMG(1:2000,:));
% axis([0,T_e,0,y_max]);
% title('Weighted Average of EMG signals');
% ylabel('Unsigned 8 bit int');
% xlabel('time (s)');
% 
% 1st fist: 0.8054s
% 2nd fist: 2.801s
% 3rd fist: 4.922s

%% Examining Frequency domain of a single Acc signal
% 
% plot in frequency domain 
signal = base_acc(:,3);

% get the closest power of 2 
nfft2 = 2.^nextpow2(length_acc);
fy = fft(signal,nfft2); % convert to frequency domain
fy = fy(1:nfft2/2);  % LHS of frequency signal 
xfft = Fsa.*(0:nfft2/2 - 1)/nfft2;  % scale time to frequency domain

figure(3);
plot(xfft, abs(fy)/max(fy)); % normalized
title(['Single  Signal for ', str_acc, ' in Frequency Domain']);
ylabel('Normalized Magnitude');
xlabel('Frequency (Hz)');


%% Filter Acceleration Data 

length_acc = size(base_acc,1);
num_acc_signals = size(base_acc,2);

%Incoming signal is at 50 Hz 
Fsa = 50;

% Chebyshev Type 1 High pass filter 
order_a=2;
Rp=2; % 3 dB
wn_a=0.5/(Fsa/2); % 0.5 Hz  % 0.012
[b_a,a_a]=cheby1(order_a,Rp, wn_a, 'high');

% lo

% fvtool(b_a, a_a);

filt_acc_signal = zeros(length_acc, num_acc_signals);

for i=1:num_acc_signals
  filt_acc_signal(:,i)=filter(b_a,a_a,base_acc(:,i)); 
  %filt_acc_signal(:,i)=filtfilt(b_a,a_a,base_acc(:,i));
end

% try removing the zero bin;
% for i=1:num_acc_signals
%     data_fft = fft(base_acc(:,i)); 
%     data_fft(1) = 0; 
%     filt_acc_signal(:,i) = ifft(data_fft);
% end

%% Calculating RMS Speed 

dt = 1/Fsa; 
%Calculate Velocity 
velocity = zeros(length_acc, num_acc_signals);
for i=1:num_acc_signals
    for j=2:length_acc
        velocity(j,i)= velocity(j-1,i) + filt_acc_signal(j-1,i)*dt;
    end
end

%Summing for RMS 
vel_sq = velocity.^2;

RMS= zeros(length_acc,1);
for i=1:length_acc
    temp_sum=0;
    for j =1:num_acc_signals
       temp_sum=temp_sum + vel_sq(i,j); 
    end
    RMS(i)=sqrt(1/num_acc_signals*temp_sum);
end

% Go from m/s to mm/s 

temp = RMS*1000;
RMS = temp;

csvwrite('06271/filtRMSOguz.csv', RMS);

%% Plot Video Velocity Data
% RMS Speed 
y_max=1000;
T_v = 40;
figure(1);
x_v=linspace(base_vid(1,1)/Fsv,base_vid(length_vid,1)/Fsv,length_vid);
plot(x_v,base_vid(:,2));
axis([0,T_v,0,y_max]);
title('Ground Truth Speed');
ylabel('mm/s');
xlabel('time (s)');


%% Plot RMS Data 
%hold on;
% RMS Speed 
y_max=1000;
T_a=round(length_acc/Fsa);
figure(2);
x_a=linspace(0+offset,T_a+offset,length_acc);
plot(x_a,RMS);
%axis([0,T_v,0,y_max]);
title('RMS Speed');
ylabel('mm/s');
xlabel('time (s)');

%hold off;