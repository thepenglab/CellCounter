%count cell numbers in each ROI
function ROIcells=countROIcells(ROIMap,cellMap)
ROINum=max(ROIMap(:));
ROIcells=zeros(1,ROINum);
ptnum=size(cellMap,1);
for i=1:ptnum
    x=floor(cellMap(i,1));
    y=floor(cellMap(i,2));
    if x>0 && y>0
        px=ROIMap(y,x);
        if px>0
            ROIcells(px)=ROIcells(px)+1;
        end
    end
end