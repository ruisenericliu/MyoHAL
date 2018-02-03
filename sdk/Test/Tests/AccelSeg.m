% Visualize segmented acceleration

close all;
clear;

% Load file for representative task
folder_name = strcat('08181/0818E',num2str(1));
str_file = strcat('0818E', num2str(1));
X_data = csvread(strcat(folder_name,'/',str_file,'_X_full.csv'));
Y_data = csvread(strcat(folder_name,'/',str_file,'_Y_full.csv'));

% Mean subtracted accelerations
X_acc = X_data(9:11,:);

% Magnitude
X_mag = X_data(12,:);

length_acc = size(X_acc,2);
num_acc_signals = size(X_acc,1);

%% pack class data 

np = size(Y_data,2);

% zeros and ones's 
Y = zeros(1,np);
for i=1:np
   for j=1:size(Y_data,1)
       if (Y_data(j,i) == 1)
          Y(i) = j-1; 
       end
   end
end


% indices for start and stopping 
starts = [1];
stops = [];

for i=1:length_acc-1
   if Y(i) == 0 && Y(i+1) == 1
       starts = [starts, i];
   end
   if Y(i) == 1 && Y(i+1) == 0
       stops = [stops, i];
   end    
end

% 50 samples per 
Fsa = 50;
dt = 1/Fsa; 

for k=1:size(starts,2)
    X = X_acc(:,starts(k):stops(k));
    
    signals = size(X,1);
    length = size(X,2);
    
    
    % Calculate magnitude of acceleration
    temp = X_mag(:,starts(k):stops(k));
    
    
    % Calculate velocity
    
    velocity = zeros(signals, length);
    for i=1:signals
        for j=2:length
            velocity(i,j) = velocity(i,j-1) + X(i,j-1)*dt;
        end
    end
    
    %Summing for RMS 
    vel_sq = velocity.^2;

    %Calculate RMS 
    RMS= zeros(1,length);
    for j=1:length
        temp_sum=0;
        for i=1:signals
            temp_sum=temp_sum + vel_sq(i,j); 
        end
        RMS(j)=sqrt(1/signals*temp_sum);
    end
    
%     figure(10+k) 
%     x = linspace(0, length/Fsa, length);
%     plot(x,temp)
%     xlabel('time (s)')
%     ylabel(' Magnitude of Acceleration m/s^2' )
%     title(strcat('Movement: ', num2str(k)))

    
    
    figure(k);
    x = linspace(0, length/Fsa, length);
    plot(x,RMS )
    xlabel('time (s)')
    ylabel(' RMS speed m/s' )
    axis([0, length/Fsa, 0, 0.7])
    title(strcat('Movement: ', num2str(k)))

    
end

    