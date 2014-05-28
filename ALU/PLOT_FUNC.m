
infile = fopen('TEST2.txt','r');
data_in = fscanf(infile,'%f');
outfile = fopen('Result.txt','r');
data_out = fscanf(outfile,'%f');

X = 1:length(data_out)/3;
x = 1:length(data_out)/3;

i = 1;
j = 1;
data_in_roll = zeros(length(data_out)/3,1);
data_out_roll = zeros(length(data_out)/3,1);
while (i<=3*length(data_out)/3)
    data_out_roll(j) = data_out(i);
    i = i+3;
    j = j+1;
end
j=1;
i =1;
while (i<=3*length(data_out)/3)
    data_in_roll(j) = data_in(i);
    i = i+3;
    j= j +1;
end
data_in_pitch = zeros(length(data_out)/3,1);
data_out_pitch = zeros(length(data_out)/3,1);
j=1;
i=2;
while (i<=3*length(data_out)/3)
    data_out_pitch(j) = data_out(i);
    i = i+3;
    j = j+1;
end
j=1;
i=2;
while (i<=3*length(data_out)/3)
    data_in_pitch(j) = data_in(i);
    i = i+3;
    j= j +1;
end
j=1;
i=3;
data_in_yaw = zeros(length(data_out)/3,1);
data_out_yaw = zeros(length(data_out)/3,1);
while (i<=3*length(data_out)/3)
    data_out_yaw(j) = data_out(i);
    i = i+3;
    j = j+1;
end
j=1;
i=3;
while (i<=3*length(data_out)/3)
    data_in_yaw(j) = data_in(i);
    i = i+3;
    j= j +1;
end

figure(1);

plot(X,data_in_roll,'b.');
hold on;
plot(x,data_out_roll,'g.');
title('roll data');
figure(2);

plot(X,data_in_pitch,'b.');
hold on;
plot(x,data_out_pitch,'g.');
title('pitch data');
figure(3);

plot(X,data_in_yaw,'b.');
hold on;
plot(x,data_out_yaw,'g.');
title('yaw data');