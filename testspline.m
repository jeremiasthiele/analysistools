% Beispiel-Daten (x, y)
x = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
y = [4, 3, 5, 4, 6, 8, 7, 9, 10, 8];  % Beispielhafte y-Werte

% Anzahl der Punkte
n = length(x);

% Berechne den Spline mit den Randbedingungen (Steigung 0 am Anfang und Ende)
% Wir verwenden den "Clamped" Spline, bei dem die Steigung an den Endpunkten gleich 0 ist
pp = spline(x, [0, y, 0]);  % Randbedingungen: Steigung 0 am Anfang und Ende

% Berechne den interpolierten Spline über ein feineres x-Gitter
xx = linspace(min(x), max(x), 100);  % Feinere x-Werte für den Spline
yy = ppval(pp, xx);  % Berechne die y-Werte des Splines

% Visualisierung
figure(3);
plot(x, y, 'ro', 'MarkerFaceColor', 'r');  % Originaldaten
hold on;
plot(xx, yy, 'b-', 'LineWidth', 2);  % Interpolierter Spline
xlabel('x');
ylabel('y');
title('Spline-Interpolation mit Randbedingungen (Steigung = 0 am Anfang und Ende)');
legend('Datenpunkte', 'Spline');
grid on;
