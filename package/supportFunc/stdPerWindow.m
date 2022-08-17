function X = stdPerWindow(X, srate, windowLength)

% Check that X is not a matrix
if ~isvector(X)
    error('X must be a row vector')
end
% force row vector
if size(X,1) > 1
    X = X';
end

% Crop signal to precicely accomodate all windows
maxWindows = floor(length(X)/(srate*windowLength));
X = X(1:maxWindows*windowLength*srate);
X = std(reshape(X, srate*windowLength, length(X)/(srate*windowLength)), 'omitnan');
