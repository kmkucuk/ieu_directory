function get_itc_mean()

% Oeffne irgendein ITC oder Power Bild und
% klicke mit dem Mauszeiger drauf

itc = get(gco, 'CData');
freqs = get(gco, 'YData');
time = get(gco, 'XData');

% Waehle Zeitfenster
window_time = input('Zeitfenster (z.B. [-200 0]): ');
window_freq = input('Frequenzfenster (z.B. [1 10]): ');

if isempty(window_time) | isempty(window_freq)
    return
end

i_freq(1) = find(freqs==window_freq(1));
i_freq(2) = find(freqs==window_freq(2));

i_time(1) = find(time==window_time(1));
i_time(2) = find(time==window_time(2));
