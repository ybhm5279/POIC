function [ nor_imVec ] = normTex( imVec )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
% Normalize appearance data grey values
color(2)=mean(imVec);
color(1)=std(imVec);
nor_imVec=(imVec-(color(2)))/color(1);

end

