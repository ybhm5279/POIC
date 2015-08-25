%% The project out inverse compositional algorithm 
% proposed in active appearance model revisited
% ========================================================================
% 1/24/2014
display('*********** START *********')
clc;
clear;

%% initialize the setting
display('******** preprocess ********')
addpath(pwd);
addpath(fullfile(pwd,'data'));
addpath(fullfile(pwd,'function'));
opt.impath = 'E:\computer vision\Face Tracking\material\人脸数据库\300W\lfpw\testset\';
opt.imformat =  '*.png';
opt.lapath = 'E:\computer vision\Face Tracking\material\人脸数据库\300W\lfpw\testset\';
opt.laformat =  '*.pts';
opt.np = 68;
[imNames,gt_shape] = ini(opt); 
load AAM
%% compute SD
if exist('R.mat','file')
    display('******** load R  ********')
    load R
else
    display('******** compute constant R  ********')
    tic
    % R=-H^(-1)*J'
    R = getR(AAM);
    toc
    display('******** R over!  ********')
    save([pwd,'/data/','R.mat'],'R');
end

%% face detect
load initializations_LFPW;
s0 = AAM.shapemodel.s0;
s0 = reshape(s0,[], 2);
fit_opt.max_iter = 20;
fit_opt.R = R;
fit_opt.AAM = AAM;
display('******** begin fitting ********')
for i = 1 : numel(imNames)
    display(['******** fitting ',num2str(i),'th image ********'])
    %这一步为第i张图片的初始形状
    ini_shape = scl(i)*s0 + repmat(trans(i, :), size(s0,1), 1);
    %读取图片
    imagedata = imread(imNames{i});
    %变换为灰度图像
    if size(imagedata, 3) == 3
        input_image = double(rgb2gray(imagedata));
    else
        input_image = double(imagedata);
    end
    %开始匹配
    tic
    [ shape, lambda ] = fit2d(ini_shape, input_image, fit_opt);
    toc
    display(['******** ',num2str(i),'th image over! ********'])
    imshow(imagedata); hold on; plot(shape(:,1), shape(:,2), '.', 'MarkerSize',11);pause(0.5);close all;
    preShapes(:,:,i) = shape;
end
