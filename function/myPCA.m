function [U,eiv] = myPCA(data, var)
[pc, ~, eiv_] = princomp(data', 'econ');
if var>1
    p = min([length(eiv_),var]);
    U = pc(:,1:p);
    eiv = eiv_(1:p);
else
    if var < 0
        error('myPCA: variation must be greater than 0');
    end
    % Normalize eigenvalues to sum at 1
    neiv = eiv_./sum(eiv_);
    covered = 0;
    i = 1;
    while covered < var
		covered = covered + neiv(i);
		i = i + 1;
    end
    % Count number of eigenvalue needed to cover desired variation
    U = pc(:,1:i-1);
    eiv = eiv_(1:i-1);
end