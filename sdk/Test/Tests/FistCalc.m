%% File for Myo EMG Reading - 200 Hz 
% 8 emg sensors 
str_emg = 'emg';
base_emg = csvread(strcat('Participant008/8/',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

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

for i=1:8
max_emg(i) = max(filt_emg_signal(:,i));
end
%% Temporary plot to estimate beginning  fist times 
% Weighting EMG values

%weight order - based on positions of myo and physiology;
%weights=[.20, .20, .05, .05, .10, .10, .10, .20];
weights = [.125,.125,.125,.125,.125,.125,.125,.125];

sum_EMG= zeros(length_emg,1);
for i=1:length_emg
    temp_sum=0;
    for j=1:num_emg_signals
    temp_sum = temp_sum + filt_emg_signal(i,j)*weights(j);
    end
    sum_EMG(i)=temp_sum;
    
end

weight_max = max(sum_EMG);

% Plot 

y_max=127;
T_e=round(2000/Fse);
figure(1);
x_e=linspace(0,T_e,2000);
plot(x_e,sum_EMG(1:2000,:));
axis([0,T_e,0,y_max]);
title('Weighted Average of EMG signals');
ylabel('Unsigned 8 bit int');
xlabel('time (s)');
