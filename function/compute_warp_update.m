function s = compute_warp_update(current_shape, delta, shape, coord_frame)

num_of_similarity_eigs = 4;
s0 = shape.s0;
S = shape.si;
Q = shape.s_star; 
triangles = coord_frame.triangles;
for k = 1:size(current_shape,1)
    % Find triangles per each point
    [triangles_per_point{k}, ~] = find(triangles == k);
end

% Get dr and dp, and compute ds0
dr = -delta(1:num_of_similarity_eigs);
dp = -delta(num_of_similarity_eigs + 1:end);
ds0 =  S * dp + Q * dr;
ds0 = reshape(ds0, [], 2);

% Compose new delta with current shape
s_new = compute_warp_composition(s0, ds0, current_shape, triangles, triangles_per_point);

% Project and reconstuct to get final shape
r = Q' * (s_new(:) - s0(:));
p = S'* (s_new(:) - s0(:));
s = s0(:) + S * p + Q * r;
s = reshape(s, [], 2);


