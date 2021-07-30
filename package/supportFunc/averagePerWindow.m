function X = averagePerWindow(X, srate, windowLength)

% Inputs
%   X:            column vector
%   srate:        sampling rate of X
%   windowLength: size of window in seconds
% Ouputs
%   X:            averaged values of X within each window

% Check that X is not a matrix
if ~isvector(X)
    error('X must be a row vector')
end
% force column vector
if size(X, 1) > 1
    X = X';
end

% Crop signal to precicely accomodate all windows
maxWindows = floor(length(X)/(srate*windowLength));
X = X(1:maxWindows*windowLength*srate);

% Reshape the vector to a matrix <samples in a window x windows>
% And calculate the mean for each window.
X = nanmean(reshape(X, srate*windowLength, length(X)/(srate*windowLength)));
