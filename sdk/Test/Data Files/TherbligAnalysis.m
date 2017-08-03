%% Label files
 
fileID = fopen('07312/0731KrittisakWTherblig.txt','r');

%fileID = fopen('07313/0731EricHTherblig.txt','r');

%% Read labels from video
 
% 'Rest'                1
% 'Transport_Empty'     2
% 'Transport_Loaded'    3
% 'Hold'                4
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
hold = [];
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
        hold(h, 1) = start_time;
        hold(h, 2) = end_time;
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

%% Analysis 

% Evaluate time spent on each therblig
% Get average time for each therblig 

totals = zeros(6, 1);
sizes = zeros(6,1);

sizes(1)= size(rest,1);
sizes(2) = size(transport_empty,1);
sizes(3) = size(transport_loaded,1);
sizes(4) = size(hold,1);
sizes(5) = size(grasp,1);
sizes(6) = size(release_load,1);

%% Lazy coding - go back and update 

for i=1:size(rest,1)
    totals(1) = totals(1) + (rest(i, 2) - rest(i,1));
end

for i=1:size(transport_empty,1)
    totals(2) = totals(2) + (transport_empty(i, 2) - transport_empty(i,1));
end

for i=1:size(transport_loaded,1)
    totals(3) = totals(3) + (transport_loaded(i, 2) - transport_loaded(i,1));
end

for i=1:size(hold,1)
    totals(4) = totals(4) + (hold(i, 2) - hold(i,1));
end

for i=1:size(grasp,1)
    totals(5) = totals(5) + (grasp(i, 2) - grasp(i,1));
end

for i=1:size(release_load,1)
    totals(6) = totals(6) + (release_load(i, 2) - release_load(i,1));
end

%% Proportions
percentages = zeros(6,1);

for i=1:6
   percentages(i) = totals(i)/sum(totals); 
end

%% Average times 
avg_times = zeros(6,1);

for i=1:6 
    avg_times(i) = totals(i)/sizes(i);
end


