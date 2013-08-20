function change_points = visual_ICSS( data )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    if size(data, 1) > size(data, 2)
        data = data';
    end

    [Dks, Cks] = CenteredCusumValues(data);

    figure;
    plot(Dks);

    figure;
    plot(data);

    change_points = ICSS(data);

    yL = get(gca, 'YLim');
    for i=1:length(change_points)
        cp = change_points(i);
        line([cp cp], yL, 'Color', 'r');
    end

end

