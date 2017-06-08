% Test filtering 

str = 'SpreadFingers';
base = csvread(strcat('06021/',str,'.csv'));

str = 'Multi-task';
base = csvread('EMG_RawAccel/emg1.csv');

length = size(base,1);
num_signals = size(base,2);

%% rectify signals - take absolute value 
rect_signal = abs(base);

%Incoming signal is at 200 hz   
Fs = 200; 

%% Low pass FIR filter - Moving Average
% h = fvtool(b,a);                 % Visualizing filters
% freqz(b,1,512);                 % Frequency response of filter

order=4;
wn = 10/(Fs/2); % 
b = fir1(order, wn);
a= 1;
% ~basic equivalent to: 
%con = conv(signal,h); % multiply signal by filter 

%% Chebyshev filter
wn = 10/(Fs/2);
order=4;
Rp = 3; %Db

[b,a]=cheby1(order,Rp,wn);
% 
% %% Butterworth filter
order=4;
wn=10/(Fs/2);
[b,a]=butter(order, wn, 'low');


%% Filtering all 8 EMG signals

filt_signal = zeros(length, num_signals);
for i=1:num_signals
  filt_signal(:,i)=filter(b,a,rect_signal(:,i)); 
    
end

%% Plotting

y_max=127;
T = round(length/Fs);

%% Singular EMG example plot


% Plot original signal 
figure(1);
x=linspace(0,T,length);
plot(x,base(:,8));
axis([0,T,-y_max,y_max]);
title(['Single Raw Signal for ', str]);
ylabel('Unsigned 8 bit int');
xlabel('time (s)');

% Plot rectified 

signal = rect_signal(:,8);

figure(2);
x=linspace(0,T,length);
plot(x,signal);
axis([0,T,0,y_max]);
title(['Single Rectified Signal for ', str]);
ylabel('Unsigned 8 bit int');
xlabel('time (s)');

% Examining Frequency domain of a single EMG signal

% plot in frequency domain 

% get the closest power of 2 
nfft2 = 2.^nextpow2(length);
fy = fft(signal,nfft2); % convert to frequency domain
fy = fy(1:nfft2/2);  % LHS of frequency signal 
xfft = Fs.*(0:nfft2/2 - 1)/nfft2;  % scale time to frequency domain

figure(3)
plot(xfft, abs(fy)/max(fy)); % normalized
title(['Single Rectified Signal for ', str, ' in Frequency Domain']);
ylabel('Normalized Magnitude');
xlabel('Frequency (Hz)');

% Plot filtered 
figure(4);

x=linspace(0,T,length);
plot(x,filt_signal(:,8));
axis([0,T,0,y_max]);
title(['Single Filtered Signal for ', str]);
ylabel('Unsigned 8 bit int');
xlabel('time (s)');


%% Full Dataset Filtered plots
for i=1:num_signals

figure(4+i);
x=linspace(0,T,length);
plot(x,filt_signal(:,i));
axis([0,T,0,y_max]);
title(['Filtered EMG Signal # ', num2str(i),' for ', str]);
ylabel('Unsigned 8 bit int');
xlabel('time (s)');

end


%% Creating a gif of the rectified/filtered signal
%EMGUnitGif(filt_signal,6, 20, Fs,str);
