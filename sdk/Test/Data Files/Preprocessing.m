%% Preprocessing.m 
 
enable_plot = false;
subinterval_time = 0.2;
 
%% offset estimate between video and Myo 
vid_mark = [148/20, 202/20, 264/20]; % software estimates at 30 FPS.
guess_mark = [2.461, 5.523, 8.579];
offset = mean(vid_mark - guess_mark); % Myo is ~ 4.7s delayed.
 
%% Close figures
 
fh=findall(0,'type','figure');
for i=1:length(fh)
     clo(fh(i));
end
 
%% Label files
 
fileID = fopen('07312/0731KrittisakHTherblig.txt','r');
 
%% File for world oriented Myo Accel Reading - 50 Hz 
 
str_acc_w = 'worldAccelH';
base_acc_w = csvread(strcat('07312/',str_acc_w,'.csv'));
base_acc_w(:,3) = base_acc_w(:,3) - 9.8;
 
Fsa = 50;
length_acc_w = size(base_acc_w,1);
num_acc_signals_w = size(base_acc_w,2);
 
%% File for Myo EMG Reading - 200 Hz 
% 8 emg sensors 
str_emg = 'emgH';
base_emg = csvread(strcat('07312/',str_emg,'.csv'));
 
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
 
%% Temporary plot to estimate beginning  fist times 
 
if enable_plot
    % Weighting EMG values
 
    %weight order - based on positions of myo and physiology;
    weights=[.20, .20, .05, .05, .10, .10, .10, .20];
 
    sum_EMG= zeros(length_emg,1);
    for i=1:length_emg
        temp_sum=0;
        for j=1:num_emg_signals
        temp_sum = temp_sum + filt_emg_signal(i,j)*weights(j);
        end
        sum_EMG(i)=temp_sum;
 
    end
 
    % Plot 
 
    y_max=127;
    T_e=round(2000/Fse);
    figure(1000);
    x_e=linspace(0,T_e,2000);
    plot(x_e,sum_EMG(1:2000,:));
    axis([0,T_e,0,y_max]);
    title('Weighted Average of EMG signals');
    ylabel('Unsigned 8 bit int');
    xlabel('time (s)');
end
 
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
 
%% Plot Filtered EMG Data
 
if enable_plot
    f = figure(1);
    p = uipanel('Parent',f,'BorderType','none'); 
    p.Title = ['Overview']; 
    p.TitlePosition = 'centertop'; 
    p.FontSize = 12;
    p.FontWeight = 'bold';
 
    for i=1:num_emg_signals
        ax = subplot(12,1,i,'Parent',p);
        y_max=80;
        T_e = round(length_emg_avg/Fsa);
        x=linspace(0,T_e,length_emg_avg);
        plot(ax,x,filt_emg_signal_avg(:,i));
        axis([0,T_e,0,y_max]);
        ylabel(strcat ('emg ', int2str (i)));
    end
 
    %% Plot Raw Acceleration Data
    for i=1:num_acc_signals_w
        ax = subplot(12,1,8+i,'Parent',p);
        y_max=1.2*max(abs(base_acc_w(:,i)));
        T_a=round(length_acc_w/Fsa);
        x_a=linspace(0,T_a,length_acc_w);
        plot(ax,x_a,base_acc_w(:,i));
        axis([0,T_a,-y_max,y_max]);
        ylabel(strcat ('acc ', int2str (i)));
    end
 
    %% Plot Acceleration Magnitude 
 
    ax = subplot (12,1,12,'Parent',p);
    y_max=max(mag_acc);
    T_a=round(length_acc_w/Fsa);
    x_a=linspace(0,T_a,length_acc_w);
    plot(ax,x_a,mag_acc);
    axis([0,T_a,0,y_max]);
    ylabel('mag acc');
end
 
%% Read labels from video
 
% 'Rest'                1
% 'Transport_Empty'     2
% 'Transport_Loaded'    3
% 'Hold'                4
% 'Grasp'               5
% 'Release_Load'        6
temp = fgetl(fileID);
temp = fgetl(fileID);
therbligs = cell (0,3);
rest = cell (0,3);
transport_empty = cell (0,3);
transport_loaded = cell (0,3);
hold = cell (0,3);
grasp = cell (0,3);
release_load = cell (0,3);
 
