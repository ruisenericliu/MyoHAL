%% EMGLabel
% This script is used to label a rough ground truth
% for the data collected on 06/16 for determining an exertion
% It will be saved to a new csv file.
% Let 1 denote exertion, and 0 denote non-exertion

%Incoming signal is at 200 Hz   
Fse = 200;

% %% Butterworth low-pass filter for EMG signal
order_e=4;
wn_e=10/(Fse/2);
[b_e,a_e]=butter(order_e, wn_e, 'low');

% Create an end matrix;
n = 40; % number of samples to boxcar average (5 Hz) 
result = [];


%% Process 1 data file 
str_emg = 'Curl25lb';
base_emg = csvread(strcat('06161/emg',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

% rectify the signal 
rect_signal  = abs(base_emg);

% Filtering all 8 EMG signals
filt_emg_signal = zeros(length_emg, num_emg_signals + 1 ); 
% added one for classifaction
for i=1:num_emg_signals
  filt_emg_signal(:,i)=filter(b_e,a_e,rect_signal(:,i)); 
    
end

% Custom label the data 
for i =1:length_emg
    filt_emg_signal(i,9) = 1; % all of it is exertion
end

% Boxcar average the data by n samples 

length_b = floor(length_emg/n);  
avg_filt_emg = zeros(length_b, num_emg_signals + 1);

% average EMG signals, round exertion
for i=1:length_b
    
   % average EMG signals  
   for j=1:num_emg_signals
      avg_filt_emg(i,j) = mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,j));
   end
   % round exertion
   avg_filt_emg(i,9) = round(mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,9)));
    
end

% Concat with base matrix; 
result = [result; avg_filt_emg];

%% Process 1 data file 
str_emg = 'Curl15lb';
base_emg = csvread(strcat('06161/emg',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

% rectify the signal 
rect_signal  = abs(base_emg);

% Filtering all 8 EMG signals
filt_emg_signal = zeros(length_emg, num_emg_signals + 1 ); 
% added one for classifaction
for i=1:num_emg_signals
  filt_emg_signal(:,i)=filter(b_e,a_e,rect_signal(:,i)); 
    
end

% Custom label the data 
for i =1:length_emg
    filt_emg_signal(i,9) = 1; % all of it is exertion
end

% Boxcar average the data by n samples 

length_b = floor(length_emg/n);  
avg_filt_emg = zeros(length_b, num_emg_signals + 1);

% average EMG signals, round exertion
for i=1:length_b
    
   % average EMG signals  
   for j=1:num_emg_signals
      avg_filt_emg(i,j) = mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,j));
   end
   % round exertion
   avg_filt_emg(i,9) = round(mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,9)));
    
end

% Concat with base matrix; 
result = [result; avg_filt_emg];


%% Process 1 data file 
str_emg = 'Fist60s';
base_emg = csvread(strcat('06161/emg',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

% rectify the signal 
rect_signal  = abs(base_emg);

% Filtering all 8 EMG signals
filt_emg_signal = zeros(length_emg, num_emg_signals + 1 ); 
% added one for classifaction
for i=1:num_emg_signals
  filt_emg_signal(:,i)=filter(b_e,a_e,rect_signal(:,i)); 
    
end

% Custom label the data 
% None of it is exertion
% for i =1:length_emg
%     
% end


% Boxcar average the data by n samples 

length_b = floor(length_emg/n);  
avg_filt_emg = zeros(length_b, num_emg_signals + 1);

% average EMG signals, round exertion
for i=1:length_b
    
   % average EMG signals  
   for j=1:num_emg_signals
      avg_filt_emg(i,j) = mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,j));
   end
   % round exertion
   avg_filt_emg(i,9) = round(mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,9)));
    
end

% Concat with base matrix; 
result = [result; avg_filt_emg];


%% Process 1 data file 
str_emg = 'Pinch60s';
base_emg = csvread(strcat('06161/emg',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

% rectify the signal 
rect_signal  = abs(base_emg);

% Filtering all 8 EMG signals
filt_emg_signal = zeros(length_emg, num_emg_signals + 1 ); 
% added one for classifaction
for i=1:num_emg_signals
  filt_emg_signal(:,i)=filter(b_e,a_e,rect_signal(:,i)); 
    
end

% Custom label the data 
% None of it is exertion
% for i =1:length_emg
%     
% end

% Boxcar average the data by n samples 

length_b = floor(length_emg/n);  
avg_filt_emg = zeros(length_b, num_emg_signals + 1);

% average EMG signals, round exertion
for i=1:length_b
    
   % average EMG signals  
   for j=1:num_emg_signals
      avg_filt_emg(i,j) = mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,j));
   end
   % round exertion
   avg_filt_emg(i,9) = round(mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,9)));
    
