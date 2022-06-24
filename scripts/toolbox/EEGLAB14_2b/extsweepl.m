function sweeplist=extsweepl(params,sweepl);

sweeplist=params.sweeplist;
sweeplist=sweeplist(sweepl,find(sweeplist(sweepl,:)));
sweeplist=double(sweeplist);