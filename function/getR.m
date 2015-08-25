function R = getR(AAM)
%% initialize
shapemodel = AAM.shapemodel;
texturemodel = AAM.texturemodel;
warpmodel = AAM.warpmodel;
s0 = shapemodel.s0;
si = shapemodel.si;
s_star = shapemodel.s_star;
A0 = texturemodel.A0;
AAi = texturemodel.AAi;
warp_map = warpmodel.warp_map; 
triangles = warpmodel.triangles;
alpha = warpmodel.alpha;
beta = warpmodel.beta;
ind_in = warpmodel.ind_in;
ind_out2 = warpmodel.ind_out2;
% number of points
np = size(s0, 1)/2;
ns = size(si,2);
% Size of the model
modelh = size(warp_map,1);
modelw = size(warp_map,2);

%% compute gradient
% warp A0 to image
I = zeros(modelh,modelw);
I(ind_in) = A0;
[di,dj] = gradient(I);
di(ind_out2) = 0;
dj(ind_out2) = 0;
mean_app_gradient(:,:,1) = di;
mean_app_gradient(:,:,2) = dj;
	
%% compute dp and dq
dp = zeros(modelh,modelw,2,ns);
dq = zeros(modelh,modelw,2,4);
for i = 1 : modelh
    for j = 1 : modelw
        if warp_map(i,j) ~= 0
            % Only the vertices of the triangle containing the pixel are of relevance
            % in determining the Jacobian.
            v = triangles(warp_map(i,j),:);
        
        	% Now we need the barycentric coordinates of (i,j) computed using 
            % point 'k' as the origin. So we rearrange the order of the vertices
            % (it doesn't matter if the result has clockwise or counterclockwise
            % winding)
            dp(i,j,1,:) = [alpha(i,j),beta(i,j),(1-alpha(i,j)-beta(i,j))]*si(v,:); 
            dp(i,j,2,:) = [alpha(i,j),beta(i,j),(1-alpha(i,j)-beta(i,j))]*si(v+np,:);
                
            dq(i,j,1,:) = [alpha(i,j),beta(i,j),(1-alpha(i,j)-beta(i,j))]*s_star(v,:); 
            dq(i,j,2,:) = [alpha(i,j),beta(i,j),(1-alpha(i,j)-beta(i,j))]*s_star(v+np,:);
        end
	end
end				

for i = 1 : 4
    SD(:,:,i) = mean_app_gradient(:,:,1) .* dq(:,:,1,i) + mean_app_gradient(:,:,2) .* dq(:,:,2,i);
end
for i = 1 : ns
    SD(:,:,i+4) = mean_app_gradient(:,:,1) .* dp(:,:,1,i) + mean_app_gradient(:,:,2) .* dp(:,:,2,i);
end
SD = reshape(SD,[],4+ns);
SD(ind_out2,:) = [];

%% project out
SD_po = SD - AAi*(AAi'*SD);
H = SD_po' * SD_po;
R = inv(H)*SD_po';
end

