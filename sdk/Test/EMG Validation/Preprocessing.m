%% Preprocessing.m 

enable_plot = true;
subinterval_time = 0.2;

%% offset estimate between video and Myo 
vid_mark = [201/30, 278/30, 355/30]; % software estimates at 30 FPS.
guess_mark = [1.481, 4.207, 6.848];
offset = mean(vid_mark - guess_mark); % Myo is ~ 5.09s delayed.

%% Close figures

fh=findall(0,'type','figure');
for i=1:length(fh)
     clo(fh(i));
end

%% File for world oriented Myo Accel Reading - 50 Hz 

str_acc_w = 'worldAccel';
base_acc_w = csvread(strcat('07031/',str_acc_w,'.csv'));
base_acc_w(:,3) = base_acc_w(:,3) - 9.8;

Fsa = 50;
length_acc_w = size(base_acc_w,1);
num_acc_signals_w = size(base_acc_w,2);

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

y_max_e = zeros(num_emg_signals, 1);

% Convert EMG signals from 200 Hz to 50 Hz
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
            y_max_e(i) = filt_emg_signal_avg(j,i)
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
    figure(1);

    for i=1:num_emg_signals
        ax(i) = subplot(12,1,i);
        y_max=80;
        T_e = round(length_emg_avg/Fsa);
        x=linspace(0,T_e,length_emg_avg);
        plot(x,filt_emg_signal_avg(:,i));
        axis([0,T_e,0,y_max]);
        ylabel(strcat ('emg ', int2str (i)));
    end

    %% Plot Raw Acceleration Data
    for i=1:num_acc_signals_w
        ax(8+i) = subplot(12,1,8+i);
        y_max=1.2*max(abs(base_acc_w(:,i)));
        T_a=round(length_acc_w/Fsa);
        x_a=linspace(0,T_a,length_acc_w);
        plot(x_a,base_acc_w(:,i));
        axis([0,T_a,-y_max,y_max]);
        ylabel(strcat ('acc ', int2str (i)));
    end

    %% Plot Acceleration Magnitude 

    ax(12) = subplot (12,1,12);
    y_max=max(mag_acc);
    T_a=round(length_acc_w/Fsa);
    x_a=linspace(0,T_a,length_acc_w);
    plot(x_a,mag_acc);
    axis([0,T_a,0,y_max]);
    ylabel('mag acc');
end

%% Read labels from video

fileID = fopen('/Users/toppykung/Desktop/Therbligs.txt','r');

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
N = 0;

while ischar(temp)
    temp = strsplit (temp);
    
    start_time = str2double (temp{2})
    end_time = str2double (temp{3})
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
    
    time_start = start_time - offset;
    time_end = end_time - offset;
    frame_start = round (time_start * Fsa);
    frame_end = round (time_end * Fsa);
    frame_length = frame_end - frame_start + 1;
    subinterval_frame = round (subinterval_time * Fsa)
    
    N = N + floor (frame_length / subinterval_frame);
    
    temp = fgetl(fileID);
end

%% Plot each therblig subinterval

% length_therbligs = size (therbligs, 1)
% 
% for num=4:6%length_therbligs
%     figure('Name',therbligs{num,3});
%     
%     time_start = therbligs{num,1} - offset;
%     time_end = therbligs{num,2} - offset;
%     frame_start = round (time_start * 50);
%     frame_end = round (time_end * 50);
%     frame_length = frame_end - frame_start + 1;
%     
%     %% Plot Filtered EMG Data
%     for i=1:num_emg_signals
% %         ax(i) = subplot(12,1,i);
%         ax(i) = subplot(9,1,i);
%         y_max=y_max_e(i);
%         x=linspace(time_start,time_end,frame_length);
%         plot(x,filt_emg_signal_avg(frame_start:frame_end,i));
%         axis([time_start,time_end,0,y_max]);
%         ylabel(strcat ('emg ', int2str (i)));
%     end
%     
%     %% Plot Raw Acceleration Data
% %     for i=1:num_acc_signals_w
% %         ax(8+i) = subplot(12,1,8+i);
% %         y_max=20;
% %         x_a=linspace(time_start,time_end,frame_length);
% %         plot(x_a,base_acc_w(frame_start:frame_end,i));
% %         axis([time_start,time_end,-y_max,y_max]);
% %     end
% 
%     %% Plot Acceleration Magnitude
% %     ax(12) = subplot (12,1,12);
%     ax(9) = subplot (9,1,9);
%     y_max=5;%max(mag_acc);
%     x_a=linspace(time_start,time_end,frame_length);
%     plot(x_a,mag_acc(frame_start:frame_end));
%     axis([time_start,time_end,0,y_max]);
%     ylabel('mag acc');
% end

