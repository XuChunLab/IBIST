function TimeStamps = SetStampsColumn( idx, interval)

if nargin < 2
    interval = 20024; % default is 200024 % ms. this is manual adjusted, based on 20180910\#10280\#10280_pre-test_2ms_5ms_opto laser 
end

nStamps = numel( idx);
TimeStamps = zeros(1, nStamps);
count = 1;
for i = idx
    TimeStamps( count) = i * interval;
    count = count + 1;
end

end % TimeStamps = SetStampsColumn( idx, interval)