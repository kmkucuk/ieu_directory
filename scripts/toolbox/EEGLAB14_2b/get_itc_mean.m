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

try
    [t, i_freq(1)] = min(abs(freqs-window_freq(1)));
    [t, i_freq(2)] = min(abs(freqs-window_freq(2)));
catch
    disp('Error: Frequenzfenster zu groﬂ');
    return
end

try
    [t, i_time(1)] = min(abs(time-window_time(1)));
    [t, i_time(2)] = min(abs(time-window_time(2)));
catch
    disp('Error: Zeitfenster zu groﬂ')
    return
end
new_itc = itc(i_freq(1):i_freq(2),i_time(1):i_time(2));
meanitc = mean(mean(new_itc));
stditc = std(std(new_itc));
disp('Die mittlere ITC im gewaehlten Zeitfenster ist:' )
fprintf('%g +- %g\n', meanitc, stditc);