while ischar(temp)
    temp = strsplit (temp);
    
    start_time = str2double (temp{2});
    end_time = str2double (temp{3});
    name = temp{4};
    
    if strcmp (name, 'Rest')
        rest{end + 1, 1} = start_time;
        rest{end, 2} = end_time;
        rest{end, 3} = name;
        name = 1;
    elseif strcmp (name, 'Transport_Empty')
        transport_empty{end + 1, 1} = start_time;
        transport_empty{end, 2} = end_time;
        transport_empty{end, 3} = name;
        name = 2;
    elseif strcmp (name, 'Transport_Loaded')
        transport_loaded{end + 1, 1} = start_time;
        transport_loaded{end, 2} = end_time;
        transport_loaded{end, 3} = name;
        name = 3;
    elseif strcmp (name, 'Hold')
        hold{end + 1, 1} = start_time;
        hold{end, 2} = end_time;
        hold{end, 3} = name;
        name = 4;
    elseif strcmp (name, 'Grasp')
        grasp{end + 1, 1} = start_time;
        grasp{end, 2} = end_time;
        grasp{end, 3} = name;
        name = 5;
    elseif strcmp (name, 'Release_Load')
        release_load{end + 1, 1} = start_time;
        release_load{end, 2} = end_time;
        release_load{end, 3} = name;
        name = 6;
    end
    
    therbligs{end + 1, 1} = start_time;
    therbligs{end, 2} = end_time;
    therbligs{end, 3} = name;
    
    temp = fgetl(fileID);
end
 
%% Plot each therblig subinterval
 
length_therbligs = size (therbligs, 1);

for num=2:9%length_therbligs
    name = therbligs{num,3};
    if name == 1
        name = 'Rest';
    elseif name == 2
        name = 'Transport_Empty';
    elseif name == 3
        name = 'Transport_Loaded';
    elseif name == 4
        name = 'Hold';
    elseif name == 5
        name = 'Grasp';
    elseif name == 6
        name = 'Release_Load';
    end
    
    f = figure(1+num);
    p = uipanel('Parent',f,'BorderType','none'); 
    p.Title = [name]; 
    p.TitlePosition = 'centertop'; 
    p.FontSize = 12;
    p.FontWeight = 'bold';
    
    time_start = therbligs{num,1} - offset;
    time_end = therbligs{num,2} - offset;
    frame_start = round (time_start * 50);
    frame_end = round (time_end * 50);
    frame_length = frame_end - frame_start + 1;
    
    %% Plot Filtered EMG Data
    for i=1:num_emg_signals
        ax = subplot(12,1,i,'Parent',p);
        y_max=y_max_e(i);
        x=linspace(time_start,time_end,frame_length);
        plot(ax,x,filt_emg_signal_avg(frame_start:frame_end,i));
        axis([time_start,time_end,0,y_max]);
        ylabel(strcat ('emg ', int2str (i)));
    end
    
    %% Plot Raw Acceleration Data
    for i=1:num_acc_signals_w
        ax = subplot(12,1,8+i,'Parent',p);
        y_max=5;
        x_a=linspace(time_start,time_end,frame_length);
        plot(ax,x_a,base_acc_w(frame_start:frame_end,i));
        axis([time_start,time_end,-y_max,y_max]);
        ylabel(strcat ('acc ', int2str (i)));
    end

    %% Plot Acceleration Magnitude
    ax = subplot (12,1,12,'Parent',p);
    y_max=5;%max(mag_acc);
    x_a=linspace(time_start,time_end,frame_length);
    plot(ax,x_a,mag_acc(frame_start:frame_end));
    axis([time_start,time_end,0,y_max]);
    ylabel('mag acc');
end
 
