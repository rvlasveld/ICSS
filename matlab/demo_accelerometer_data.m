csv = load('../data/sit-walk-turn-walk-turn-walk-sit.csv');

% Get the x-accelerometer values
s = csv(:,3);

d = reshape(s.', 1, [] );
visual_ICSS(d);