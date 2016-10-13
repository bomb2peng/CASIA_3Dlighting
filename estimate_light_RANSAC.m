function [Theta, k] = estimate_light_RANSAC(X, s, parameters)

% [Theta k] = estimate_light_RANSAC(X, s)
%
% DESC:
% estimate the parameters of 3D lighting environment given the pairs [b, M(i,:)]^T
% Theta = 9x1 where M(i,:)*Theta = b

% cardinality of the MSS
k = parameters;

if (nargin == 0) || isempty(X)
    Theta = [];
    return;
end;

if (nargin >= 2) && ~isempty(s)
    X = X(:, s);
end;

% check if we have enough points
N = size(X, 2);
if (N < k)
    error('estimate_line:inputError', ...
        'At least 2 points are required');
end;

b = X(1,:)';
M = X(2:10,:)';
Theta = (M'*M)\M'*b;

return;
