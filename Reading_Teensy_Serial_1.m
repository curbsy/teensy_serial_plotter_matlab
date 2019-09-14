%spits out serial data for set amount of time

s = serial('COM3');
set(s,'BaudRate',57600);
fopen(s);
for ii=1:199
    d=fscanf(s,'%f ');
    d=d*(5/256);
    %[length(d) d']
end
fclose(s);
delete(s);
clear s
