function dp = ms2dp(ms, sf)
% dp = ms2dp(ms, sf)
%
% ms2dp returns the inputargument ms in datapoints. The default Value of
% the sampling frequency is 512 Hz.

switch nargin
case 1
    sf = 512; 
end
dp = sf/1000 * ms;
