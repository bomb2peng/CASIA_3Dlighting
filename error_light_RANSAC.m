function [E T_noise_squared d] = error_light_RANSAC(Theta, X, sigma, P_inlier, parameters)

% [E T_noise_squared d] = error_light_RANSAC(Theta, X, sigma, P_inlier)
%
% DESC:
% estimate the squared fitting error for lighting estimation

% compute the squared error
E = [];
if ~isempty(Theta) && ~isempty(X)
    E = (X(2:10,:)'*Theta - X(1,:)').^2;           
end;

% compute the error threshold
if (nargout > 1)
    
    if (P_inlier == 0)
        T_noise = sigma;
    else
        % Assumes the errors are normally distributed. Hence the sum of
        % their squares is Chi distributed (with 1 DOF since we are 
        % computing the distance of a 1D pixel value)
        d = 1;
        
        % compute the inverse probability
        T_noise_squared = sigma^2 * chi2inv_LUT(P_inlier, d);

    end;
    
end;

return;
