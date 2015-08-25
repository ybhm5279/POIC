function warped_image = warp_image(shape,app_data,warpmodel)

triangles = warpmodel.triangles;
warp_map = warpmodel.warp_map;
alpha_coords = warpmodel.alpha;
beta_coords = warpmodel.beta;

num_of_triangles = size(triangles, 1);

warped_image = zeros(size(warp_map));

for t = 1:num_of_triangles
    [u, v] = find(warp_map == t);
    ind_base = u + (v-1) * size(warp_map,1);
    
    warped_coords = alpha_coords(ind_base)*shape(triangles(t,1),:)+beta_coords(ind_base)*shape(triangles(t,2),:)+(1-alpha_coords(ind_base)-beta_coords(ind_base))*shape(triangles(t,3),:);
    warped_coords = round(warped_coords);
    ind = find(warped_coords<=0);
    warped_coords(ind) = 1;
    ind_warped = warped_coords(:,2) + (warped_coords(:,1)-1) * size(app_data, 1);
    warped_image(ind_base) = app_data(ind_warped);
end
end

