function [ shape, lambda ] = fit2d(ini_shape, input_image, fit_opt)
%FIT2D �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
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
    %������ͼ����ini_shape���ֵ�����ٳ���
    image_warped = reshape(warp_image(cur_shape, input_image,warpmodel), [], 1);
    iw_out2 = image_warped(:);
    iw_out2(ind_out2) = [];
    %�õ�ͼƬ��ģ��֮�������(I(s;p;q)-A0);
    error_img = iw_out2 - AA0;
    % delta_p = R* (I(s;p;q)-A0),0.01Ϊ����ϵ�����ɲ��ܣ����޶��ɣ�ƽ���ٶȺ;��ȵĴ���
    d_para = 0.01*R * error_img;
    % �õ��µ���״ģ��p�󣬺ϳ�����״
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

