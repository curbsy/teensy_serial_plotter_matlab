%Plots serial data vs timer in real time on plot with limited/scrolling axis
%Also plots average of all data in red
%Used with photoresistor

s = serial('COM3');                            %this is the serial port
set(s,'BaudRate',57600);                       %change settings to match teensy code
fopen(s);                                      %opens communication with serial port
figure;                                        %opens a new figure
data = animatedline('Color', 'c');             %initilizes data line
data2 = animatedline('Color', 'r');            %initializes data2 (average line)
xlabel('Time (seconds)');                      %labels x axis
ylabel('Voltage (V)');                         %labels y axis

S.t = uicontrol('Style','toggle',...           %changes to toggle switch
             'Position',[10 10 80 40],...      %sets position in gui [left bottom width height]
             'String','Not Looping');          %displays message on toggle switch
dataArr =[];                                   %initializes array
tic;                                           %starts timer

while 1
    set(S.t,'string','Looping')                %changes message on toggle switch
    d = fscanf(s,'%f ');                       %reads data and converts it to a float
    d = 5 - (d*(5/256));                       %normalizes voltage from teensy output
                                               %photoresistor resistance increases with less light
    t = toc;                                   %toc gives timer time
    newData = [d; t];
    dataArr =[dataArr, newData];               %concatenates two arrays to add new data
    addpoints(data, t, d);                     %adds new data to data plot; d vs timer
    drawnow limitrate;                         %limitrate creates a faster smoother animation
    m = mean(dataArr, 2);                      %takes mean of rows
    addpoints(data2, toc, m(1,:));             %adds new mean of row 1 (actual data) to data2 plot
    drawnow limitrate;
    axis([toc-5 toc 0 5]);                     %sets axis to essentially scroll through data 
    if get(S.t,'value')
        set(S.t,'string','Not Looping');   %changes message on toggle switch, ends while loop when button pressed
        break;
    end
end

x = dataArr(2, :);                             %arrays for curve fitter app
y = dataArr(1, :);

minimum = min(y);                                  %finds min value 
maximum = max(y);                                  %finds max value

fclose(s);                                     %ends serial communication
delete(s);                                     %removes serial port from memory
clear s;                                       %clears serial port from variables