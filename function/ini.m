function [imNames,shapes] = ini(opt)
%INI 此处显示有关此函数的摘要
%   此处显示详细说明
if exist('shapes.mat','file')&&exist('imNames.mat','file')
    load shapes;
    load imNames;
else
    impath = opt.impath;
    imformat = opt.imformat;
    np = opt.np;

    imlist = dir([impath, imformat]);
    for i=1:length(imlist )
        fname = imlist(i).name;
        imNames{i} = [impath,fname];
        laName = strcat(imNames{i}(1:end-3),'pts');
        shapes(:,:,i) = read_shape(laName, np);
%         [data1,data2]=textread(lalist(i).name,'%n%n',np,'headerlines',3);
%         shapes(:,:,i)=[data1,data2];
    end
end

