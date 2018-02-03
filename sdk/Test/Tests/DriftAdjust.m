%% 

plot_offset = false;
no_reset = true;

%% Therblig loading Label files

% This file helds the labeled therbligs in video time 
fileID = fopen('07313/0731EricHTherblig.txt','r');


%% Read labels from video
 
% 'Rest'                1
% 'Transport_Empty'     2
% 'Transport_Loaded'    3
% 'held'                4
% 'Grasp'               5
% 'Release_Load'        6

%% TODO use this: 
key = {'Rest';'Transport_Empty'; 'Transport_Loaded'; ...
    'Hold';'Grasp'; 'Release_Load'};

temp = fgetl(fileID);
therbligs = [];
rest = [];
transport_empty = [];
transport_loaded = [];
held = [];
grasp = [];
release_load = []; 

counter = 0;
r = 0; te = 0; tl = 0; h = 0; g = 0; rl = 0;

name = 0;

while ischar(temp)
    
    counter = counter + 1; 
    
    temp = strsplit (temp);
    start_time = str2double (temp{2});
    end_time = str2double (temp{3});
    strname = temp{4};
    
    if strcmp (strname, 'Rest')
        r = r+1;
        name = 1;
        rest(r, 1) = start_time;
        rest(r, 2) = end_time;
    elseif strcmp (strname, 'Transport_Empty')
        te = te+1;
        name = 2;
        transport_empty(te, 1) = start_time;
        transport_empty(te, 2) = end_time;
    elseif strcmp (strname, 'Transport_Loaded')
        tl = tl+1;
        name = 3;
        transport_loaded(tl, 1) = start_time;
        transport_loaded(tl, 2) = end_time;
    elseif strcmp (strname, 'Hold')
        h = h+1;
        name = 4;
        held(h, 1) = start_time;
        held(h, 2) = end_time;
    elseif strcmp (strname, 'Grasp')
        g = g+1;
        name = 5;
        grasp(g, 1) = start_time;
        grasp(g, 2) = end_time;
    elseif strcmp (strname, 'Release_Load')
        rl = rl+1;
        name = 6;
        release_load(rl, 1) = start_time;
        release_load(rl, 2) = end_time;
    end
    
    therbligs(counter, 1) = start_time;
    therbligs(counter, 2) = end_time;
    therbligs(counter, 3) = name;
    
    temp = fgetl(fileID);
end


%% Offset calculation 

% from EMG fist estimate 
vid_mark = [294/20, 331/20, 368/20]; % software estimates at 20 FPS.
guess_mark = [2.156, 3.937, 5.883];
offset = mean(vid_mark - guess_mark); % Myo is ~ 5.09s delayed. 

% from video


%% File for Myo EMG Reading - 200 Hz 
% 8 emg sensors 
str_emg = 'emg';
base_emg = csvread(strcat('07031/',str_emg,'.csv'));

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

% Saved Filtered Data for Oguz 
%csvwrite('06271/filtEMGOguz.csv', filt_emg_signal);

%% Temporary plot to estimate beginning fist times 
% Weighting EMG values

sum_EMG= zeros(length_emg,1);
for i=1:length_emg
    sum_EMG(i) =mean(filt_emg_signal(i,:));    
end

% Plot 

if (plot_offset)
    
    y_max=127;
    T_e=round(2000/Fse);
    figure(1000);
    x_e=linspace(0,T_e,2000);
    plot(x_e,sum_EMG(1:2000,:));
    axis([0,T_e,0,y_max]);
    title('Average of EMG signals');
    ylabel('Unsigned 8 bit int');
    xlabel('time (s)');
end



%% File for Accel Reading - 50 Hz
str_acc = 'worldAccelH';
base_acc = csvread(strcat('07313/',str_acc,'.csv'));


% Plot Original Acceleration Signals 

length_acc = size(base_acc,1);
num_acc_signals = size(base_acc,2);

%Incoming signal is at 50 Hz 
Fsa = 50;


y_max=15;
T_a=round(length_acc/Fsa);

% Plot original signal 