if enable_plot
    %% Rest
 
    temp = rest
 
    if size (temp, 1) > 0
        f = figure(1001);
        p = uipanel('Parent',f,'BorderType','none'); 
        p.Title = ['Rest']; 
        p.TitlePosition = 'centertop'; 
        p.FontSize = 12;
        p.FontWeight = 'bold';
 
        emg = [];
        acc = [];
        acc_m = [];
 
        for num=1:size(temp,1)
            time_start = temp{num,1} - offset;
            time_end = temp{num,2} - offset;
            frame_start = round (time_start * Fsa);
            frame_end = round (time_end * Fsa);
 
            g = []
            for i=1:num_emg_signals
                g = [g,filt_emg_signal_avg(frame_start:frame_end,i)];
            end
            emg = [emg;g];
 
            g = []
            for i=1:num_acc_signals_w
                g = [g,base_acc_w(frame_start:frame_end,i)];
            end
            acc = [acc;g];
 
            acc_m = [acc_m,mag_acc(frame_start:frame_end)'];
        end
 
        frame_length = size (emg, 1)
 
        for i=1:num_emg_signals
            ax = subplot(12,1,i,'Parent',p);
            y_max=y_max_e(i);
            x=linspace(0,frame_length,frame_length);
            plot(ax,x,emg(:,i));
            axis([0,frame_length,0,y_max]);
            ylabel(strcat ('emg ', int2str (i)));
        end
 
        for i=1:num_acc_signals_w
            ax = subplot(12,1,8+i,'Parent',p);
            y_max=5;%1.2*max(abs(base_acc_w(:,i)));
            x_a=linspace(0,frame_length,frame_length);
            plot(ax,x_a,acc(:,i));
            axis([0,frame_length,-y_max,y_max]);
            ylabel(strcat ('acc ', int2str (i)));
        end
 
        ax = subplot (12,1,12,'Parent',p);
        y_max=5;%max(mag_acc);
        x_a=linspace(0,frame_length,frame_length);
        plot(ax,x_a,acc_m);
        axis([0,frame_length,0,y_max]);
        ylabel('mag acc');
    end
 
    %% Transport Empty
 
    temp = transport_empty
 
    if size (temp, 1) > 0
        f = figure(1002);
        p = uipanel('Parent',f,'BorderType','none'); 
        p.Title = ['Transport Empty']; 
        p.TitlePosition = 'centertop'; 
        p.FontSize = 12;
        p.FontWeight = 'bold';
 
        emg = [];
        acc = [];
        acc_m = [];
 
        for num=1:size(temp,1)
            time_start = temp{num,1} - offset;
            time_end = temp{num,2} - offset;
            frame_start = round (time_start * Fsa);
            frame_end = round (time_end * Fsa);
 
            g = []
            for i=1:num_emg_signals
                g = [g,filt_emg_signal_avg(frame_start:frame_end,i)];
            end
            emg = [emg;g];
 
            g = []
            for i=1:num_acc_signals_w
                g = [g,base_acc_w(frame_start:frame_end,i)];
            end
            acc = [acc;g];
 
            acc_m = [acc_m,mag_acc(frame_start:frame_end)'];
        end
 
        frame_length = size (emg, 1)
 
        for i=1:num_emg_signals
            ax = subplot(12,1,i,'Parent',p);
            y_max=y_max_e(i);
            x=linspace(0,frame_length,frame_length);
            plot(ax,x,emg(:,i));
            axis([0,frame_length,0,y_max]);
            ylabel(strcat ('emg ', int2str (i)));
        end
 
        for i=1:num_acc_signals_w
            ax = subplot(12,1,8+i,'Parent',p);
            y_max=5;%1.2*max(abs(base_acc_w(:,i)));
            x_a=linspace(0,frame_length,frame_length);
            plot(ax,x_a,acc(:,i));
            axis([0,frame_length,-y_max,y_max]);
            ylabel(strcat ('acc ', int2str (i)));
        end
 
        ax = subplot (12,1,12,'Parent',p);
        y_max=5;%max(mag_acc);
        x_a=linspace(0,frame_length,frame_length);
        plot(ax,x_a,acc_m);
        axis([0,frame_length,0,y_max]);
        ylabel('mag acc');
    end
 
    %% Transport Loaded
 
    temp = transport_loaded
 
    if size (temp, 1) > 0
        f = figure(1003);
        p = uipanel('Parent',f,'BorderType','none'); 
        p.Title = ['Transport Loaded']; 
        p.TitlePosition = 'centertop'; 
        p.FontSize = 12;
        p.FontWeight = 'bold';
 
        emg = [];
        acc = [];
        acc_m = [];
 
        for num=1:size(temp,1)
            time_start = temp{num,1} - offset;
            time_end = temp{num,2} - offset;
            frame_start = round (time_start * Fsa);
            frame_end = round (time_end * Fsa);
 
            g = []
            for i=1:num_emg_signals
                g = [g,filt_emg_signal_avg(frame_start:frame_end,i)];
            end
            emg = [emg;g];
 
            g = []
            for i=1:num_acc_signals_w
                g = [g,base_acc_w(frame_start:frame_end,i)];
            end
            acc = [acc;g];
 
            acc_m = [acc_m,mag_acc(frame_start:frame_end)'];
        end
 
        frame_length = size (emg, 1)
 
        for i=1:num_emg_signals
            ax = subplot(12,1,i,'Parent',p);
            y_max=y_max_e(i);
            x=linspace(0,frame_length,frame_length);
            plot(ax,x,emg(:,i));
            axis([0,frame_length,0,y_max]);
            ylabel(strcat ('emg ', int2str (i)));
        end
 
        for i=1:num_acc_signals_w
            ax = subplot(12,1,8+i,'Parent',p);
            y_max=5;%1.2*max(abs(base_acc_w(:,i)));
            x_a=linspace(0,frame_length,frame_length);
            plot(ax,x_a,acc(:,i));
            axis([0,frame_length,-y_max,y_max]);
            ylabel(strcat ('acc ', int2str (i)));
        end
 
        ax = subplot (12,1,12,'Parent',p);
        y_max=5;%max(mag_acc);
        x_a=linspace(0,frame_length,frame_length);
        plot(ax,x_a,acc_m);
        axis([0,frame_length,0,y_max]);
        ylabel('mag acc');
    end
 
    %% Hold
 
    temp = hold
 
    if size (temp, 1) > 0
        f = figure(1004);
        p = uipanel('Parent',f,'BorderType','none'); 
        p.Title = ['Hold']; 
        p.TitlePosition = 'centertop'; 
        p.FontSize = 12;
        p.FontWeight = 'bold';
 
        emg = [];
        acc = [];
        acc_m = [];
 
        for num=1:size(temp,1)
            time_start = temp{num,1} - offset;
            time_end = temp{num,2} - offset;
            frame_start = round (time_start * Fsa);
            frame_end = round (time_end * Fsa);
 
            g = []
            for i=1:num_emg_signals
                g = [g,filt_emg_signal_avg(frame_start:frame_end,i)];
            end
            emg = [emg;g];
 
            g = []
            for i=1:num_acc_signals_w
                g = [g,base_acc_w(frame_start:frame_end,i)];
            end
            acc = [acc;g];
 
            acc_m = [acc_m,mag_acc(frame_start:frame_end)'];
        end
 
        frame_length = size (emg, 1)
 
        for i=1:num_emg_signals
            ax = subplot(12,1,i,'Parent',p);
            y_max=y_max_e(i);
            x=linspace(0,frame_length,frame_length);
            plot(ax,x,emg(:,i));
            axis([0,frame_length,0,y_max]);
            ylabel(strcat ('emg ', int2str (i)));
        end
 
        for i=1:num_acc_signals_w
            ax = subplot(12,1,8+i,'Parent',p);
            y_max=5;%1.2*max(abs(base_acc_w(:,i)));
            x_a=linspace(0,frame_length,frame_length);
            plot(ax,x_a,acc(:,i));
            axis([0,frame_length,-y_max,y_max]);
            ylabel(strcat ('acc ', int2str (i)));
        end
 
        ax = subplot (12,1,12,'Parent',p);
        y_max=5;%max(mag_acc);
        x_a=linspace(0,frame_length,frame_length);
        plot(ax,x_a,acc_m);
        axis([0,frame_length,0,y_max]);
        ylabel('mag acc');
    end
 
    %% Grasp
 
    temp = grasp
 
    if size (temp, 1) > 0
        f = figure(1005);
        p = uipanel('Parent',f,'BorderType','none'); 
        p.Title = ['Grasp']; 
        p.TitlePosition = 'centertop'; 
        p.FontSize = 12;
        p.FontWeight = 'bold';
 
        emg = [];
        acc = [];
        acc_m = [];
 
        for num=1:size(temp,1)
            time_start = temp{num,1} - offset;
            time_end = temp{num,2} - offset;
            frame_start = round (time_start * Fsa);
            frame_end = round (time_end * Fsa);
 
            g = []
            for i=1:num_emg_signals
                g = [g,filt_emg_signal_avg(frame_start:frame_end,i)];
            end
            emg = [emg;g];
 
            g = []
            for i=1:num_acc_signals_w
                g = [g,base_acc_w(frame_start:frame_end,i)];
            end
            acc = [acc;g];
 
            acc_m = [acc_m,mag_acc(frame_start:frame_end)'];
        end
 
        frame_length = size (emg, 1)
 
        for i=1:num_emg_signals
            ax = subplot(12,1,i,'Parent',p);
            y_max=y_max_e(i);
            x=linspace(0,frame_length,frame_length);
            plot(ax,x,emg(:,i));
            axis([0,frame_length,0,y_max]);
            ylabel(strcat ('emg ', int2str (i)));
        end
 
        for i=1:num_acc_signals_w
            ax = subplot(12,1,8+i,'Parent',p);
            y_max=5;%1.2*max(abs(base_acc_w(:,i)));
            x_a=linspace(0,frame_length,frame_length);
            plot(ax,x_a,acc(:,i));
            axis([0,frame_length,-y_max,y_max]);
            ylabel(strcat ('acc ', int2str (i)));
        end
 
        ax = subplot (12,1,12,'Parent',p);
        y_max=5;%max(mag_acc);
        x_a=linspace(0,frame_length,frame_length);
        plot(ax,x_a,acc_m);
        axis([0,frame_length,0,y_max]);
        ylabel('mag acc');
    end
 
    %% Release Load
 
    temp = release_load
 
    if size (temp, 1) > 0
        f = figure(1006);
        p = uipanel('Parent',f,'BorderType','none'); 
        p.Title = ['Release Load']; 
        p.TitlePosition = 'centertop'; 
        p.FontSize = 12;
        p.FontWeight = 'bold';
 
        emg = [];
        acc = [];
        acc_m = [];
 
        for num=1:size(temp,1)
            time_start = temp{num,1} - offset;
            time_end = temp{num,2} - offset;
            frame_start = round (time_start * Fsa);
            frame_end = round (time_end * Fsa);
 
            g = []
            for i=1:num_emg_signals
                g = [g,filt_emg_signal_avg(frame_start:frame_end,i)];
            end
            emg = [emg;g];
 
            g = []
            for i=1:num_acc_signals_w
                g = [g,base_acc_w(frame_start:frame_end,i)];
            end
            acc = [acc;g];
 
            acc_m = [acc_m,mag_acc(frame_start:frame_end)'];
        end
 
        frame_length = size (emg, 1)
 
        for i=1:num_emg_signals
            ax = subplot(12,1,i,'Parent',p);
            y_max=y_max_e(i);
            x=linspace(0,frame_length,frame_length);
            plot(ax,x,emg(:,i));
            axis([0,frame_length,0,y_max]);
            ylabel(strcat ('emg ', int2str (i)));
        end
 
        for i=1:num_acc_signals_w
            ax = subplot(12,1,8+i,'Parent',p);
            y_max=5;%1.2*max(abs(base_acc_w(:,i)));
            x_a=linspace(0,frame_length,frame_length);
            plot(ax,x_a,acc(:,i));
            axis([0,frame_length,-y_max,y_max]);
            ylabel(strcat ('acc ', int2str (i)));
        end
 
        ax = subplot (12,1,12,'Parent',p);
        y_max=5;%max(mag_acc);
        x_a=linspace(0,frame_length,frame_length);
        plot(ax,x_a,acc_m);
        axis([0,frame_length,0,y_max]);
        ylabel('mag acc');
    end
    
end
 
%% Create Data for Training
 
length_therbligs = size (therbligs, 1);
subinterval_frame = round (subinterval_time * Fsa);

X_data = [];
y_data = [];

id = 1;

for num=1:length_therbligs
    label = therbligs{num,3};
    
    time_start = therbligs{num,1} - offset;
    time_end = therbligs{num,2} - offset;
    frame_start = round (time_start * Fsa);
    frame_end = round (time_end * Fsa);
    frame_length = frame_end - frame_start + 1;
    
    for st=frame_start:subinterval_frame:(frame_end-subinterval_frame+1)
        ed = st + subinterval_frame - 1;

        X = [];
        for i=1:num_emg_signals
            X = [X; filt_emg_signal_avg(st:ed,i)];
        end
        for i=1:num_acc_signals_w
            X = [X; base_acc_w(st:ed,i)];
        end
        X = [X; mag_acc(st:ed)];
        
        y = zeros (6, 1);
        y (label) = 1;
        
        X_data = [X_data, X];
        y_data = [y_data, y];
        id = id + 1;
    end
end

numInputs = 1;
numLayers = 2;
biasConnect = [1; 1];
inputConnect = [1; 0];
layerConnect = [0 0; 1 0];
outputConnect = [0 1];

net = network(numInputs,numLayers,biasConnect,inputConnect,layerConnect,outputConnect);

net.inputs{1}.size = size (X_data, 1);

net.layers{1}.size = 100;
net.layers{1}.transferFcn = 'tansig';
net.layers{1}.initFcn = 'initnw';

net.layers{2}.size = 6;
net.layers{2}.transferFcn = 'logsig';
net.layers{2}.initFcn = 'initnw';

net.initFcn = 'initlay';
net.performFcn = 'crossentropy';
net.trainFcn = 'trainscg';

net = init (net);
net = train (net, X_data, y_data);