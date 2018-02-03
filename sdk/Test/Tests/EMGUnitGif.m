function [ ] = EMGUnitGif( data, zero_index,figure_num, freq, name)
% A helper function to plot EMG values in a circular array
% Input:
% Data: m x n vector of filtered EMG data
% Zero_index: the index of the column that is at degree 0.
% Figure_num: the figure on which to create the gif
% freq: The sampling frequency
% name: the name of the movement
 
%Adjust rearrange columns

m=size(data,1);
n=size(data,2);
max_val=max(data(:));

data_shifted=zeros(m,n);

% in our case, column 6 should be on the x-axis
for i=1:n
   % some odd adjustments for 1 based indexing 
   data_shifted(:,i) = data(:, mod(zero_index- 2 + i,n) + 1);
end 

% now split degrees based on number of values 
inc = 2*pi/n;


figure(figure_num);
filename = 'temp.gif';

% Plot the points in a circle 
for i=1:m
    
    clf
    %figure(i); %TODO do we need this

    % current iteration    
    curr_data = data_shifted(i,:);
    
    % for each data sample, calculate points 

    x=zeros(1,n);
    y=zeros(1,n);
    for k=1:n
        x(k)=curr_data(k)*cos((k-1)*inc);
        y(k)=curr_data(k)*sin((k-1)*inc);
    end
    
    hold on;
    % draw lines 
    for j=1:n-1
         plot( [x(j),x(j+1)],[y(j),y(j+1)]);
    end
    
    %plot closing line
    plot([x(n),x(1)],[y(n),y(1)]);
    
%    % test quiver plot 
%     for j=1:n
%        quiver(0,0, x(j),y(j));
%     end
%     
    hold off;
    
    axis([-max_val-1, max_val+1, -max_val-1, max_val+1]);
    grid on;
    
    time = i/freq; % convert from hz to time increment
    
    title(strcat(name,' - EMG Values'));
    legend(['Time: ', sprintf('%.3f',time), ' s']);
    
    drawnow;
    
    frame = getframe(figure_num);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if i == 1
         imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    else
         imwrite(imind,cm,filename,'gif','WriteMode','append');
    end
    
end


end

