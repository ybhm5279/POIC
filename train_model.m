%% Script to perform AAMs building
% ========================================================================
%% AAMs building after learning:
%% [1] G. Tzimiropoulos, and M. Pantic, "Optimization problems for fast AAM
%% fitting in-the-wild," ICCV 2013
% Training an AAM consists of the following steps
% A. Read shapes and apply Procrustes to remove similarity transforms (scale-rotation-translation)
%    This step produces: (i) the mean shape and (ii) the similarity-free shapes
% B. Create shape model by appying PCA on the similarity-free shapes
% C. Create the coordinate frame of the AAM. This is where all calculations take place.
%    We create one coordinate frame for every scale (i.e resolution)
% D. Read images and warp them to mean shape using a piecewise affine warp. This will
%    create the shape-free textures
% E. Create texture model by appying PCA on the shape-free textures

% 1/18/2015
% min shaobo

display('*********** start *********')
clc;
close all;
clear;

%% initialize the settings
addpath(pwd);
addpath(fullfile(pwd,'data'));
addpath(fullfile(pwd,'function'));
opt.impath = 'E:\computer vision\Face Tracking\material\ÈËÁ³Êý¾Ý¿â\300W\lfpw\trainset\';
opt.imformat =  '*.png';
opt.np =68;
[imNames,shapes] = ini(opt); 
%% building begin
AAM_opt.max_s = 10;%AAM_opt.max_s = 0.95
AAM_opt.max_t = 20;%AAM_opt.max_t = 0.95
tic;
AAM = AAMBuilding( imNames,shapes,AAM_opt );
toc;
save(fullfile(pwd,'data/AAM'),'AAM');
display('*********** AMMs have been built *********')