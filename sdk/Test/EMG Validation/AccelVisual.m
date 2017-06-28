% File for Accel Reading - 50 Hz
str_acc = 'MultiTaskAcc';
base_acc = csvread(strcat('06091/',str_acc,'.csv'));

%str_acc = 'accelTreadMill';
%base_acc = csvread(strcat('06161/',str_acc,'.csv'));


%% Filter Acceleration Signals 

length_acc = size(base_acc,1);
num_acc_signals = size(base_acc,2);

%Incoming signal is at 50 Hz 
Fsa = 50;

% Chebyshev Type 1 High pass filter 
order_a=2;
Rp=3; % 3 dB
wn_a=5/(Fsa/2); % 0.5 Hz 
[b_a,a_a]=cheby1(order_a,Rp, wn_a, 'high');

filt_acc_signal = zeros(length_acc, num_acc_signals);
for i=1:num_acc_signals
  filt_acc_signal(:,i)=filter(b_a,a_a,base_acc(:,i)); 
    
end


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

%% Examining Frequency domain of a single Acc signal

% % plot in frequency domain 
% signal = base_acc(:,3);
% 
% % get the closest power of 2 
% nfft2 = 2.^nextpow2(length_acc);
% fy = fft(signal,nfft2); % convert to frequency domain
% fy = fy(1:nfft2/2);  % LHS of frequency signal 
% xfft = Fsa.*(0:nfft2/2 - 1)/nfft2;  % scale time to frequency domain
% 
% figure(1)
% plot(xfft, abs(fy)/max(fy)); % normalized
% title(['Single  Signal for ', str_acc, ' in Frequency Domain']);
% ylabel('Normalized Magnitude');
% xlabel('Frequency (Hz)');


%% Plot Acceleration Data 

y_max=15;
T_a=round(length_acc/Fsa);

% Plot original signal 
figure(2);
x_a=linspace(0,T_a,length_acc);
plot(x_a,base_acc(:,3));
axis([0,T_a,-y_max,y_max]);
title(['Single Raw Signal for ', str_acc]);
ylabel('m/s^2');
xlabel('time (s)');

y_max=5;
% Plot filtered signal 
figure(3);
x_a=linspace(0,T_a,length_acc);
plot(x_a,filt_acc_signal(:,3));
axis([0,T_a,-y_max,y_max]);
title(['Single Filtered Signal for ', str_acc]);
ylabel('m/s^2');
xlabel('time (s)');

%% Plot Velocity Data 

% RMS Speed 
y_max=1;
T_a=round(length_acc/Fsa);
figure(4);
x_a=linspace(0,T_a,length_acc);
plot(x_a,RMS);
axis([0,T_a,0,y_max]);
title('RMS Speed');
ylabel('m/s');
xlabel('time (s)');

