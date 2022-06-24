function differenz_plot
fig1 = input('Figure #1: ');
fig2 = input('Figure #2: ');
% h = findobj('Type', 'figure');


% Get itc from pictures
im = findobj(fig1, 'Type', 'image');
itc{1} = get(im, 'CData');
freqs{1} = get(im, 'YData');
time{1} = get(im, 'XData');

im = findobj(fig2, 'Type', 'image');
itc{2} = get(im, 'CData');
freqs{2} = get(im, 'YData');
time{2} = get(im, 'XData');


figure
imagesc(time{1},freqs{1},itc{1}-itc{2})
axis xy
xlabel('Time [ms]')
ylabel('Frequency [Hz]')
title(['Differenzplot: figure(' num2str(fig1) ') - figure(' num2str(fig2) ')'])
colorbar

