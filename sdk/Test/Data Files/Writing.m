%% Preprocessing.m 

fileChoice = 2; 
options = 1; % 1 for 6 outputs; 
             % 2 for 4 outputs; 
             % 3 for 4 outputs with merging
             % 4 for exertion/non exertion
            
% Option 3 is not true
subinterval_time = 0.2;
 
%% offset estimate between video and Myo

if (fileChoice == 1)
    
    vid_mark = [294/20, 331/20, 368/20];
    guess_mark = [2.156, 3.937, 5.883];
    offset = mean(vid_mark - guess_mark); % Myo is ~ 4.7s delayed.
 
    folder_name = '07313';
    str_file = '0731EricHTherblig';
    str_acc_w = 'worldAccelH';
    str_emg = 'emgH';

elseif (fileChoice == 2) 
   
    vid_mark = [214/17, 241/17, 271/17];
    guess_mark = [1.811,3.357, 5.338  ];
    offset = mean(vid_mark - guess_mark);
    folder_name = '07313';
    str_file = '0731EricWTherblig';
    str_acc_w = 'worldAccelW';
    str_emg = 'emgW';
    
end

%% Close figures
 
fh=findall(0,'type','figure');
for i=1:length(fh)
     clo(fh(i));
end

%% Label files

fileID = fopen(strcat(folder_name, '/',str_file,'.txt'),'r');
 
%% File for world oriented Myo Accel Reading - 50 Hz 
 
base_acc_w = csvread(strcat(folder_name, '/',str_acc_w,'.csv'));

Fsa = 50;
length_acc_w = size(base_acc_w,1);
num_acc_signals_w = size(base_acc_w,2);

% base_acc_w(:,3) = base_acc_w(:,3) - 9.8;
for i=1:num_acc_signals_w
    mu = mean (base_acc_w (:,i));
    for j=1:length_acc_w
        base_acc_w (j,i) = base_acc_w (j,i) - mu;
    end
end
 
%% File for Myo EMG Reading - 200 Hz 
% 8 emg sensors 
base_emg = csvread(strcat(folder_name, '/',str_emg,'.csv'));
 
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
 
y_max_e = zeros(num_emg_signals, 1);
 
%% Convert EMG signals from 200 Hz to 50 Hz
length_emg_avg = round (length_emg / 4);
filt_emg_signal_avg = zeros(length_emg_avg, num_emg_signals);
for i=1:num_emg_signals
    for j=1:length_emg_avg
        sum = 0.0;
        cnt = 0;
        for k=1:4
            if j*4+k-4 <= length_emg
                sum = sum+filt_emg_signal(j*4+k-4,i);
                cnt = cnt+1.0;
            end
        end
        filt_emg_signal_avg(j,i) = sum/cnt;
        
        if j >= 500 && filt_emg_signal_avg(j,i) > y_max_e(i)
            y_max_e(i) = filt_emg_signal_avg(j,i);
        end
    end
end
 
 
% sum the magnitude 
 
temp = base_acc_w;
mag_acc = zeros(length_acc_w, 1);
 
for i=1:length_acc_w
    mag_acc(i) = sqrt(temp(i,1)^2 + temp(i,2)^2 + temp(i,3)^2 );
end
 
% 3 point average - smooth out signal a little 
temp = zeros(length_acc_w, 1);
 
for i=2:length_acc_w-2
    temp(i) = mean(mag_acc(i-1:i+1));
end
mag_acc = temp;
 
%% Read labels from video
 
% 'Rest'                1
% 'Transport_Empty'     2
% 'Transport_Loaded'    3
% 'Hold'                4
% 'Grasp'               5
% 'Release_Load'        6
temp = fgetl(fileID);
therbligs = [];

counter = 0;
name = 0;
 
while ischar(temp)
    counter = counter + 1; 
    
    temp = strsplit (temp);
    
    start_time = str2double (temp{2});
    end_time = str2double (temp{3});
    name = temp{4};
    
    if strcmp (name, 'Rest')
        name = 1;
    elseif strcmp (name, 'Transport_Empty')
        if  (options == 4)
            name = 1;
        else
            name = 2;
        end
    elseif strcmp (name, 'Transport_Loaded')
        if  (options == 4)
            name = 2;
        else
            name = 3;
        end
    elseif strcmp (name, 'Hold')
        if  (options == 4)
            name = 2;
        else
            name = 4;
        end
    elseif strcmp (name, 'Grasp')
        if  (options == 3)
            name = 2;
        elseif (options == 4)
            name = 1;
        else
            name = 5;
        end
    elseif strcmp (name, 'Release_Load')
        if  (options == 3)
            name = 3;
        elseif (options == 4)
            name = 2;
        else
            name = 6;
        end
        
    end
    
    if (name <= 4) | ((options == 1) & (name <= 6))
        therbligs(counter, 1) = start_time;
        therbligs(counter, 2) = end_time;
        therbligs(counter, 3) = name;
    end
    
    temp = fgetl(fileID);
end

%% Create Data for Training
 
length_therbligs = size (therbligs, 1);
subinterval_frame = round (subinterval_time * Fsa);

X_data = [];
y_data = [];

id = 1;

% Normalized
for i=1:num_emg_signals
    mx = max (filt_emg_signal_avg(:,i));
    for j=1:length_emg_avg
        filt_emg_signal_avg(j,i) = filt_emg_signal_avg(j,i) / mx;
    end
end
for i=1:num_acc_signals_w
    mx = max (base_acc_w(:,i));
    for j=1:length_acc_w
        base_acc_w(j,i) = base_acc_w(j,i) / mx;
    end
end
mx = max (mag_acc(:));
for j=1:length_acc_w
    mag_acc(j) = mag_acc(j) / mx;
end

for num=1:length_therbligs
    label = therbligs(num,3);
    
    time_start = therbligs(num,1) - offset;
    time_end = therbligs(num,2) - offset;
    frame_start = round (time_start * Fsa);
    frame_end = round (time_end * Fsa);
    frame_length = frame_end - frame_start + 1;
    
    for st=frame_start:subinterval_frame:(frame_end-subinterval_frame+1)
        ed = st + subinterval_frame - 1;

        X = [];
        for i=1:num_emg_signals
            mu = mean (filt_emg_signal_avg(st:ed,i));
            X = [X; mu];
%             X = [X; filt_emg_signal_avg(st:ed,i)];
        end
        for i=1:num_acc_signals_w
            mu = mean (base_acc_w(st:ed,i));
            X = [X; mu];
%             X = [X; base_acc_w(st:ed,i)];
        end
        mu = mean (mag_acc(st:ed));
        X = [X; mu];
%         X = [X; mag_acc(st:ed)];
        
        if (options ==2 || options == 3)
            y = zeros (4, 1);
        elseif (options == 4) 
            y = zeros (2, 1);
        else
            y = zeros(6,1);
        end
        y (label) = 1;
        
        X_data = [X_data, X];
        y_data = [y_data, y];
    end
end

%% Save data as csv file

csvwrite(strcat(str_file,'_X.csv'), X_data);
csvwrite(strcat(str_file,'_y.csv'), y_data);
