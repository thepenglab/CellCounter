%load an image 
function [Image,ImgInfo]=loadImage(filename)
screenInfo=get(0,'ScreenSize');
imf0=imfinfo(filename);
ImgNumber=length(imf0);

ImgInfo=struct;
ImgInfo.Filename=imf0(1).Filename;
ImgInfo.imgNumber=ImgNumber;
ImgInfo.MinSampleValue=imf0(1).MinSampleValue;
ImgInfo.MaxSampleValue=imf0(1).MaxSampleValue;
r0=[imf0(1).Width/screenInfo(3),imf0(1).Height/screenInfo(4)];
r1=max(ceil(r0))+1;
ImgInfo.zoomRatios=1/r1:1/r1:2;
ImgInfo.currentZoomIndex=1;
ImgInfo.Width=imf0(1).Width;
ImgInfo.Height=imf0(1).Height;
ImgInfo.dispWid=round(ImgInfo.Width/r1);
ImgInfo.dispHei=round(ImgInfo.Height/r1);
ImgInfo.str=['Image size: ',num2str(ImgInfo.Width),' x ',num2str(ImgInfo.Height)];
    
chs0=length(imf0(1).BitsPerSample);
bitnum=imf0(1).BitsPerSample(1);
typeTag={'uint8','uint16','uint32'};
m=1;
if bitnum==8
	m=1;
elseif bitnum==12
    m=2;
elseif bitnum==16
    m=2;
elseif bitnum==32
    m=3;
end
Image=zeros(imf0(1).Height,imf0(1).Width,ImgNumber*chs0,typeTag{m});
    
allChs=0;
ImgInfo.clim=zeros(2,chs0);
ImgInfo.autoScale=zeros(2,chs0);
for i=1:ImgNumber
	k=(1:chs0)+(i-1)*chs0;
	Image(:,:,k)=imread(filename,i);
	ImgInfo.clim(:,k)=[imf0(i).MinSampleValue; imf0(i).MaxSampleValue];
	ImgInfo.chs(i)=imf0(i).SamplesPerPixel;
	allChs=allChs+ImgInfo.chs(i);
	%get image statistics
 	ImgStat=getImgStat(Image(:,:,k),imf0(i));
	ImgInfo.binX=ImgStat.x;
	[hLen,chs]=size(ImgStat.hist);
	ImgInfo.hist(1:hLen,k)=ImgStat.hist;
	ImgInfo.Threshold(k)=ImgStat.autoThreshold;
	ImgInfo.autoScale(:,k)=ImgStat.autoScale;
end
ImgInfo.allChs=allChs;
ImgInfo.Threshold(ImgNumber*chs0+1)=0;