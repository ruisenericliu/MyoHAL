%% File for Accel Reading - 50 Hz
str_acc = 'accelMP';
base_acc = csvread(strcat('08033/',str_acc,'.csv'));

% clean up motion
base_acc = base_acc(200:end,:);

length_acc = size(base_acc,1);
num_acc_signals = size(base_acc,2);


%% File for world oriented Myo Accel Reading - 50 Hz 

str_acc_w = 'worldAccelMP';
base_acc = csvread(strcat('08033/',str_acc_w,'.csv'));

base_acc = base_acc(200:end,:);

%length_acc_w = size(base_acc_w,1);
%num_acc_signals_w = size(base_acc_w,2);



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

%% Calculate the magnitude of the signal

 magnitude = zeros(length_acc,1);
 
for i =1:length_acc

magnitude(i) = sqrt( base_acc(i,1)^2 + base_acc(i,2)^2 + base_acc(i,3)^2 );
    
end

figure(4);
x_a=linspace(0,T_a,length_acc);
plot(x_a,magnitude);
axis([0,T_a,5,15]);
title('Magnitude of Acceleration');
ylabel('m/s^2');
xlabel('time (s)');


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
    figure(4+i);
    x_a=linspace(0,T_a,length_acc);
    plot(x_a,sub_acc_signal(:,i));
    axis([0,T_a,-5,5]);
    title(['Mean Subtracted -Axis ', num2str(i)]);
    ylabel('m/s^2');
    xlabel('time (s)');
end



%% Calculating Velocity

dt = 1/Fsa; 
%Calculate Velocity 
velocity = zeros(length_acc, num_acc_signals);

% Calculate Velocity

for i=1:num_acc_signals 
    for j=2:length_acc 
        velocity(j,i)= velocity(j-1,i) + sub_acc_signal(j-1,i)*dt;
    end
end


%% Plot Velocity

figure(8);
x_a=linspace(0,T_a,length_acc);
plot(x_a, velocity);
title('Velocity along each axis');
ylabel('m/s');
xlabel('time (s)');
legend('x','y','z');

%% Try Kalman Filter? 
