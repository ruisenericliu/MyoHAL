%% SpeedCalibration.m 
% Ruisen (Eric) Liu 
% 07/03/17
% This script will be used to compare video analysis speed data 
% with the acceleration data from the armband

% Second experiment - additional orientation data collected 
% from my armband

% Experiment Setup: 
% 
% Oguz wore the Myo armband on his right arm, with sensor 4 aligned on the 
% inner wrist. He moved 10 weighted bottles in a 47 second interval. 
%
% Video: 070317Oguz1 - Video analysis software: 30 frames per second  
% Syncing baseline: Made a closed fist 3 times.
% 
% The first closed fist ? started around 201 - 6.7
% The second closed fist ? around 278 - 9.27
% The last closed fist ? around 355 - 11.83

%
% Acceleration Data from Myo: 50 Hz
% EMG Data from Myo: 200 Hz 

% 1st fist: 1.481s
% 2nd fist: 4.207s
% 3rd fist: 6.848s

%% offset estimate between video and Myo 
vid_mark = [201/30, 278/30, 355/30]; % software estimates at 30 FPS.
guess_mark = [1.481, 4.207, 6.848];
offset = mean(vid_mark - guess_mark); % Myo is ~ 5.09s delayed. 

%% Close figures

fh=findall(0,'type','figure');
for i=1:length(fh)
     clo(fh(i));
end

%% File for Raw Myo Accel Reading - 50 Hz
% 3 axis accelerometer

str_acc = 'accel';
base_acc = csvread(strcat('07031/',str_acc,'.csv'));

Fsa = 50;
length_acc = size(base_acc,1);
num_acc_signals = size(base_acc,2);

%% File for world oriented Myo Accel Reading - 50 Hz 

str_acc_w = 'worldAccel';
base_acc_w = csvread(strcat('07031/',str_acc_w,'.csv'));

length_acc_w = size(base_acc_w,1);
num_acc_signals_w = size(base_acc_w,2);



