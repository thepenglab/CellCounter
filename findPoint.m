%to determine if a point is within the cellMap
function pt=findPoint(point,cellMap,r)
%range of searching (pixel)
%r=10;
con1=(cellMap(:,1)>=point(1)-r & cellMap(:,1)<=point(1)+r);
con2=(cellMap(:,2)>=point(2)-r & cellMap(:,2)<=point(2)+r);
pt=find(con1 & con2);
%only return one point
if length(pt)>1
    pt=pt(1);
end