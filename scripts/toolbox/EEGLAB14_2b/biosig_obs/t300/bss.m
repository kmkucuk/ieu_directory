function [W] = bss(data,Mode,M,maxlag)
%  BSS is a wrapper for various Blind Source Separation algorithms
%
%  W = bss(data, Mode)
%  W = bss(data, Mode, M)
%  W = bss(data, Mode, [], maxlag)
%  W = bss(data, Mode, M, maxlag)
%
%  W: 	   unmixing matrix
%  data:   signal data (each column is a channel)
%  M: 	   [optional] number of components.
%  maxlag: maximum lag for time delayed separation 	
%  Mode:   algorithm used. Currently are supported: 
%	PCA
%	JADE
%	NGCA
% 	FFDIAG 
%	TDSEP (old not recommended)
%	TDSEP1 
%	TDSEP3  

%	$Id$
%	Copyright (C) 2007 by Alois Schloegl 
%    	This is part of the BIOSIG-toolbox http://biosig.sf.net/

% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Library General Public
% License as published by the Free Software Foundation; either
% Version 2 of the License, or (at your option) any later version.


if ~exist('jade','file')
	addpath([getenv('HOME'),'/matlab/other/jade']);
end;
if ~exist('NGCA','file')
	addpath('/home/neuro/schalo/cvs/neuro_cvs/Tex/codename_spok/code/JMLR_paper'); 
end; 
if ~exist('tdsep','file')
%	addpath('/home/neuro/schalo/cvs/neuro_cvs/matlab/meg_lab/'); 
end; 
if ~exist('tdsep0','file')
	addpath('/home/neuro/schalo/cvs/neuro_cvs/matlab/bci/ica/'); 
end; 
if ~exist('ffdiag2','file')
	addpath('/home/dropbox/IDA/ziehe/ffdiag'); 
end; 
if ~exist('tdsep3','file')
	addpath('/home/neuro/schalo/matlab/other/motoaki/'); 
end; 

r = rank(data); 
m = size(data,2);
if nargin<3,
	M = r;
end; 	
if isempty(M),
	M = r;
end; 	

Mode = upper(Mode); 

[u,s,v]=svd(data,0); 
V = v*inv(s);

data= center(data);
V0 = inv(sqrtm(covm(data,'D')));   %% whitening or sphering
data = data*V0';

save matlab_bss V V0

if 0, 
elseif strcmp(Mode,'PCA')
	[u,s,W] = svd(tmp,M); % get k (i.e. FLAG.PCA) largests PCA's

elseif strcmp(Mode,'JADE')
	W = jade(data', M)'; 

elseif strcmp(Mode,'NGCA')
	[W, projdata, signalmatrix] = NGCA(data',M);	

elseif strcmp(Mode,'FFDIAG')
	C   = zeros(m,m,maxlag+1);
	for k = 1:maxlag+1,
		C(:,:,k) = tdCorr(data', k-1);
	end
	[W,d] = ffdiag2(C);
elseif strcmp(Mode,'TDSEP')
	[W,d] = tdsep(data',0:maxlag);

elseif strcmp(Mode,'TDSEP0')
	[W] = tdsep0(data',0:maxlag);

elseif strcmp(Mode,'TDSEP3')
	[W,d] = tdsep3(data',0:maxlag);
end;

W = V0*W; 