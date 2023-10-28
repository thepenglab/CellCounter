%get ROIMap from ROI
function ROIMap=getROIMap(ROI,ImgSize)
ROIMap=zeros(ImgSize(2),ImgSize(1));
num=length(ROI);
for i=1:num
    bk1=poly2mask(ROI(i).xy(:,1),ROI(i).xy(:,2),ImgSize(2),ImgSize(1));
    ROIMap=ROIMap+bk1*i;
end