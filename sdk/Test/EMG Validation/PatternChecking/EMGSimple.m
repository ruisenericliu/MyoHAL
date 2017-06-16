% File for EMG reading - 200 Hz
str_emg = 'Curl25lb';
base_emg = csvread(strcat('06161/emg',str_emg,'.csv'));




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

%y_max=127;
%T_e=round(length_emg/Fse);
% figure(1);
% x_e=linspace(0,T_e,length_emg);
% plot(x_e,sum_EMG);
% axis([0,T_e,0,y_max]);
% title('Weighted Average of EMG signals');
% ylabel('Unsigned 8 bit int');
% xlabel('time (s)');

%% Full Dataset Filtered plots

y_max=80;
T_e=round(length_emg/Fse);

f = figure;
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = ['Filtered EMG Signals 1-8 for ', str_emg]; 
p.TitlePosition = 'centertop'; 
p.FontSize = 12;
p.FontWeight = 'bold';

for i=1:num_emg_signals

ax1 = subplot(num_emg_signals,1,i,'Parent',p);

x_e=linspace(0,T_e,length_emg);
plot(ax1,x_e,filt_emg_signal(:,i));
axis([0,T_e,0,y_max]);
ylabel([' EMG # ', num2str(i),]);

end
