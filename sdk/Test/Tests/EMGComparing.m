%% Test filtering 

str1 = 'Fist';
base1 = csvread(strcat('06021/',str1,'.csv'));

str2 = 'Fist_emg';
base2 = csvread(strcat('06081/',str2,'.csv'));

num_signals = size(base1,2);
length1 = size(base1,1);
length2 = size(base2,1);
length = min (length1, length2)

%Incoming signal is at 200 hz   
Fs = 200; 

%% Plotting

y_max=1;
T1 = round(length1/Fs);
T2 = round(length2/Fs);
T = round(length/Fs);

%% rectify signals - take absolute value 

rect_signal1 = abs(base1);
rect_signal2 = abs(base2);

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

filt_signal1 = zeros(length1, num_signals);
for i=1:num_signals
  filt_signal1(:,i)=filter(b,a,rect_signal1(:,i)); 
    
end

filt_signal2 = zeros(length2, num_signals);
for i=1:num_signals
  filt_signal2(:,i)=filter(b,a,rect_signal2(:,i)); 
    
end

%% Plotting

sum_coeff = 0.0;

for nsignal = 1:num_signals
    a = filt_signal1(230:550, nsignal);
    a = a / max (abs (a));
    b = filt_signal2(400:700, nsignal);
    b = b / max (abs (b));
    [Dist,D,k,w]= dtw(a',b');
    s1 = a (w (end:-1:1, 1), :);
    s2 = b (w (end:-1:1, 2), :);
%     k = (520 - 230) + 1
%     s1 = base1(230:520, nsignal);
%     s1 = s1 / max (abs (s1));
%     k2 = (650 - 400) + 1
%     s2 = base2(400:650, nsignal);
%     s2 = s2 / max (abs (s2));
    [R, lag] = xcorr(s1,s2,'coeff');
    coeff = max (abs (R));
    sum_coeff = sum_coeff + coeff;
    
    %% Singular EMG example plot
    
    % Plot original signal 
    figure(nsignal);
    ax(1) = subplot (3, 1, 1);
    T1 = round (k / Fs);
    x=linspace(0,T1,k);
    plot(x,s1);
    axis([0,T1,0,1]);
    title(['DTW of Single Filtered Signal for ', str1, ' from 1.15 - 2.75 s']);
    ylabel('Unsigned 8 bit int');
    xlabel('time (s)');

    %% Singular EMG example plot

    % Plot original signal 
    ax(2) = subplot (3, 1, 2);
    T2 = round (k / Fs);
    x=linspace(0,T2,k);
    plot(x,s2);
    axis([0,T2,0,1]);
    title(['DTW of Single Filtered Signal for ', str2, ' from 2.0 - 3.5 s']);
    ylabel('Unsigned 8 bit int');
    xlabel('time (s)');

    %% Comparing signals

    % Plot original signal 
    ax(3) = subplot (3, 1, 3);
    plot(lag/Fs,R);
    axis([-T,T,-1,1]);
    nsignal_str = num2str (nsignal);
    coeff_str = num2str (coeff);
    title(['Cross-correlation of Signal ' nsignal_str ' = ' coeff_str]);
    ylabel('Unsigned 8 bit int');
    xlabel('time (s)');
    
end

sum_coeff = sum_coeff / num_signals;

fprintf ('Average cross-correlation = %f\n', sum_coeff);