%Plots serial data (temp) vs timer in real time on plot with limited/scrolling axis
%Also plots average of all data in red
%Plots linearized thermistor and raw data

s = serial('COM3');                            %this is the serial port
set(s,'BaudRate',57600);                       %change settings to match teensy code
fopen(s);                                      %opens communication with serial port
figure;                                        %opens a new figure
data = animatedline('Color', 'c');             %initilizes data normalized line in cyan
data2 = animatedline('Color', 'r');            %initializes data2 (average line) in red
data3 = animatedline('Color', 'g');            %initializes raw linearized data line in green
error = animatedline('Color', 'y');

xlabel('Time (seconds)');                      %labels x axis
ylabel('Temperature (°C)');                    %labels y axis

S.t = uicontrol('Style','toggle',...           %changes to toggle switch
             'Position',[10 10 80 40],...      %sets position in gui [left bottom width height]
             'String','Not Looping');          %displays message on toggle switch
dataArr =[];                                   %initializes array
tic;                                           %starts timer

while 1
    set(S.t,'string','Looping')                %changes message on toggle switch
    v = fscanf(s,'%f ');                       %reads data and converts it to a float
    v = (v*(5/256));                           %normalizes voltage from teensy output
    t = toc;                                   %toc gives timer time
    r = (23500/v) - 4700;                      %gives resistance based on 4.7k resistor in v divider
    
    temp = (1282045/log(10000/r))/((4300/log(10000/r))-298.15);  %give temp in Kelvin from resistance
    temp = temp - 273.15;                      %convert to Celcius
    newData = [temp; t];
    dataArr =[dataArr, newData];               %concatenates two arrays to add new data
    addpoints(data, t, temp);                  %adds new data to data plot; d vs timer
    drawnow limitrate;                         %limitrate creates a faster smoother animation
   
    m = mean(dataArr, 2);                      %takes mean of rows
    addpoints(data2, toc, m(1,:));             %adds new mean of row 1 (actual data) to data2 plot
    drawnow limitrate;
    
    temp2 = ((r-10000)/(-125.9))+25;
    addpoints(data3, t, temp2);   
    drawnow limitrate;
    
    axis([toc-5 toc 15 60]);                   %sets axis to essentially scroll through data 
    if get(S.t,'value')                        %when button pressed:
            set(S.t,'string','Not Looping');   %changes message on toggle switch
            break;                             %ends while loop
    end
end 

x = dataArr(2, :);                             %arrays for curve fitter app
y = dataArr(1, :);
                                               %DO NOT give variables the names of functions
minimum = min(y);                              %finds min value 
maximum = max(y);                              %finds max value

fclose(s);                                     %ends serial communication
delete(s);                                     %removes serial port from memory
clear s;                                       %clears serial port from variables