% Test filtering 

base = csvread('06021/Fist.csv');



length = size(base,1);
num_signals = size(base,2);

rect_signal = base;

%% rectify signals
for i=1:length
   for j=1:num_signals
       if (base(i,j) < 0)
          rect_signal(i,j) = 0;
       end
   end
end

%% Filter a particular signal

% Temporary selected signal
signal = rect_signal(:,2)';


%% Incoming signal is at 200 hz
    
Fs = 400; 

% get the closest power of 2 
nfft2 = 2.^nextpow2(length);

fy = fft(signal,nfft2); % convert to frequency domain
fy = fy(1:nfft2/2);  % LHS of frequency signal 
xfft = Fs.*(0:nfft2/2 - 1)/nfft2;  % scale time to frequency domain
figure(1)
plot(xfft, abs(fy/max(fy))); % normalize 

% Testing a low pass FIR filter 
cutoff = 20/Fs/2; % 20 Hz? 
order = 32;
h = fir1(order, cutoff);
con = conv(signal,h);


% Plot original signal and filtered signal 
figure(2);
plot(base(:,2));
figure(3);
plot(con);

% Butterworth filter
% order2=2;
% cutoff2=10/Fs/2
% [b,a]=butter(order2, cutoff2);        % low pass
% % h = fvtool(b,a);                 % Visualize filter
% filtered = filter(b,a,signal);
% figure(4);
% plot(filtered)