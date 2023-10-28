
function showImgStat(ImgInfo,handles)
figImgStat=getappdata(0,'figImgStat');
hfig=0;
if ~isempty(figImgStat)
    if ishandle(figImgStat)
        hfig=1;
    end
end
if hfig
    set(0,'currentfigure',figImgStat);clf;
    ps=get(figImgStat,'Position');
    set(gcf,'position',[ps(1),ps(2),300,200*ImgInfo.allChs]);
else
    screenInfo=get(0,'ScreenSize');
    hfg=figure('position',[screenInfo(3)-700,100,300,200*ImgInfo.allChs],'NumberTitle','off','name','Color intensity');
    setappdata(0,'figImgStat',hfg);    
end
threshold=getappdata(0,'threshold');
signalCh=getappdata(0,'signalCh');
ylabelStr={'Red','Green','Blue'};
for i=1:ImgInfo.allChs
    subplot(ImgInfo.allChs,1,i);
    bar(ImgInfo.binX,ImgInfo.hist(:,i),'FaceColor',[.25,.25,.25]);
    yhi=prctile(ImgInfo.hist(:,i),97)+1;
    %mark the lower and upper 
    hold on;
    plot([1,1]*ImgInfo.clim(1,i),[0,yhi],'b','LineWidth',1);
    hold on;
    plot([1,1]*ImgInfo.clim(2,i),[0,yhi],'b','LineWidth',1);
    if signalCh==i
        hold on;
        plot([1,1]*threshold,[0,yhi],'r','LineWidth',1);
    end
    ylabel(ylabelStr{i});
    set(gca,'ytick',[],'ylim',[0,yhi]);
end