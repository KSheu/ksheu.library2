% TNF SIMULATION
options = struct;
options.DEBUG = 1;
options.SIM_TIME = 8*60;

global START_TIME END_TIME NUM_CELLS

% Transcription factor vector
% single cell TFs trajectories
% data_name = 'WT_10ngTNF';
% data_name = 'ikbamut_10ngTNF';
% data_name = 'lps_100ng';
% data_name = 'cpg_100nM';
% data_name = 'pic_50ug';

% names = {'tnf_10ng', 'p3csk4_100ng','cpg_100nM', 'pic_50ug'};
% names = {'pic_50ug'};
% names = {'lps_100ng'}; %add extra 'trajectories.data' if lps (messed up the struct)
% names = {'WT_10ngTNF', 'ikbamut_10ngTNF'};
names = {'ikbamut_10ngTNF'};
for j = 1:length(names)
data_name = char(names(j));
data = load(strcat('F://enhancer_dynamics/nfkb_trajectories/',data_name,'.mat'));
% data = load('F://enhancer_dynamics/nfkb_trajectories_20190302/2KO_TNF.mat');
data = cell2struct(struct2cell(data), {'trajectories'});

data = data.trajectories;
datazero = vec2mat(data(:, 1), 1);
subtract = repmat(datazero, 1, size(data,2));
data = data - subtract; %subtract the first column to normalize
data(data<0) = 0; %take neg. values to be 0
data_smooth = smoothrows(data);
data_smooth = sortrows(data_smooth,[1 20]); %max within first 100 mins
% data_smooth = data_smooth; %scale to max

START_TIME =0;
END_TIME = 480;
NUM_CELLS = size(data,1); %100
sim.time = START_TIME:END_TIME;
% tf = data_smooth(5,1:96); %cut to 8hrs
% plot(sim.time*5, interp1( 1:length(tf), tf, START_TIME:END_TIME,'nearest'));
% xlabel('time (min)')
% ylabel('[TF]')	
% ylim([0 inf]);
% f = fit( transpose(time(:,1:96)*5), transpose(tf), 'linearinterp');
% plot( f, transpose(time(:,1:96)*5), transpose(tf) )

% Starting Conditions
    initvalues = zeros(15,1);
    initvalues(1,1) = 100;    %E0
    initvalues(2,1) = 0;    %E1

    initvalues(3,1) = 0;   %E2
    initvalues(4,1) = 0;   %E3

    initvalues(5,1) = 0;   %E4
    initvalues(6,1) = 0;   %E5
    initvalues(7,1) = 0;   %E6
    initvalues(8,1) = 0;   %E7
    initvalues(9,1) = 0;   %E8
    initvalues(10,1) = 0;   %E9
    initvalues(11,1) = 0;   %E10
    initvalues(12,1) = 0;   %E11
    initvalues(13,1) = 0;   %E12
    initvalues(14,1) = 0;   %E13
    initvalues(15,1) = 0;   %E14
    

output_enhancer = zeros(NUM_CELLS,481); %container to store the outputs
r = (1:NUM_CELLS); 
for i = r
    disp(i);
    tf = data_smooth(i,1:96); %cut to 8hrs 
    time = linspace(START_TIME, END_TIME, length(tf));
    [tsim1, results1] = ode15s(@(t,x) chromatinOde(t, x, time,{}, tf),[START_TIME END_TIME],initvalues);
    
%   [t_sim, x_sim] = ode15s(@(t,y)'chromatinOde', v.SIM_TIME,starting_vals,ode_opt,v);

    output = transpose(interp1(tsim1,results1,START_TIME:END_TIME, 'linear'));
    output_enhancer(i,:) = output(15,:); %store all the outputs

end

enhancer{1,1} = output_enhancer;
% 
% mat = enhancer{1,1};
% mat = sortrows(mat, 100);
% surf(mat);
% shading interp 
% colorbar

% output_enhancer = sortrows(output_enhancer,[10 90]);
subplot(1,length(names),j);
imagesc(output_enhancer);
title(char(names(j)));
colorbar
save(strcat('F://enhancer_dynamics/model_v1/output_enhancer_',data_name,'.mat'), 'output_enhancer')
end

%plot summary curves, column means
% load('F://enhancer_dynamics/model_v1/output_enhancer_lps_100ng.mat');
% plot(smoothrows(mean(output_enhancer)));
% ylim([0 100]);