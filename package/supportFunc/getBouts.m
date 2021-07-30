function [onset, duration] = getBouts(X)

% Input
%   X:        Logical vector
% Output
%   onset:    vector of indices where X turns from 0 to 1
%   duration: vector of sample-length of consequtive 1's

% Check that X is not a matrix
if ~isvector(X)
    error('X must be a row vector')
end
% force column vector
if size(X,2) > 1
    X = X';
end

onset    = find(diff([0;X]) == 1);
duration = (find(diff([X;0]) == -1) - onset) + 1;