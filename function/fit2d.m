function [ shape, lambda ] = fit2d(ini_shape, input_image, fit_opt)
%FIT2D 此处显示有关此函数的摘要
%   此处显示详细说明
%% initialize setting
% load data
max_iter = fit_opt.max_iter;
R = fit_opt.R;
shapemodel = fit_opt.AAM.shapemodel;
texturemodel = fit_opt.AAM.texturemodel;
warpmodel = fit_opt.AAM.warpmodel;
A0 = texturemodel.A0;
Ai = texturemodel.Ai;
AA0 = texturemodel.AA0;
ind_out = warpmodel.ind_out;
ind_out2 = warpmodel.ind_out2;
% Initialize current shape
cur_shape = ini_shape;
iter = 1;

%% begin fitting
while iter<max_iter
    % compute the cost function
    %将输入图像中ini_shape部分的纹理抠出来
    image_warped = reshape(warp_image(cur_shape, input_image,warpmodel), [], 1);
    iw_out2 = image_warped(:);
    iw_out2(ind_out2) = [];
    %得到图片和模板之间的误差，即(I(s;p;q)-A0);
    error_img = iw_out2 - AA0;
    % delta_p = R* (I(s;p;q)-A0),0.01为控制系数，可不管，有无都可，平衡速度和精度的存在
    d_para = 0.01*R * error_img;
    % 得到新的形状模型p后，合成新形状
    cur_shape =  compute_warp_update(cur_shape, d_para, shapemodel, warpmodel);
    iter = iter + 1;
end

%% output result
% shape
shape = cur_shape;
% app
iw_out = image_warped;
iw_out(ind_out) = [];
lambda = Ai'*(iw_out - A0) ;
end

