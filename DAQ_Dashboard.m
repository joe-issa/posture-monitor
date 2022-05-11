close all; clear; clc;

c = 'grbck'; %for states 1 to 3.

f = figure('NumberTitle','off',...
          'Name','Posture Monitor: DAQ Dashboard',...
          'WindowState','maximized');
       
% data = fileread('sample_results_1.txt');
% new_data = regexprep(data,'\n\n','\n');
% 
% fid=fopen('daq_no_space.txt','w');
% fwrite(fid, new_data);
% fclose(fid);

fid = fopen('sample_results_3.txt');

result = [];

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    celldata = textscan(tline,'%d %d %d %d', 'Delimiter', {',','\n'});
    matdata = cell2mat(celldata);
    result = [result ; matdata];
end
fclose(fid);    

%Divide
state = result(2:end,1)+1; %add 1 since MATLAB indexing starts at 1
adc = result(2:end,2);
counter = result(2:end,3);
how_long = result(2:end,4);

thresh = result(1,1);
good_max = result(1,2);

%Find percentages of each state
freq = histcounts(state);
total = sum(freq);
freq = freq/total*100;

%Find percentages of good range bad range
total = length(adc);
good_zone = length(intersect(find(adc>thresh),find(adc<good_max)))/total*100;
bad_zone = 100 - good_zone;

%Check for all state changes
state_change_at = 1; %Unknown # of changes so cannot preallocate memory
for i=1:length(state)-1
    if state(i)~=state(i+1)
        state_change_at = [state_change_at, i+1];
    end
end
state_change_at = [state_change_at, length(state)];

%For the legend coloring
for i=1:length(c)
   subplot(6,3,[1,2,4,5])
   plot(0,0,c(i))
   hold on
end

if length(state_change_at)>1
for i=1:length(state_change_at)-1
   subplot(6,3,[1,2,4,5])
   hold on
   plot(state_change_at(i):state_change_at(i+1),[adc(state_change_at(i):state_change_at(i+1)-1);adc(state_change_at(i+1))],c(state(state_change_at(i))))
   plot([1,1,length(state),length(state),1],[thresh,good_max,good_max,thresh,thresh],'k')
   ylabel("ADC Value from Flex")
   title("Sensor Reading reflecting your posture")
   grid on
   subplot(6,3,[7,8,10,11])
   hold on
   plot(state_change_at(i):state_change_at(i+1),[counter(state_change_at(i):state_change_at(i+1)-1);counter(state_change_at(i+1))],c(state(state_change_at(i))))
   ylabel("Seconds of Bad Posture (s)")
   title("Consecutive Seconds of Bad Posture")
   grid on
   subplot(6,3,[13,14,16,17])
   hold on
   plot(state_change_at(i):state_change_at(i+1),[how_long(state_change_at(i):state_change_at(i+1)-1);how_long(state_change_at(i+1))],c(state(state_change_at(i))))
   ylabel("Seconds of consecutive sitting (s)")
   title("How Long you've been Sitting wihtout Physical Activity")
   xlabel('Second or Sample Number')
   grid on
end
else
   subplot(6,3,[1,2,4,5])
   plot(1:length(adc),adc,c(1)) 
   subplot(6,3,[7,8,10,11])
   plot(1:length(counter),counter,c(1)) 
   subplot(6,3,[13,14,16,17])
   plot(1:length(how_long),how_long,c(1)) 
   xlabel('Second or Sample Number')
end

   %State frequency pie chart
   subplot(6,3,[3,6,9])
   p1 = pie(freq);
   title("Percentage division of every state")
   legend({'Good Posture','Bad Posture ','Sitting long','Massage Mode'},'Location','eastoutside'); 

   %good posture bad posture pie chart
   subplot(6,3,[12,15,18])
   pie([good_zone,bad_zone])
   title("Good Posture Time vs. Bad Posture Time")
   legend({'Good Posture Zone','in Bad Posture'},'Location','southoutside','Orientation','horizontal')
   
   subplot(6,3,[1,2,4,5])
   leg = legend('Good Posture','Bad Posture ','Sitting long','Massage Mode');
   leg.Color = [0.99,0.99,0.99];
   leg.Location = 'northwest';
   leg.Position(2) = leg.Position(2)+0.1;
   leg.Position(1) = leg.Position(1)-0.2;
   
main_title = sgtitle("Posture Monitor DAQ");
main_title.FontSize = 28;