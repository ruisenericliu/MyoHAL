% EMG Data 

base = csvread('06021/HoldStill.csv');

nval = size(base,1);
mval = size(base,2);

%% rectify signals
% for i=1:nval
%    for j=1:mval
%        if (base(i,j) < 0)
%           base(i,j) = 0;
%        end
%    end
% end

%% Plotting
t = linspace(1, nval, nval);
% Plot for each EMG 

Base_avg=mean(base);

for i=1:mval
    figure(i)
    hold on
    plot(t, base(:,i));
    hold off
    str = sprintf('Temporary Data from EMG # %d',i);
    title(str);
    xlabel('frequency - approx 200 Hz')
    ylabel('EMG-Nominal value');
end



% Base -  Plot Norm
norm_base = zeros(nval,1);
for i=1:size(base,1);
  norm_base(i) = norm(base(i,1:8));
end
    
figure(1000)
hold on
plot(t, norm_base);
title('Temporary EMG Data - Norm');
xlabel('frequency - approx 200 Hz')
ylabel('EMG-Vector Norm');
hold off

