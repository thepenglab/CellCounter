function updateImage(Image,cellMap,ROI)
figImage=getappdata(0,'figImage');
if ~ishandle(figImage)
    return;
else
    set(0,'currentfigure',figImage);
    if ~isempty(Image)
        imshow(Image);
    end
end
viewFlag=getappdata(0,'viewFlag');
if ~isempty(cellMap)
    cellMarker=getappdata(0,'cellMarker');
    mk={'o','.','+'};
    h1=getappdata(0,'cellMaphandle');
    if ishandle(h1)
        delete(h1);
    end
    if viewFlag(1)
        hold on;
        h2=plot(cellMap(:,1),cellMap(:,2),'r','LineStyle','none',...
            'Marker',mk{cellMarker(1)},'MarkerSize',cellMarker(2));
        setappdata(0,'cellMaphandle',h2);
    end
end
if ~isempty(ROI)
    cROIn=length(ROI);
    for i=1:cROIn
        if ishandle(ROI(i).handle)
            delete(ROI(i).handle);
            delete(ROI(i).tagHandle);
        end
    end
    if viewFlag(2)
        for i=1:cROIn
            hold on;
            h1=plot(ROI(i).xy(:,1),ROI(i).xy(:,2),'--w');
            ROI(i).handle=h1;
            x1=mean(ROI(i).xy(:,1));
            y1=mean(ROI(i).xy(:,2));
            tagStr=[num2str(i),' ',ROI(i).tag];
            h2=text(x1,y1,tagStr,'Color','w');
            ROI(i).tagHandle=h2;
        end
        setappdata(0,'ROI',ROI);
    end
end