function ImgStat=getImgStat(Image,ImgInfo)
ImgStat={};
chs=ImgInfo.SamplesPerPixel;
ImgStat.hist=zeros(256,chs);
ImgStat.autoThreshold=zeros(1,chs);
ImgStat.autoScale=zeros(2,chs);
coffset=30;
for i=1:chs
    M1=Image(:,:,i);
    [counts,x]=imhist(M1);
    ImgStat.hist(1:length(x),i)=counts;
    [m,idx]=max(counts(coffset:end));
    ImgStat.autoThreshold(i)=idx(1)+coffset-1+round(1.5*std2(M1));
    %for auto-display
    [a,b]=size(M1);
    M0=reshape(M1,a*b,1);
    ImgStat.autoScale(1,i)=prctile(M0,5);
    ImgStat.autoScale(2,i)=prctile(M0,99.9);
    if ImgStat.autoScale(2,i)==ImgStat.autoScale(1,i)
        ImgStat.autoScale(2,i)=ImgStat.autoScale(1,i)+0.1;
    end
end
ImgStat.x=x;