end

% Concat with base matrix; 
result = [result; avg_filt_emg];



%% Process 1 data file 
str_emg = 'WaveLeft60s';
base_emg = csvread(strcat('06161/emg',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

% rectify the signal 
rect_signal  = abs(base_emg);

% Filtering all 8 EMG signals
filt_emg_signal = zeros(length_emg, num_emg_signals + 1 ); 
% added one for classifaction
for i=1:num_emg_signals
  filt_emg_signal(:,i)=filter(b_e,a_e,rect_signal(:,i)); 
    
end

% Custom label the data 
% None of it is exertion
% for i =1:length_emg
%     
% end

% Boxcar average the data by n samples 

length_b = floor(length_emg/n);  
avg_filt_emg = zeros(length_b, num_emg_signals + 1);

% average EMG signals, round exertion
for i=1:length_b
    
   % average EMG signals  
   for j=1:num_emg_signals
      avg_filt_emg(i,j) = mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,j));
   end
   % round exertion
   avg_filt_emg(i,9) = round(mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,9)));
    
end

% Concat with base matrix; 
result = [result; avg_filt_emg];


%% Process 1 data file 
str_emg = 'WaveRight60s';
base_emg = csvread(strcat('06161/emg',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

% rectify the signal 
rect_signal  = abs(base_emg);

% Filtering all 8 EMG signals
filt_emg_signal = zeros(length_emg, num_emg_signals + 1 ); 
% added one for classifaction
for i=1:num_emg_signals
  filt_emg_signal(:,i)=filter(b_e,a_e,rect_signal(:,i)); 
    
end

% Custom label the data 
% None of it is exertion
% for i =1:length_emg
%     
% end

% Boxcar average the data by n samples 

length_b = floor(length_emg/n);  
avg_filt_emg = zeros(length_b, num_emg_signals + 1);

% average EMG signals, round exertion
for i=1:length_b
    
   % average EMG signals  
   for j=1:num_emg_signals
      avg_filt_emg(i,j) = mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,j));
   end
   % round exertion
   avg_filt_emg(i,9) = round(mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,9)));
    
end

% Concat with base matrix; 
result = [result; avg_filt_emg];


%% Process 1 data file 
str_emg = 'SpreadFingers60s';
base_emg = csvread(strcat('06161/emg',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

% rectify the signal 
rect_signal  = abs(base_emg);

% Filtering all 8 EMG signals
filt_emg_signal = zeros(length_emg, num_emg_signals + 1 ); 
% added one for classifaction
for i=1:num_emg_signals
  filt_emg_signal(:,i)=filter(b_e,a_e,rect_signal(:,i)); 
    
end

% Custom label the data 
% None of it is exertion
% for i =1:length_emg
%     
% end

% Boxcar average the data by n samples 

length_b = floor(length_emg/n);  
avg_filt_emg = zeros(length_b, num_emg_signals + 1);

% average EMG signals, round exertion
for i=1:length_b
    
   % average EMG signals  
   for j=1:num_emg_signals
      avg_filt_emg(i,j) = mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,j));
   end
   % round exertion
   avg_filt_emg(i,9) = round(mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,9)));
    
end

% Concat with base matrix; 
result = [result; avg_filt_emg];


%% Process 1 data file 
str_emg = 'Grasp15lb';
base_emg = csvread(strcat('06161/emg',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

% rectify the signal 
rect_signal  = abs(base_emg);

% Filtering all 8 EMG signals
filt_emg_signal = zeros(length_emg, num_emg_signals + 1 ); 
% added one for classifaction
for i=1:num_emg_signals
  filt_emg_signal(:,i)=filter(b_e,a_e,rect_signal(:,i)); 
    
end

% Custom label the data 
for i =1:length_emg
   % if it is the second half of a 10s interval, it was an exertion
   if mod(i, 2000) > 1000
       filt_emg_signal(i,9)=1;
   end
end


% Boxcar average the data by n samples 

length_b = floor(length_emg/n);  
avg_filt_emg = zeros(length_b, num_emg_signals + 1);

% average EMG signals, round exertion
for i=1:length_b
    
   % average EMG signals  
   for j=1:num_emg_signals
      avg_filt_emg(i,j) = mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,j));
   end
   % round exertion
   avg_filt_emg(i,9) = round(mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,9)));
    
