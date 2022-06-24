function [data,params] = importbraindata_raw( file, GUI ) 
% IMPORTBRAINDATA
% IMPORTBRAINDATA ( file ) import a braindata fileset
% for FILE, use the filename without extension 
% IMPORTBRAINDATA will read both parameter and 
% data file. 
% 
% The first return value is a 3-dimensional matrix with the data of the
% form sweeps x data x channels. The second return value is a structure
% containing the information from the parameter file. 
%
% If the optional parameter GUI is set to one, a progressbar is displayed 
% during importing
%
% copyright (c) Peter Ganten, 2000 (all rights reserved!)

% CHANGE by Joscha Schmiedt: For compatibility reasons with matlab 7 
% the fread parameter of the function get_string was changed to uchar
% 12.07.06


% NOTE: There is an older version of the braindata file format,
% which is not yet supported. 

  
% check, if we got a string
  if nargin < 1 || ~ isa( file, 'char' )
    error ( ['This function must be called with a valid file name' ...
	     ' as argument!'] );
    return; 
  end

  do_gui = 0;
  if exist ( 'GUI' , 'var' ) && GUI == 1
    H = waitbar ( 0, 'Please wait...' ); 
    do_gui = 1; 
  end; 

% construct the full filenames
parfilename = [ file '.pre' ];
datfilename = [ file '.evo' ];

% try to open the files
parfilefd = fopen( parfilename, 'r' );
if parfilefd == -1 
  parfilename = [ file '.prm' ]; 
  datfilename = [ file, '.spo' ]; 
  parfilefd = fopen( parfilename, 'r' ); 
  if parfilefd == -1
    if do_gui == 1
      close ( H );
    end;
    error ( ['Failed to open ' parfilename ]);
    return 
  end 
end 
datfilefd = fopen( datfilename, 'r' );
if datfilefd == -1 
  if do_gui == 1
    close ( H );
  end;
  error ( ['Failed to open ' datfilename ]);
  return 
end

if do_gui == 1
  waitbar ( 0.01 );
end


% Now the dirty stuff starts ... 
params.ID = get_string ( parfilefd, 8 );
params.revision = get_string ( parfilefd, 8 );
params.hardware = get_string ( parfilefd, 8 );
params.type = get_string ( parfilefd, 8 );
params.filename = get_string ( parfilefd, 16 );
params.number_of_sweeps = get_int ( parfilefd );
params.points_in_sweep = get_int ( parfilefd );
params.number_of_channels = get_int ( parfilefd ); 
params.dwz = get_double( parfilefd );
params.trigger = get_int ( parfilefd ); 
if do_gui == 1
  waitbar ( .02 );
end
params.height_cal_amp = get_double( parfilefd );
params.unit_cal_amp = get_int ( parfilefd ); 
params.intervall = get_int ( parfilefd ); 
params.gain_of_adc = get_int ( parfilefd );
params.int_trig_flag = get_int ( parfilefd );
params.artefact_flag = get_int ( parfilefd );
params.dwz_2 = get_double ( parfilefd ); 
params.record_scheme = get_string ( parfilefd, 32 ); 
params.nsw_2 = get_int ( parfilefd );
params.subject_wake = get_int ( parfilefd );
if do_gui == 1
  waitbar ( .03 );
end
params.wake_channel = get_int ( parfilefd );
params.ppg = get_int ( parfilefd ); 
params.ppg_channel = get_int ( parfilefd ); 
params.standort = get_string ( parfilefd, 12 ); 
params.password = get_string ( parfilefd, 8 ); 
% oh well, lets have a comment here 
params.start_sec = get_int ( parfilefd );
params.end_sec = get_int ( parfilefd );
params.start_min = get_int ( parfilefd );
params.end_min = get_int ( parfilefd );
params.start_hour = get_int ( parfilefd );
params.end_hour = get_int ( parfilefd );
params.start_day = get_int ( parfilefd );
params.end_day = get_int ( parfilefd );
params.start_month = get_int ( parfilefd );
params.end_month = get_int ( parfilefd );
params.start_year = get_int ( parfilefd );
params.end_year = get_int ( parfilefd );
% go for another comment
params.experiment_type = get_string ( parfilefd, 32 ); 
params.reclen_eep = get_int ( parfilefd );
if do_gui == 1
  waitbar ( .04 );
end
for i = 1:16
  params.amplification(i) = get_int ( parfilefd );
end
for i = 1:7
  params.dummy(i) = get_int ( parfilefd );