for i=1:3
    figure(i);
    x_a=linspace(0,T_a,length_acc);
    plot(x_a,base_acc(:,i));
    axis([0,T_a,-y_max,y_max]);
    title(['Axis ', num2str(i)]);
    ylabel('m/s^2');
    xlabel('time (s)');
end


%% Mean subtract raw Accel and see if there's drift

%% get some averages of the data
acc_avg = zeros(num_acc_signals,1);
for i=1:num_acc_signals
    acc_avg(i) = mean(base_acc(1:length_acc,i));
end

sub_acc_signal=zeros(length_acc,num_acc_signals);

for i=1:num_acc_signals
  sub_acc_signal(:,i)=base_acc(:,i) - acc_avg(i);
end

%% Mean subtracted acceleration 


for i=1:3
    figure(3+i);
    x_a=linspace(0,T_a,length_acc);
    plot(x_a,sub_acc_signal(:,i));
    axis([0,T_a,-5,5]);
    title(['Mean Subtracted -Axis ', num2str(i)]);
    ylabel('m/s^2');
    xlabel('time (s)');
end


%% Calculating Velocity - reset for empty therbligs

dt = 1/Fsa; 


% fill all indices with -1
velocity = -1*ones(length_acc, num_acc_signals);

% set the initial velocity to be zero 
velocity(1,:) = 0;

% set 0 for grasp/release loads 


centers = [];

for i=1:size(therbligs, 1)
    type = therbligs(i,3);
    
    if ( type > 4 )  % Grasp and Release Load are 5,6
        start = round( (therbligs(i,1) - offset)  *50);
        finish = round( (therbligs(i,2) - offset) *50);
        
        %% Try setting only one value to 0 
        center = round(mean(start,finish));
        
        centers = [centers, center];
        
        for j=1:num_acc_signals
           velocity(center,j) = 0; 
        end
       
        
        %% Set all values to 0 
%         for j =1:num_acc_signals
%            for k=start:finish
%                 velocity(k,j) = 0;
%            end
%         end
        
    end
end


% Calculate Velocity

final_time = therbligs(size(therbligs,1),2); % last therblig end time

for i=1:num_acc_signals 
    for j=2:length_acc 
        
        % don't calculate past labeled data
        if j > round( (final_time-offset)*50)
                velocity(j,i) = 0;         
        elseif velocity(j,i) == -1 % calculate only non-computed 
            velocity(j,i) = velocity(j-1,i) + sub_acc_signal(j-1,i)*dt;
        end
    end
end

if (no_reset)
    velocity = zeros(length_acc, num_acc_signals);
    for i=1:num_acc_signals 
        for j=2:length_acc  
            velocity(j,i) = velocity(j-1,i) + sub_acc_signal(j-1,i)*dt;
        end
    end
end

%% Calculate RMS 
vel_sq = velocity.^2;

RMS= zeros(length_acc,1);
for i=1:length_acc
    temp_sum=0;
    for j =1:num_acc_signals
       temp_sum=temp_sum + vel_sq(i,j); 
    end
    RMS(i)=sqrt(1/num_acc_signals*temp_sum);
end


%% Calculate held indices

helds = zeros(length_acc,1);

for i=1:size(held, 1)
    start = round( (held(i,1) - offset)  *50);
    finish = round( (held(i,2) - offset) *50);
    
    for j =1:num_acc_signals
           for k=start:finish
                helds(k,j) = 1; % label it as positive
           end
        end
    
end

%% Plot Velocity

for i=1:3
    
figure(6+i);
x_a=linspace(0,T_a,length_acc);
hold on
plot(x_a, velocity(:,i));

for j=1:size(centers,2)
    x = [centers(j)/50, centers(j)/50];
    y = [-1,1];
    line(x,y, 'color', 'r');
end



hold off
title(['Velocity along axis ', num2str(i)]);
ylabel('m/s');
xlabel('time (s)');
end
%% Plot RMS Data 
% RMS Speed 
T_a=round(length_acc/Fsa);
figure(10);
x_a=linspace(0,T_a,length_acc);

hold on
plot(x_a,RMS);
plot(x_a, helds);

hold off


%axis([0,T_v,0,y_max]);
title('Armband RMS Speed');
ylabel('mm/s');
xlabel('time (s)');

