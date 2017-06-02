% EMG Data 

base = csvread('emgStill.csv');
cup = csvread('emgMoveCup.csv');
book = csvread('emgLiftBook.csv');
fist = csvread('emgSqueeze.csv');

% first 3 values are dead for some reason
base = base(4:100, :);
cup = cup(4:100, :);
book = book(4:100,:);
fist = fist(4:100,:);

nval = size(base,1);
mval = size(base,2);

% rectify signals
for i=1:nval
   for j=1:mval
       if (base(i,j) < 0)
          base(i,j) = 0;
       end
       if (cup(i,j) < 0)
          cup(i,j) = 0;
       end
       if (book(i,j) < 0)
          book(i,j) = 0;
       end
       if (fist(i,j) < 0)
          fist(i,j) = 0;
       end
   end
end


t = linspace(1, nval, nval);


% Base

Base_avg=mean(base);

figure(1)
hold on
plot(t, base(:, 1));
plot(t, base(:, 2));
plot(t, base(:, 3));
plot(t, base(:, 4));
plot(t, base(:, 5));
plot(t, base(:, 6));
plot(t, base(:, 7));
plot(t, base(:, 8));
title('EMG Standalone Data');
xlabel('Timesteps - 50ms')
ylabel('EMG-Nominal value');
hold off


% Base -  Norm
norm_base = zeros(nval,1);
for i=1:size(base,1);
  norm_base(i) = norm(base(i,1:8));
end
    
figure(2)
hold on
plot(t, norm_base);
title('EMG Norm Data - Staying still');
xlabel('Timesteps - 50ms')
ylabel('EMG-Vector Norm');
hold off



% Cup 

Cup_avg=mean(cup);

figure(3)
hold on
plot(t, cup(:, 1));
plot(t, cup(:, 2));
plot(t, cup(:, 3));
plot(t, cup(:, 4));
plot(t, cup(:, 5));
plot(t, cup(:, 6));
plot(t, cup(:, 7));
plot(t, cup(:, 8));
title('EMG Data - Moving a cup');
xlabel('Timesteps - 50ms')
ylabel('EMG-Nominal value');
hold off

% Cup -  Norm
norm_cup = zeros(nval,1);
for i=1:size(cup,1);
  norm_cup(i) = norm(cup(i,1:8));
end
    
figure(4)
hold on
plot(t, norm_cup);
title('EMG Norm Data - Moving a cup');
xlabel('Timesteps - 50ms')
ylabel('EMG-Vector Norm');
hold off


% Fist

Fist_avg=mean(fist);

figure(5)
hold on
plot(t, fist(:, 1));
plot(t, fist(:, 2));
plot(t, fist(:, 3));
plot(t, fist(:, 4));
plot(t, fist(:, 5));
plot(t, fist(:, 6));
plot(t, fist(:, 7));
plot(t, fist(:, 8));
title('EMG Data - Making a fist');
xlabel('Timesteps - 50ms')
ylabel('EMG-Nominal value');
hold off

% fist -  Norm
norm_fist = zeros(nval,1);
for i=1:size(fist,1);
  norm_fist(i) = norm(fist(i,1:8));
end
    
figure(6)
hold on
plot(t, norm_fist);
title('EMG Norm Data - Making a fist');
xlabel('Timesteps - 50ms')
ylabel('EMG-Vector Norm');
hold off




% Book

Book_avg=mean(book);

figure(7)
hold on
plot(t, book(:, 1));
plot(t, book(:, 2));
plot(t, book(:, 3));
plot(t, book(:, 4));
plot(t, book(:, 5));
plot(t, book(:, 6));
plot(t, book(:, 7));
plot(t, book(:, 8));
title('EMG Data - Lifting a book');
xlabel('Timesteps - 50ms')
ylabel('EMG-Nominal value');
hold off

% Book -  Norm
norm_book = zeros(nval,1);
for i=1:size(book,1);
  norm_book(i) = norm(book(i,1:8));
end
    
figure(8)
hold on
plot(t, norm_book);
title('EMG Norm Data - Lifting a book');
xlabel('Timesteps - 50ms')
ylabel('EMG-Vector Norm');
hold off