end
params.max_nsw = get_int ( parfilefd );
params.max_swp = get_int ( parfilefd );
params.max_zei = get_int ( parfilefd );
params.max_words_sweep = get_int ( parfilefd );
params.record_length = get_int ( parfilefd );
params.record_sweep = get_int ( parfilefd );
params.max_records = get_double ( parfilefd ); 
params.record_data = get_double ( parfilefd ); 
params.start_data = get_int ( parfilefd );
for i = 1:32
  params.calib_factor(i) = get_double ( parfilefd ); 
end
params.subject_id = get_string ( parfilefd, 8 );
params.project_id = get_string ( parfilefd, 16 );
params.scheme_file = get_string ( parfilefd, 32 );
params.list_length = get_int ( parfilefd );
params.multistable = get_int ( parfilefd );
params.original_file = get_string ( parfilefd, 16 ); 
params.check_para = get_double ( parfilefd );
params.check_data = get_double ( parfilefd );
if do_gui == 1
  waitbar ( .05 );
end
params.grand_asw = get_int ( parfilefd );
params.grand_nsw = get_int ( parfilefd ); 
params.grand_files = get_int ( parfilefd );
params.new_para = get_int ( parfilefd ); 
if params.new_para ~= 1
  warning ( ['The version of this parameterfile is not the expected' ...
	     ' one. Strange things might happen know !'] ); 
end
% empty stuff; 
fread ( parfilefd, 26, 'char' ); 
params.is_sweep_list = uint8 ( zeros(32,1) );
for i = 1:32
  params.is_sweep_list(i) = get_byte ( parfilefd ); 
end
fread ( parfilefd, 480, 'char' ); 
if do_gui == 1
  waitbar ( .06 );
end
for i = 1:8
  params.text_descript(i,:) = get_string ( parfilefd, 64 );
end
for i = 1:32
  params.text_channel(i,:) = get_string ( parfilefd, 16 ); 
end
for i = 1:32
  params.descr_sweep_list(i,:) = get_string ( parfilefd, 16 );
end
params.time_list = uint8 ( zeros(512,1) );
for i = 1:512
  params.time_list(i) = get_byte ( parfilefd );
end
if do_gui == 1
  waitbar ( .07 );
end
params.trigger_list = uint16 ( zeros(256,1) ); 
for i = 1:256
  params.trigger_list(i) = get_int ( parfilefd );
end

whos params.trigger_list 

params.sweep_list = uint8 ( zeros(8192,1) );
for i = 1:8192
  params.sweep_list(i) = get_byte ( parfilefd );
end
fread ( parfilefd, 2560, 'char' ); 
% ascii descriptions for HP transfer
fread ( parfilefd, 190, 'char' );
fread ( parfilefd, 322, 'char' );
params.info_sweep = uint8 ( zeros(8192,1) );
for i = 1:8192
  params.info_sweep(i) = get_byte ( parfilefd );
end
if do_gui == 1
  waitbar ( .08 );
end
params.info_eep = uint8 ( zeros(8192,1) );
for i = 1:8192
  params.info_eep(i) = get_byte ( parfilefd );
end
if do_gui == 1
  waitbar ( .09 );
end
params.artefact = uint8 ( zeros(8192,1) );
for i = 1:8192
  params.artefact(i) = get_byte ( parfilefd );
end
params.arte_eep = uint8 ( zeros(8192,1) );
if do_gui == 1
  waitbar ( .1 );
end
for i = 1:8192
  params.arte_eep(i) = get_byte ( parfilefd );
end
params.klicktime = get_double ( parfilefd );
params.trigger_marker = uint8 ( zeros(128,1) );
for i = 1:128
  % in the C-Version, we have some special logic here,
  % I don't think that I will need it anytime soon
  params.trigger_marker(i) = get_byte ( parfilefd ) ; 
end
for i = 1:128
  params.trigger_stim(i,:) = get_string ( parfilefd, 16 );
end
% on par with the C Version 
% ftell ( parfilefd )

pr = .9 / params.number_of_sweeps;

% now get the real data
data = single ( zeros ( params.number_of_sweeps, params.points_in_sweep, ...
	       params.number_of_channels )); 
for i = 1:params.number_of_sweeps
  tmp = fread ( datfilefd, params.number_of_channels * ...
		params.points_in_sweep, 'int16' );
  tmp = reshape ( tmp, params.number_of_channels, params.points_in_sweep ...
  		  )';
  tmp = tmp - 2048;
  if do_gui == 1
    waitbar ( (pr*i)+.1 );    
  end
  for j = 1:params.number_of_channels
    data(i,:,j) = tmp(:,j) * params.calib_factor(j) * -1;
  end
end

% get the sweeplists
%[ params.sweeplist, params.sweepdesc ] = construct_sweep_lists ( params ); 
[ params.triggerlist, params.triggerdesc ] = construct_trigger_lists ( params ); 

