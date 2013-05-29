function [ Dk, Ck ] = CenteredCusumValues( data )
%CENTERED_CUSUM_VALUES Calculate the centered and normalized cumulative sum of squared
%   Based on 'Use of Cumulative Sums of Squares for Retrospective Detection
%   of Changes of Variance', by Inclan and Tiao, 1994
%
%   input: the data the process
%   ouput: 
%       - the centerd and normalised cumulative sums,
%       - the cumulative sums,
%       - the position for which |Dk| is max

    squared = data.^2;
    Ck = cumsum(squared);
    CT = Ck(end);
    T = length(data);
    ks = 1:T;
    
    Dk = Ck./CT - (ks/T);
end