end


csvwrite('plotset.csv', avg_filt_emg);

% Concat with base matrix; 
result = [result; avg_filt_emg];





%% Process 1 data file 
str_emg = 'Grasp25lb';
base_emg = csvread(strcat('06161/emg',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

% rectify the signal 
rect_signal  = abs(base_emg);

% Filtering all 8 EMG signals
filt_emg_signal = zeros(length_emg, num_emg_signals + 1 ); 
% added one for classifaction
for i=1:num_emg_signals
  filt_emg_signal(:,i)=filter(b_e,a_e,rect_signal(:,i)); 
    
end

% Custom label the data 
for i =1:length_emg
   % if it is the second half of a 10s interval, it was an exertion
   if mod(i, 2000) > 1000
       filt_emg_signal(i,9)=1;
   end
end

% Boxcar average the data by n samples 

length_b = floor(length_emg/n);  
avg_filt_emg = zeros(length_b, num_emg_signals + 1);

% average EMG signals, round exertion
for i=1:length_b
    
   % average EMG signals  
   for j=1:num_emg_signals
      avg_filt_emg(i,j) = mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,j));
   end
   % round exertion
   avg_filt_emg(i,9) = round(mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,9)));
    
end

% Concat with base matrix; 
result = [result; avg_filt_emg];



%% Process 1 data file 
str_emg = 'Pull25lb';
base_emg = csvread(strcat('06161/emg',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

% rectify the signal 
rect_signal  = abs(base_emg);

% Filtering all 8 EMG signals
filt_emg_signal = zeros(length_emg, num_emg_signals + 1 ); 
% added one for classifaction
for i=1:num_emg_signals
  filt_emg_signal(:,i)=filter(b_e,a_e,rect_signal(:,i)); 
    
end

% Custom label the data 
for i =1:length_emg
   % if it is the second half of a 10s interval, it was an exertion
   if mod(i, 2000) > 1000
       filt_emg_signal(i,9)=1;
   end
end

% Boxcar average the data by n samples 

length_b = floor(length_emg/n);  
avg_filt_emg = zeros(length_b, num_emg_signals + 1);

% average EMG signals, round exertion
for i=1:length_b
    
   % average EMG signals  
   for j=1:num_emg_signals
      avg_filt_emg(i,j) = mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,j));
   end
   % round exertion
   avg_filt_emg(i,9) = round(mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,9)));
    
end

% Concat with base matrix; 
result = [result; avg_filt_emg];

%% Process 1 data file 
str_emg = 'Push25lb';
base_emg = csvread(strcat('06161/emg',str_emg,'.csv'));

length_emg = size(base_emg,1);
num_emg_signals = size(base_emg,2);

% rectify the signal 
rect_signal  = abs(base_emg);

% Filtering all 8 EMG signals
filt_emg_signal = zeros(length_emg, num_emg_signals + 1 ); 
% added one for classifaction
for i=1:num_emg_signals
  filt_emg_signal(:,i)=filter(b_e,a_e,rect_signal(:,i)); 
    
end

% Custom label the data 
for i =1:length_emg
   % if it is the second half of a 10s interval, it was an exertion
   if mod(i, 2000) > 1000
       filt_emg_signal(i,9)=1;
   end
end

% Boxcar average the data by n samples 

length_b = floor(length_emg/n);  
avg_filt_emg = zeros(length_b, num_emg_signals + 1);

% average EMG signals, round exertion
for i=1:length_b
    
   % average EMG signals  
   for j=1:num_emg_signals
      avg_filt_emg(i,j) = mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,j));
   end
   % round exertion
   avg_filt_emg(i,9) = round(mean(filt_emg_signal(n*(i-1)+1:n*(i-1)+n,9)));
    
end

% Concat with base matrix; 
result = [result; avg_filt_emg];



%% Save to file 
csvwrite('FiltNLabeled.csv',result);

