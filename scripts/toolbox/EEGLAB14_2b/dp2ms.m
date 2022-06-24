function ms = dp2ms(dp, sf)
% ms = dp2ms(dp, sf)
%
% dp2ms returns the inputargument dp in ms. The default Value of
% the sampling frequency is 512 Hz.

switch nargin
case 1
    sf = 512; 
end
ms = 1000/sf * dp;
