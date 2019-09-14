%puts serial data in vector and plots for set amount of time

s = serial('COM3');
set(s,'BaudRate',57600);    %change settings for cummincation with serial port
fopen(s);                   %opens communication with serial port
dataArr =[];                %initializes empty array
for ii=1:199
    d=fscanf(s,'%f ');
    dataArr = [dataArr, d]; %puts raw data in array
end

plot([1:199], dataArr);     %plots raw data
title('Photoresistor Data');
xlabel('Time');
ylabel('Voltage');

fclose(s);
delete(s);
clear s