function AAM = AAMBuilding( imNames,shapes,opt )
%% building AAMs including shapemodel,texturemodel,warpmodel.
%   INPUT:
%       imNames: 图片的名字
%       shapes: np-by-2-by-n笛卡尔坐标
%       opt: pca系数
%% read data
max_s = opt.max_s;
max_t = opt.max_t;

%% AAMs begin building
% number of points
np = size(shapes, 1);
% size of training set
ns = size(shapes, 3);

%% align shapes
% align all shapes to the mean shape
% aligned shapes
% Translate each shape to the origin
aligned_shapes = shapes - repmat(mean(shapes, 1), size(shapes, 1), 1);
mean_shape = mean(aligned_shapes, 3);

iteration = 0;
max_iteration = 100;

while (iteration<=max_iteration)
    % Align all shapes with current mean shape
    for i=1:size(shapes,3)
        [~, aligned_shapes(:,:,i)] = procrustes(mean_shape, aligned_shapes(:,:,i));
    end
    
    % Update mean shape
    mean_shape_new = mean(aligned_shapes, 3);
    [~, mean_shape_new] = procrustes(mean_shape, mean_shape_new);
    mean_shape = mean_shape_new;
    
    iteration = iteration + 1;
end
%% shapemodel building
% mean shape
s0 = reshape(mean(aligned_shapes, 3),[],1);
%PCA
shape_matrix = reshape(aligned_shapes,[],ns) - repmat(s0(:), [1 ns]);
[pc,eiv] = myPCA(shape_matrix, max_s);
% Build the basis for the global shape transformg
s_star = zeros(np*2, 4);
% Parameterizing a global 2D similarity transform
s_star(:,1) = s0;
s_star(:,2) = [-s0(np+1:end,1); s0(1:np,1)];
s_star(:,3) = [ones(np, 1); zeros(np, 1)];
s_star(:,4) = [zeros(np, 1); ones(np, 1)];
% Orthogonalization of all eigenevectors
s_star = gs_orthonorm(s_star);
S_all = gs_orthonorm([s_star, pc]);
s_star = S_all(:, 1:size(s_star, 2));
si = S_all(:, size(s_star, 2)+1:end);

shapemodel.s0 = s0;
shapemodel.si = si;
shapemodel.shape_eiv = eiv;
shapemodel.s_star = s_star;
%% warpmodel building
% Determine the region of interest 
base_shape = reshape(s0,[],2);
mini = min(base_shape(:,2));
minj = min(base_shape(:,1));
maxi = max(base_shape(:,2));
maxj = max(base_shape(:,1));
base_shape = reshape(base_shape - repmat([minj - 2, mini - 2], [np, 1]), 2*np, 1);
% warp map building
modelw = ceil(maxj - minj + 3);
modelh = ceil(maxi - mini + 3);
% triangles
triangles = delaunay(base_shape(1:np)',base_shape(1+np:end)');
warp_map = zeros(modelh, modelw);
for i=1:size(triangles,1)
    % vertices for each triangle
    X = base_shape(triangles(i,:),1);
    Y = base_shape(triangles(i,:)+np,1);
    % mask for each traingle
    mask = poly2mask(X,Y,modelh, modelw) .* i;
    % the complete base texture
    warp_map = max(warp_map, mask);
end
alpha = zeros(modelh, modelw);
beta = zeros(modelh, modelw);
% for each point
for ii = 1:size(triangles,1)
    % Find points at each triangle
    [all_i,all_j] = find(warp_map == ii);
    u = base_shape(triangles(ii,:));
    v = base_shape(triangles(ii,:)+np);
    i1 = v(1);
    j1 = u(1);
    i2 = v(2);
    j2 = u(2);
    i3 = v(3);
    j3 = u(3);
    % for each triangle of this point
    for jj = 1:length(all_i)
        i = all_i(jj);
        j = all_j(jj);
        % Compute the two barjcentric coordinates using Cramer's Rule
		den = (i1 - i3) * (j2 - j3) - (i2 - i3) * (j1 - j3);
		alpha(i,j) = ((i - i3) * (j2 - j3) - (i2 - i3) * (j - j3)) / den;
		beta(i,j) = ((i1 - i3) * (j - j3) - (i - i3) * (j1 - j3)) / den;
    end
end
% warp image to vector
% This is an implementation detail, but quite important.
% When we warp the images to the mean shape below, we may want to mask out 1
% boundary pixel. This is because there might be error in the annotations,
% and usually boundary pixels might belong to the background of the
% image and not the face.
mask = warp_map; mask(mask>0) = 1; mask = double(mask);
mask = imerode(mask, strel('square',3));
ind_in = find(mask == 1);
ind_out = find(mask == 0);
mask2 = imerode(mask, strel('square', 3));
ind_in2 = find(mask2 == 1);
ind_out2 = find(mask2 == 0);

warpmodel.triangles = triangles;
warpmodel.warp_map = warp_map;
warpmodel.base_shape = base_shape;
warpmodel.alpha = alpha;
warpmodel.beta = beta;
warpmodel.ind_in = ind_in;
warpmodel.ind_out = ind_out;
warpmodel.ind_in2 = ind_in2;
warpmodel.ind_out2 = ind_out2;
%% texturemode building
j = 1;
for i=1:numel(imNames)
	imagedata = imread(imNames{i});
    if size(imagedata, 3) == 3
        app_data = double(rgb2gray(imagedata));
    else
        app_data = double(imagedata);
    end
    app = warp_image(shapes(:,:,i),app_data,warpmodel);
    app_vec = reshape(app,[],1);
    % mask out 1 boundary pixel
    app_vec(ind_out) = [];
    % check if warped data is fine
    temp = sum(isnan(app_vec));
    if ((temp == 0) && max(app_vec) <= 255)
        app_vecs(:,j) = app_vec;
        j = j + 1;
    end
end
A0 = mean(app_vecs, 2);
% Prepare appearances for PCA
app_vecs = app_vecs - repmat(A0,1,size(app_vecs,2));
[pc eiv] = myPCA(app_vecs, max_t);

AA0 = zeros(modelh*modelw, 1);
AA0(ind_in) = A0;
AAi = zeros(modelh*modelw, size(pc,2));
for i = 1:size(AAi, 2)
    AAi(ind_in, i) = pc(:, i);
end
AA0(ind_out2) = [];
AAi(ind_out2, :) = [];
AAi = gs_orthonorm(AAi);

texturemodel.A0 = A0;
texturemodel.Ai = pc;
texturemodel.app_eiv = eiv;
texturemodel.AA0 = AA0;
texturemodel.AAi = AAi;
%% 
AAM.shapemodel = shapemodel;
AAM.texturemodel = texturemodel;
AAM.warpmodel = warpmodel;
