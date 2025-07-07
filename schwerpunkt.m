% Daten
x = 0:20;
y = 2+ randn(size(x)) - cos(x);
plot(x,y);

% Flächeninhalt
A = cumtrapz(y);
figure(2);
plot(x,A)

% x-Koordinate des Schwerpunktes
xs = cumtrapz(x.*y)./A;
figure(3);plot(x,xs);

% y-Koordinate des Schwerpunktes
ys = cumtrapz(y.^2)./(2*A);
figure(4);plot(x,ys);


