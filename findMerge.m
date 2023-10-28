function [cellMap,maskImage]=findMerge(allCellMaps,allMaskImages)
cellMap=[];
maskImage=[];
if isempty(allCellMaps{1}) || isempty(allCellMaps{2})
    return;
end
maskImage01=allMaskImages(:,:,1) & allMaskImages(:,:,2);
cc=bwconncomp(maskImage01,8);
maskImage=labelmatrix(cc);
ss=regionprops(cc,'Centroid','Area');
cellMap=zeros(cc.NumObjects,3);     %x,y,area
for i=1:cc.NumObjects
	cellMap(i,1:2)=ss(i).Centroid;
	cellMap(i,3)=ss(i).Area;
end