if enable_plot
    %% Rest

    temp = rest

    if size (temp, 1) > 0
        figure('Name', 'Rest');

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
            ax(i) = subplot(12,1,i);
            y_max=y_max_e(i);
            x=linspace(0,frame_length,frame_length);
            plot(x,emg(:,i));
            axis([0,frame_length,0,y_max]);
            ylabel(strcat ('emg ', int2str (i)));
        end

        for i=1:num_acc_signals_w
            ax(8+i) = subplot(12,1,8+i);
            y_max=5;%1.2*max(abs(base_acc_w(:,i)));
            x_a=linspace(0,frame_length,frame_length);
            plot(x_a,acc(:,i));
            axis([0,frame_length,-y_max,y_max]);
            ylabel(strcat ('acc ', int2str (i)));
        end

        ax(12) = subplot (12,1,12);
        y_max=5;%max(mag_acc);
        x_a=linspace(0,frame_length,frame_length);
        plot(x_a,acc_m);
        axis([0,frame_length,0,y_max]);
        ylabel('mag acc');
    end

    %% Transport Empty

    temp = transport_empty

    if size (temp, 1) > 0
        figure('Name', 'Transport Empty');

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
            ax(i) = subplot(12,1,i);
            y_max=y_max_e(i);
            x=linspace(0,frame_length,frame_length);
            plot(x,emg(:,i));
            axis([0,frame_length,0,y_max]);
            ylabel(strcat ('emg ', int2str (i)));
        end

        for i=1:num_acc_signals_w
            ax(8+i) = subplot(12,1,8+i);
            y_max=5;%1.2*max(abs(base_acc_w(:,i)));
            x_a=linspace(0,frame_length,frame_length);
            plot(x_a,acc(:,i));
            axis([0,frame_length,-y_max,y_max]);
            ylabel(strcat ('acc ', int2str (i)));
        end

        ax(12) = subplot (12,1,12);
        y_max=5;%max(mag_acc);
        x_a=linspace(0,frame_length,frame_length);
        plot(x_a,acc_m);
        axis([0,frame_length,0,y_max]);
        ylabel('mag acc');
    end

    %% Transport Loaded

    temp = transport_loaded

    if size (temp, 1) > 0
        figure('Name', 'Transport Loaded');

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
            ax(i) = subplot(12,1,i);
            y_max=y_max_e(i);
            x=linspace(0,frame_length,frame_length);
            plot(x,emg(:,i));
            axis([0,frame_length,0,y_max]);
            ylabel(strcat ('emg ', int2str (i)));
        end

        for i=1:num_acc_signals_w
            ax(8+i) = subplot(12,1,8+i);
            y_max=5;%1.2*max(abs(base_acc_w(:,i)));
            x_a=linspace(0,frame_length,frame_length);
            plot(x_a,acc(:,i));
            axis([0,frame_length,-y_max,y_max]);
            ylabel(strcat ('acc ', int2str (i)));
        end

        ax(12) = subplot (12,1,12);
        y_max=5;%max(mag_acc);
        x_a=linspace(0,frame_length,frame_length);
        plot(x_a,acc_m);
        axis([0,frame_length,0,y_max]);
        ylabel('mag acc');
    end

    %% Hold

    temp = hold

    if size (temp, 1) > 0
        figure('Name', 'Hold');

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
            ax(i) = subplot(12,1,i);
            y_max=y_max_e(i);
            x=linspace(0,frame_length,frame_length);
            plot(x,emg(:,i));
            axis([0,frame_length,0,y_max]);
            ylabel(strcat ('emg ', int2str (i)));
        end

        for i=1:num_acc_signals_w
            ax(8+i) = subplot(12,1,8+i);
            y_max=5;%1.2*max(abs(base_acc_w(:,i)));
            x_a=linspace(0,frame_length,frame_length);
            plot(x_a,acc(:,i));
            axis([0,frame_length,-y_max,y_max]);
            ylabel(strcat ('acc ', int2str (i)));
        end

        ax(12) = subplot (12,1,12);
        y_max=5;%max(mag_acc);
        x_a=linspace(0,frame_length,frame_length);
        plot(x_a,acc_m);
        axis([0,frame_length,0,y_max]);
        ylabel('mag acc');
    end

    %% Grasp

    temp = grasp

    if size (temp, 1) > 0
        figure('Name', 'Grasp');

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
            ax(i) = subplot(12,1,i);
            y_max=y_max_e(i);
            x=linspace(0,frame_length,frame_length);
            plot(x,emg(:,i));
            axis([0,frame_length,0,y_max]);
            ylabel(strcat ('emg ', int2str (i)));
        end

        for i=1:num_acc_signals_w
            ax(8+i) = subplot(12,1,8+i);
            y_max=5;%1.2*max(abs(base_acc_w(:,i)));
            x_a=linspace(0,frame_length,frame_length);
            plot(x_a,acc(:,i));
            axis([0,frame_length,-y_max,y_max]);
            ylabel(strcat ('acc ', int2str (i)));
        end

        ax(12) = subplot (12,1,12);
        y_max=5;%max(mag_acc);
        x_a=linspace(0,frame_length,frame_length);
        plot(x_a,acc_m);
        axis([0,frame_length,0,y_max]);
        ylabel('mag acc');
    end

    %% Release Load

    temp = release_load

    if size (temp, 1) > 0
        figure('Name', 'Release Load');

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
            ax(i) = subplot(12,1,i);
            y_max=y_max_e(i);
            x=linspace(0,frame_length,frame_length);
            plot(x,emg(:,i));
            axis([0,frame_length,0,y_max]);
            ylabel(strcat ('emg ', int2str (i)));
        end

        for i=1:num_acc_signals_w
            ax(8+i) = subplot(12,1,8+i);
            y_max=5;%1.2*max(abs(base_acc_w(:,i)));
            x_a=linspace(0,frame_length,frame_length);
            plot(x_a,acc(:,i));
            axis([0,frame_length,-y_max,y_max]);
            ylabel(strcat ('acc ', int2str (i)));
        end

        ax(12) = subplot (12,1,12);
        y_max=5;%max(mag_acc);
        x_a=linspace(0,frame_length,frame_length);
        plot(x_a,acc_m);
        axis([0,frame_length,0,y_max]);
        ylabel('mag acc');
    end
    
