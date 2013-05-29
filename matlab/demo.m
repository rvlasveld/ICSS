data = ProvideDataBatch(700, 'paper');
[Dks, Cks] = CenteredCusumValues(data);

figure;
plot(data);
figure;
plot(Dks);

change_points = ICSS(data)