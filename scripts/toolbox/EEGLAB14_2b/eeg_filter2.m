function data2 = eeg_filter2 ( data, low, high, sfreq)
% EEG_FILTER
% 10.11.06: changed default sampling frequency to 500 Hz

if nargin==3
    sfreq=500;
end
% see in which dimension the data lives. 
  [ tmp, dim ] = max ( size ( data ));
  ndim = length ( size ( data ));
  
  % shift the data in the first dimension.
  data = shiftdim ( data, dim-1 );

  % calculate the frequency in the data 
  % freq = params.points_in_sweep/(params.dwz/1000); 
  
  % Fourier transform the input 
  data = fft ( data); 

  % set those complex numbers to zero, which represent the low and high
  % pass areas
  l=length(data);
  low = floor ( low / sfreq * l);
  high = ceil ( high / sfreq * l);
  
  data(1:low,:)=0; data(high+2:l/2,:)=0;
  data(l-low+1:l,:)=0; data(l/2:l-high-1,:)=0;

  data(l,:)=0;
    
  % perform the inverse fourier transform
  data = real ( ifft ( data )); 
  
  % shift the data back in to its original dimensional structure
  data2 = shiftdim ( data, ndim-dim+1 ); 


