%% Load data

str_file1 = '0731EricHTherblig';
str_file2 = '0731EricWTherblig';

X_data1 = csvread(strcat(str_file1,'_X.csv'));
y_data1 = csvread(strcat(str_file1,'_y.csv'));

X_data2 = csvread(strcat(str_file2,'_X.csv'));
y_data2 = csvread(strcat(str_file2,'_y.csv'));

X_data = [X_data1, X_data2];
y_data = [y_data1, y_data2];

%% Create Network

net = fitnet (9);

%% Train

net = train (net, X_data, y_data);

%% Predict the outputs

y_pred = net (X_data);

numExamples = size (y_pred, 2);
for i=1:numExamples
    temp = zeros (size (y_pred, 1), 1);
    [M, I] = max (y_pred (:, i));
    temp (I) = 1;
    y_pred (:, i) = temp;
end

%% Calculate the error rate

plotconfusion (y_data, y_pred);