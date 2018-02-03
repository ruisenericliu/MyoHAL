% File for EMG reading - 200 Hz
str_emg = 'MultiTaskEmg';
base_emg = csvread(strcat('06091/',str_emg,'.csv'));

str_emg = 'DoubleTap';
base_emg = csvread(strcat('06021/',str_emg,'.csv'));


%% Filter EMG Signals

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

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

%% Weighting EMG values 

% weight order - based on positions of myo and physiology;
weights=[.20, .20, .05, .05, .10, .10, .10, .20];

sum_EMG= zeros(length_emg,1);
for i=1:length_emg
    temp_sum=0;
    for j=1:num_emg_signals
    temp_sum = temp_sum + filt_emg_signal(i,j)*weights(j);
    end
    sum_EMG(i)=temp_sum;
    
end



%% Plot Weighted Average of EMG data

y_max=127;
T_e=round(length_emg/Fse);
figure(1);
x_e=linspace(0,T_e,length_emg);
plot(x_e,sum_EMG);
axis([0,T_e,0,y_max]);
title('Weighted Average of EMG signals');
ylabel('Unsigned 8 bit int');
xlabel('time (s)');

%% Full Dataset Filtered plots
% for i=1:num_emg_signals
% 
% figure(1+i);
% x_e=linspace(0,T_e,length_emg);
% plot(x_e,filt_emg_signal(:,i));
% axis([0,T_e,0,y_max]);
% title(['Filtered EMG Signal # ', num2str(i),' for ', str_emg]);
% ylabel('Unsigned 8 bit int');
% xlabel('time (s)');
% 
% end