%% File for Myo EMG Reading - 200 Hz 
% 8 emg sensors 
str_emg = 'emg';
base_emg = csvread(strcat('07031/',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

%% File for Video Speed - 30 Hz 
% frame #, velocity, acceleration 

str_vid = 'video';
base_vid = csvread(strcat('07031/',str_vid,'.csv'));

Fsv = 30; %hz 
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
%csvwrite('06271/filtEMGOguz.csv', filt_emg_signal);

%% Temporary plot to estimate beginning  fist times 
% Weighting EMG values

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
% figure(1000);
% x_e=linspace(0,T_e,2000);
% plot(x_e,sum_EMG(1:2000,:));
% axis([0,T_e,0,y_max]);
% title('Weighted Average of EMG signals');
% ylabel('Unsigned 8 bit int');
% xlabel('time (s)');

%% Examining Frequency domain of a single Acc signal
% 
% plot in frequency domain 
signal = base_acc(:,2);

% get the closest power of 2 
nfft2 = 2.^nextpow2(length_acc);
fy = fft(signal,nfft2); % convert to frequency domain
fy = fy(1:nfft2/2);  % LHS of frequency signal 
xfft = Fsa.*(0:nfft2/2 - 1)/nfft2;  % scale time to frequency domain

figure(1);
plot(xfft, abs(fy)/max(fy)); % normalized
title(['Single  Signal for ', str_acc, ' in Frequency Domain']);
ylabel('Normalized Magnitude');
xlabel('Frequency (Hz)');


%% Filter Acceleration Data 

length_acc = size(base_acc,1);
num_acc_signals = size(base_acc,2);

%Incoming signal is at 50 Hz 
Fsa = 50;

% Chebyshev Type 1 High pass filter - for DC offset only
order_a=3;
Rp=20; %dB
wn_a=0.016/(Fsa/2); % 0.016 - 2* nyquist/length
[b_a,a_a]=cheby1(order_a,Rp, wn_a, 'high');


%[b_a,a_a] = butter(order_a,wn_a,'high');

% % low pass filter 
% 
% order_a2=4;
% wn_a2=3/(Fsa/2);
% [b_a2,a_a2]=butter(order_a2, wn_a2, 'low');


%fvtool(b_a, a_a);

%% Filter Accelerations
filt_acc_signal = zeros(length_acc, num_acc_signals);
filt_acc_signal_w = zeros(length_acc_w, num_acc_signals);

%% Raw Acceleration
for i=1:num_acc_signals
  filt_acc_signal(:,i)=filter(b_a,a_a,base_acc(:,i)); 
  %filt_acc_signal(:,i)=filtfilt(b_a,a_a,base_acc(:,i));
end

%% Filter Oriented Acceleration 

% TODO - why does this make things close 
%base_acc_w(:,3) = base_acc_w(:,3) - 9.8;

for i=1:num_acc_signals
  filt_acc_signal_w(:,i)=filter(b_a,a_a,base_acc_w(:,i)); 
  %filt_acc_signal(:,i)=filtfilt(b_a,a_a,base_acc_w(:,i));
end

% % Apply low pass filter 
% for i=1:num_acc_signals
%   filt_acc_signal_w(:,i)=filter(b_a2,a_a2,filt_acc_signal_w(:,i)); 
%   %filt_acc_signal(:,i)=filtfilt(b_a,a_a,base_acc_w(:,i));
% end

%% temporary get some averages of the data
acc_avg = zeros(3,1);
for i=1:3
    acc_avg(i) = mean(base_acc_w(1:length_acc_w,i));
end


for i=1:num_acc_signals
  filt_acc_signal_w(:,i)=base_acc_w(:,i) - acc_avg(i);
end



%% Plot Raw Acceleration Data

% Plot original signal 

for i=1:num_acc_signals
    
y_max=1.2*max(abs(base_acc(:,i)));
T_a=round(length_acc/Fsa);
    
figure(1+i);
hold on;
x_a=linspace(0,T_a,length_acc);
plot(x_a,base_acc(:,i));

% Plot filtered signal
plot(x_a,filt_acc_signal(:,i));
axis([0,T_a,-y_max,y_max]);
title(['Acceleration Signal for Axis ', num2str(i)]);
ylabel('m/s^2');
xlabel('time (s)');
legend('Raw','Filtered')
hold off;

end

%% Plot World Acceleration Data 


% Plot original signal 

for i=1:num_acc_signals

y_max=1.2*max(base_acc_w(:,i));
T_a=round(length_acc/Fsa);

    
    
figure(4+i);
hold on;
x_a=linspace(0,T_a,length_acc);
plot(x_a,base_acc_w(:,i));

% Plot filtered signal 
plot(x_a,filt_acc_signal_w(:,i));
axis([0,T_a,-y_max,y_max]);
title(['Oriented Acceleration Signal for Axis ', num2str(i)]);
ylabel('m/s^2');
xlabel('time (s)');
legend('Raw','Filtered')

hold off;

end

%% Plot Acceleration Magnitude 

% sum the magnitude 

temp = filt_acc_signal_w;
mag_acc = zeros(length_acc, 1);

for i=1:length_acc
    mag_acc(i) = sqrt(temp(i,1)^2 + temp(i,2)^2 + temp(i,3)^2 );
end

% 3 point average - smooth out signal a little 
temp = zeros(length_acc, 1);

for i=2:length_acc-2
    temp(i) = mean(mag_acc(i-1:i+1));
end
mag_acc = temp;

y_max=10;
T_a=round(length_acc/Fsa);
figure(8);
x_a=linspace(0+offset,T_a+offset,length_acc);
plot(x_a,mag_acc);
axis([10,50,0,y_max]);
title('Armband Magnitude of Acceleration');
ylabel('m/s');
xlabel('time (s)');


%% From Video: 

y_max=10;
T_v = 50;
figure(9);
x_v=linspace(base_vid(1,1)/Fsv,base_vid(length_vid,1)/Fsv,length_vid);
plot(x_v,base_vid(:,3)/1000);
axis([10,T_v,0,y_max]);
title('Ground Truth Acceleration');
ylabel('m/s^2');
xlabel('time (s)');
 

%% Plot them together
% figure;
% hold on;
% plot(x_a,mag_acc);
% plot(x_v,base_vid(:,3)/1000);
% axis([10,T_v,0,y_max]);
% title('Acceleration');
% ylabel('m/s^2');
% xlabel('time (s)');
% legend('armband', 'video');
% 
% hold off;



%% Calculating RMS Speed 

dt = 1/Fsa; 
%Calculate Velocity 
velocity = zeros(length_acc, num_acc_signals);

%% Ignore the first 5 seconds of data (5*50 = 250)
for i=1:num_acc_signals 
    for j=250:length_acc 
        velocity(j,i)= velocity(j-1,i) + filt_acc_signal_w(j-1,i)*dt;
    end
end

% %% Try low pass filter on velocity 
% 
% order_v=4;
% wn_v=0.1/(Fsa/2);
% [b_v,a_v]=butter(order_v, wn_v, 'low');
% 
% % Filtering all 8 EMG signals
% filt_vel_signal = zeros(length_acc, num_acc_signals);
% for i=1:num_acc_signals
%   filt_vel_signal(:,i)=filter(b_v,a_v,velocity(:,i)); 
%     
% end


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


% csvwrite('06271/filtRMSOguz.csv', RMS);


%% Plot Video Velocity Data
% RMS Speed 
y_max=1500;
T_v = 50;
figure(10);
x_v=linspace(base_vid(1,1)/Fsv,base_vid(length_vid,1)/Fsv,length_vid);
plot(x_v,base_vid(:,2));
axis([0,T_v,0,y_max]);
title('Ground Truth Speed');
ylabel('mm/s');
xlabel('time (s)');

%% Plot Velocity
    figure(11);
    x_a=linspace(0+offset,T_a+offset,length_acc);
    plot(x_a, velocity);
    title('Velocity along each axis');
    ylabel('m/s');
    xlabel('time (s)');
    legend('x','y','z');

%% Plot RMS Data 
%hold on;
% RMS Speed 
y_max=1000;
T_a=round(length_acc/Fsa);
figure(12);
x_a=linspace(0+offset,T_a+offset,length_acc);
plot(x_a,RMS);
%axis([0,T_v,0,y_max]);
title('Armband RMS Speed');
ylabel('mm/s');
xlabel('time (s)');

%hold off;