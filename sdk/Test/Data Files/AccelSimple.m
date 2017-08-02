% File for Accel Reading - 50 Hz
str_acc = 'accelThermal';
base_acc = csvread(strcat('07311/',str_acc,'.csv'));


%% Filter Acceleration Signals 

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


%% Mean subtract and see if there's drift