end

%% Create Data for Training

length_therbligs = size (therbligs, 1)
subinterval_frame = round (subinterval_time * Fsa);

X_data = zeros (subinterval_frame,12,N);
y_data = [];

id = 1;

for num=1:length_therbligs
    label = therbligs{num,3};
    
    if strcmp (label, 'Rest')
        label = 1;
    elseif strcmp (label, 'Transport_Empty')
        label = 2;
    elseif strcmp (label, 'Transport_Loaded')
        label = 3;
    elseif strcmp (label, 'Hold')
        label = 4;
    elseif strcmp (label, 'Grasp')
        label = 5;
    elseif strcmp (label, 'Release_Load')
        label = 6;
    end
    
    time_start = therbligs{num,1} - offset;
    time_end = therbligs{num,2} - offset;
    frame_start = round (time_start * Fsa);
    frame_end = round (time_end * Fsa);
    frame_length = frame_end - frame_start + 1;
    
    for st=frame_start:subinterval_frame:(frame_end-subinterval_frame+1)
        ed = st + subinterval_frame - 1;

        X = [];
        for i=1:num_emg_signals
            X = [X,filt_emg_signal_avg(st:ed,i)];
        end
        for i=1:num_acc_signals_w
            X = [X,base_acc_w(st:ed,i)];
        end
        X = [X,mag_acc(st:ed)];
        
        X_data(:,:,id) = X;
        y_data = [y_data; label];
        id = id + 1;
    end
end