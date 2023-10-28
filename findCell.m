%method: edge detection+threshold+center
%cellMap=[x,y,area] of each cell
%maskImage n-labelled 2D-image
function [cellMap,maskImage]=findCell(Image,threshold)
cellMap=[];
%get edge image
I1=edge(Image);
%remove very small objects
I2=bwareaopen(I1,3);
%try to connect open-circles
se=strel('disk',2);
%M4=imdilate(M3,se);
I2=imclose(I2,se);
%get reverse image for center-based detection
I3=~I2;
%use intensity threshold
M1=Image>threshold;
%combine edge with threshold
M2=M1.*I2;
M2=bwareaopen(M2,5);
cc1=bwconncomp(M2,8);
if cc1.NumObjects==0
    return;
end
%estimate cell-size (area)
ss=regionprops(cc1,'Centroid','ConvexArea','Perimeter');
ar=[ss.ConvexArea];
cellMinArea=median(ar);
cellMaxArea=median(ar)*10;
idx=find(ar>cellMinArea & ar<cellMaxArea & ar>[ss.Perimeter]+cellMinArea/3);
MM2=ismember(labelmatrix(cc1), idx); 
cellMedianArea=median(ar(idx));
%add closely-connected cells, center-based
M3=M1.*I3;
M3=bwareaopen(M3,3);
cc2=bwconncomp(M3,4);
ss2=regionprops(cc2,'Area','Perimeter');
ar2=[ss2.Area];
pr2=[ss2.Perimeter];
idx2=find(ar2>cellMedianArea/3 & ar2<cellMedianArea*3 & ar2>pr2*1.2);
MM3=ismember(labelmatrix(cc2), idx2); 
%combine two images
MM=MM2|MM3;
cc=bwconncomp(MM,8);
ss=regionprops(cc,'Area');
ar=[ss.Area];
%remove un-usual big objects
th1=mean(ar)+3.5*std(ar);
idx3=find(ar<th1);
maskImage01=ismember(labelmatrix(cc),idx3);
cc=bwconncomp(maskImage01,8);
maskImage=labelmatrix(cc);
ss=regionprops(cc,'Centroid','Area');
cellMap=zeros(cc.NumObjects,3);     %x,y,area
for i=1:cc.NumObjects
	cellMap(i,1:2)=ss(i).Centroid;
	cellMap(i,3)=ss(i).Area;
end
disp(['Median Area of a cell: ',num2str(median(cellMap(:,3)))]);

