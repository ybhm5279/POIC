function [ nor_imVec ] = normTex( imVec )
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
% Normalize appearance data grey values
color(2)=mean(imVec);
color(1)=std(imVec);
nor_imVec=(imVec-(color(2)))/color(1);

end