if do_gui == 1
  close ( H );
end;

% Now close the files and return 
fclose ( parfilefd );
fclose ( datfilefd );
return

% get a string out of the dammed encrypted braindata file 
function converted = get_string ( infd, stringlen )

converted = char ( bitxor( fread ( infd, stringlen, 'uchar' ), 255 )');

% get a byte out of the dammed encrypted braindata file 
function converted = get_byte ( infd )

converted = bitxor ( fread ( infd, 1, 'char' ), 255 );


% get a 16bit integer from the dammed encrypted braindata file 
function converted = get_int ( infd ) 

tmp =  fliplr( bitxor( fread ( infd, 2, 'char' ), 255 )');
converted = tmp(1)*256 + tmp(2);


% get a 32bit double from the dammed encrypted braindata file
function converted = get_double( infd ) 

stuff =  bitxor( fread ( infd, 4, 'char' ), 255 )';

a = stuff(1);
b = stuff(2);
c = stuff(3);
d = stuff(4);

tmp1 = bitand ( c,  127 );

nachkomma = tmp1*65536 +  b*256 + a;
nachkomma = nachkomma / 8388608;
    
if d >= 64 

  tmp4 = bitshift( bitand( d, 127 ), 1 );
  tmp3 = bitshift( bitand( c, 128 ), -7 );
  tmp4 = bitand( bitor( tmp4, tmp3 ), 127 );			
	    
  tmpvar = 2 ^ ( tmp4 + 1 );
  
  converted = tmpvar;
  converted = converted + ( tmpvar * nachkomma );
  
elseif d < 63  
  
  tmp4 = bitshift( bitand( d, 63 ), 1 );
  tmp3 = bitshift( bitand( c, 128 ), -7 );
  tmp4 = bitor( tmp4, bitor( tmp3, 128 ));
  tmp4 = bitxor( tmp4, 255 );
	    
  tmpvar = 2 ^ tmp4;
  tmpvar = 1 / tmpvar;
  converted = tmpvar + ( tmpvar * nachkomma );
  
elseif d == 63 
  if c < 128
    
    tmp4 = bitshift( bitand( d, 63 ), 1 );
    tmp3 = bitshift( bitand( c, 128 ), -7 );
    tmp4 = bitor( tmp4, bitor( tmp3, 128 ));
    tmp4 = bitxor( tmp4, 255 ); 
    
    tmpvar = 2 ^ tmp4;
    tmpvar = 1 / tmpvar;
    converted = tmpvar + ( tmpvar * nachkomma );
    
  else 

    converted = 1;
    converted = converted + ( 1 * nachkomma );
    
  end

else 
  
  converted = -1;
  
end
      

% construct the parameter list from the parameter structure
function [ triggerlist, triggerdesc ] = construct_trigger_lists ( params ) 

  triggerlist(1,:) = uint16 ( zeros(params.number_of_sweeps,1));
  triggerdesc(1,:) = cellstr ( '' ); 
  
  k = 1; 
  for i = 1:128 
    if params.trigger_marker(i) == 1
      triggerlist(k,:) = uint16 ( zeros(params.number_of_sweeps,1) );
      triggerdesc(k,:) = cellstr(deblank(params.trigger_stim(i,:)));
      m = 1;
      lp = 0;
      for j = 1:params.number_of_sweeps
	lp = lp + 1;
	if lp > params.list_length
	  lp = 1; 
	end
	if params.trigger_list(lp) == i 
	  triggerlist(k,m) = j;
	  m = m + 1; 
	end
      end
      k = k + 1;
    end
  end
  

% construct the sweep lists from the parameter structure
function [ sweeplist, sweepdesc ] = construct_sweep_lists ( params )

k = 0; 
for i = 1:32
  if params.is_sweep_list(i) ~=1
    continue;
  end
  k = k + 1; 
  sweeplist(k,:) = uint16 ( zeros(params.number_of_sweeps,1) );
  sweepdesc(k,:) = cellstr(deblank(params.descr_sweep_list(i,:))); 
  
  m = 1;
  if params.number_of_sweeps > 4096
    
    for j = 1:params.number_of_sweeps 
      switch i
       case 1,
	x =  bitand ( params.sweep_list((j*2)-1), 1 ) == 1; 
       case 2,
	x =  bitand ( params.sweep_list((j*2)-1), 2 ) == 2; 
       case 3,
	x =  bitand ( params.sweep_list((j*2)-1), 4 ) == 4; 
       case 4,
	x =  bitand ( params.sweep_list((j*2)-1), 8 ) == 8; 
       case 5,
	x =  bitand ( params.sweep_list((j*2)-1), 16 ) == 16; 
       case 6,
	x =  bitand ( params.sweep_list((j*2)-1), 32 ) == 32; 
       case 7,
	x =  bitand ( params.sweep_list((j*2)-1), 64 ) == 64; 
       case 8,
	x =  bitand ( params.sweep_list((j*2)-1), 128 ) == 128; 
       case 9,
	x =  bitand ( params.sweep_list(j*2), 1 ) == 1; 
       case 10,
	x =  bitand ( params.sweep_list(j*2), 2 ) == 2; 
       case 11,
	x =  bitand ( params.sweep_list(j*2), 4 ) == 4; 
       case 12,
	x =  bitand ( params.sweep_list(j*2), 8 ) == 8; 
       case 13,
	x =  bitand ( params.sweep_list(j*2), 16 ) == 16; 
       case 14,
	x =  bitand ( params.sweep_list(j*2), 32 ) == 32; 
       case 15,
	x =  bitand ( params.sweep_list(j*2), 64 ) == 64; 
       case 16,
	x =  bitand ( params.sweep_list(j*2), 128 ) == 128; 
       otherwise,
	x = 0;
      end
      if x == 1
	sweeplist(k,m)=j; 
	m = m +1;
      end
    end
  else 
    for j = 1:params.number_of_sweeps 
      switch i
       case 1,
	x =  bitand ( params.sweep_list((j*4)-3), 1 ) == 1; 
       case 2,
	x =  bitand ( params.sweep_list((j*4)-3), 2 ) == 2; 
       case 3,
	x =  bitand ( params.sweep_list((j*4)-3), 4 ) == 4; 
       case 4,
	x =  bitand ( params.sweep_list((j*4)-3), 8 ) == 8; 
       case 5,
	x =  bitand ( params.sweep_list((j*4)-3), 16 ) == 16; 
       case 6,
	x =  bitand ( params.sweep_list((j*4)-3), 32 ) == 32; 
       case 7,
	x =  bitand ( params.sweep_list((j*4)-3), 64 ) == 64; 
       case 8,
	x =  bitand ( params.sweep_list((j*4)-3), 128 ) == 128; 
       case 9,
	x =  bitand ( params.sweep_list((j*4)-2), 1 ) == 1; 
       case 10,
	x =  bitand ( params.sweep_list((j*4)-2), 2 ) == 2; 
       case 11,
	x =  bitand ( params.sweep_list((j*4)-2), 4 ) == 4; 
       case 12,
	x =  bitand ( params.sweep_list((j*4)-2), 8 ) == 8; 
       case 13,
	x =  bitand ( params.sweep_list((j*4)-2), 16 ) == 16; 
       case 14,
	x =  bitand ( params.sweep_list((j*4)-2), 32 ) == 32; 
       case 15,
	x =  bitand ( params.sweep_list((j*4)-2), 64 ) == 64; 
       case 16,
	x =  bitand ( params.sweep_list((j*4)-2), 128 ) == 128; 
       case 17,
	x =  bitand ( params.sweep_list((j*4)-1), 1 ) == 1; 
       case 18,
	x =  bitand ( params.sweep_list((j*4)-1), 2 ) == 2; 
       case 19,
	x =  bitand ( params.sweep_list((j*4)-1), 4 ) == 4; 
       case 20,
	x =  bitand ( params.sweep_list((j*4)-1), 8 ) == 8; 
       case 21,
	x =  bitand ( params.sweep_list((j*4)-1), 16 ) == 16; 
       case 22,
	x =  bitand ( params.sweep_list((j*4)-1), 32 ) == 32; 
       case 23,
	x =  bitand ( params.sweep_list((j*4)-1), 64 ) == 64; 
       case 24,
	x =  bitand ( params.sweep_list((j*4)-1), 128 ) == 128; 
       case 25,
	x =  bitand ( params.sweep_list(j*4), 1 ) == 1; 
       case 26,
	x =  bitand ( params.sweep_list(j*4), 2 ) == 2; 
       case 27,
	x =  bitand ( params.sweep_list(j*4), 4 ) == 4; 
       case 28,
	x =  bitand ( params.sweep_list(j*4), 8 ) == 8; 
       case 29,
	x =  bitand ( params.sweep_list(j*4), 16 ) == 16; 
       case 30,
	x =  bitand ( params.sweep_list(j*4), 32 ) == 32; 
       case 31,
	x =  bitand ( params.sweep_list(j*4), 64 ) == 64; 
       case 32,
	x =  bitand ( params.sweep_list(j*4), 128 ) == 128; 
       otherwise,
	x = 0;
      end
      if x == 1
	sweeplist(k,m)=j; 
	m = m +1;
      end
    end
  end
end

    

    
