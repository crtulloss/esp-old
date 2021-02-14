h0 = readmatrix('h0.csv');
h1 = readmatrix('h1.csv');
h2 = readmatrix('h2.csv');
h3 = readmatrix('h3.csv');
h4 = readmatrix('h4.csv');
h5 = readmatrix('h5.csv');

h = vertcat(h0,h1,h2,h3,h4,h5);
writematrix(h,'h.csv');