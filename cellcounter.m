function varargout = cellcounter(varargin)
% CELLCOUNTER MATLAB code for cellcounter.fig
%      CELLCOUNTER, by itself, creates a new CELLCOUNTER or raises the existing
%      singleton*.
%
%      H = CELLCOUNTER returns the handle to a new CELLCOUNTER or the handle to
%      the existing singleton*.
%
%      CELLCOUNTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CELLCOUNTER.M with the given input arguments.
%
%      CELLCOUNTER('Property','Value',...) creates a new CELLCOUNTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cellcounter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cellcounter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cellcounter

% Last Modified by GUIDE v2.5 02-Dec-2019 21:52:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cellcounter_OpeningFcn, ...
                   'gui_OutputFcn',  @cellcounter_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before cellcounter is made visible.
function cellcounter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cellcounter (see VARARGIN)

% Choose default command line output for cellcounter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cellcounter wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%init once 
handles=initOnce(handles);
%init data
handles=init(handles);
setappdata(0,'handles',handles);
guidata(hObject, handles);


%init only once
function handles=initOnce(handles)
versionName='Cellcounter 1.4 2020@YP-CU';
set(handles.text_info_version,'String',versionName);
setappdata(0,'PathName','C:\');
setappdata(0,'figImage',[]);
setappdata(0,'figImgStat',[]);
setappdata(0,'figFileList',[]);
setappdata(0,'infoHandles',[]);
setappdata(0,'colorCh',0);      %color channel for adjusting display
setappdata(0,'funcTag',0);      %function tag for buttonDown, 0=none,1=AddROI, 2=reject cells, 3=add cells
ROI_blank=struct('id',0,'tag','na','xy',[],'cells',0,'handle',[],'tagHandle',[]);
setappdata(0,'ROI_blank',ROI_blank);
setappdata(0,'prePoint',[1,1]);          %previous buttondown point
setappdata(0,'cellMarker',[1,5]);       %marker to plot cells, [type,size]
setappdata(0,'viewFlag',[0,0]);         %whether to display cellMarker or ROI
setappdata(0,'signalCh',1);
setappdata(0,'threshold',100);


function handles=init(handles)   
setappdata(0,'FileName',[]);
setappdata(0,'FileList',[]);
initData();


function initData()
setappdata(0,'Image',[]);
setappdata(0,'ImgInfo',[]);
ROI_blank=getappdata(0,'ROI_blank');
setappdata(0,'ROI',ROI_blank);
setappdata(0,'cROIn',0);
setappdata(0,'ROIMap',[]);
setappdata(0,'cellMap',[]);     %[x,y,area];
setappdata(0,'cellMaphandle',[]);
setappdata(0,'maskImage',[]);   %labelled 2D-image per channel
setappdata(0,'allCellMaps',cell(3,1));        %for each signal channel
setappdata(0,'allMaskImages',[]);   %for each signal channel

% --- Outputs from this function are returned to the command line.
function varargout = cellcounter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_file_open.
function pushbutton_file_open_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_file_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PathName = getappdata(0,'PathName');
FileList=getappdata(0,'FileList');
if isempty(FileList)
    [FileName,PathName] = uigetfile({'*.tif';'*.jpg';'*.png';'*.mat';'*.*'},'Select an image',PathName);
    if FileName~=0
        setappdata(0,'FileName',FileName);
        setappdata(0,'PathName',PathName);
        %create a listbox of image files
        extname=['*',FileName(end-3:end)];
        pn2=fullfile(PathName,extname);
        FileList=dir(pn2);
        [figFileList,infoHandles]=createFileListFig(FileList,FileName);
        %update image-information using the first file
        fname=fullfile(PathName,FileName);
        if contains(FileName,'.mat')
            info=[];
        else
            info=imfinfo(fname);
        end
        updateFileListFigInfo(infoHandles,info);
        setappdata(0,'figFileList',figFileList);
        setappdata(0,'infoHandles',infoHandles);
        setappdata(0,'FileList',FileList);
    end
else
    FileName=getappdata(0,'FileName');
end

if contains(FileName,'.mat')
    %load data from mat-files
    fn=fullfile(PathName,FileName);
    load(fn,'Image','ImgInfo','maskImage',...
        'ROI','ROIMap','cellMap','threshold','allCellMaps','allMaskImages');
    setappdata(0,'Image',Image);
    setappdata(0,'ImgInfo',ImgInfo);
    setappdata(0,'maskImage',maskImage);
    setappdata(0,'ROI',ROI);
    setappdata(0,'ROIMap',ROIMap);
    setappdata(0,'cellMap',cellMap);
    setappdata(0,'threshold',threshold);
    setappdata(0,'allCellMaps',allCellMaps);
    setappdata(0,'allMaskImages',allMaskImages);

    set(handles.text_info_message,'String','MSG: Data loaded');
    updatePanel(ImgInfo,handles);
    CreateImageFig(Image,ImgInfo,handles);
    showImgStat(ImgInfo,handles);
else
    initInfoPanel(handles);
    initData();
    set(handles.text_info_message,'String','MSG: Loading image...');
    disp('Loading image...');
    fn=fullfile(PathName,FileName);
    [Image,ImgInfo]=loadImage(fn);
    %save data
    setappdata(0,'Image',Image);
    setappdata(0,'ImgInfo',ImgInfo);
    if ImgInfo.allChs==1
        setappdata(0,'signalCh',1);
    end
    signalCh=getappdata(0,'signalCh');
    setappdata(0,'threshold',ImgInfo.Threshold(signalCh));
    %show information: size, zoom
    updatePanel(ImgInfo,handles);
    %show figures
    CreateImageFig(Image,ImgInfo,handles);
    showImgStat(ImgInfo,handles);
    set(handles.text_info_message,'String','MSG: Image loaded');
    disp('Image loaded');
end


function [figFileList,infoHandles]=createFileListFig(FileList,file0)
screenInfo=get(0,'ScreenSize');
figFileList=uifigure('Position',[screenInfo(3)-350,100,300,400],'Name','The list of image files');
list=uilistbox(figFileList,'Position',[1,120,300,280],'ValueChangedFcn',@updateFileListBox);
fnum=length(FileList);
flist=cell(1,fnum);
for i=1:fnum
    flist{i}=FileList(i).name;
end
list.Items=flist;
list.Value=file0;
list.ItemsData=1:fnum;
label1=uilabel(figFileList,'Position',[10,90,100,15],'Text','Image Size:');
text1=uitextarea(figFileList,'Position',[120,90,170,20],'Value','na');
label2=uilabel(figFileList,'Position',[10,70,100,15],'Text','Image number:');
text2=uitextarea(figFileList,'Position',[120,70,170,20],'Value','na');
label3=uilabel(figFileList,'Position',[10,50,100,15],'Text','Color Channels:');
text3=uitextarea(figFileList,'Position',[120,50,170,20],'Value','na');
label4=uilabel(figFileList,'Position',[10,30,100,15],'Text','Image Bits:');
text4=uitextarea(figFileList,'Position',[120,30,170,20],'Value','na');
label5=uilabel(figFileList,'Position',[10,10,100,15],'Text','FileModDate:');
text5=uitextarea(figFileList,'Position',[120,10,170,20],'Value','na');
infoHandles=struct;
infoHandles.list=list;
infoHandles.size=text1;
infoHandles.imgNum=text2;
infoHandles.colors=text3;
infoHandles.bits=text4;
infoHandles.date=text5;



function updateFileListBox(src,event)
FileList=getappdata(0,'FileList');
PathName=getappdata(0,'PathName');
if ~isempty(FileList)
    infoHandles=getappdata(0,'infoHandles');
    val=src.Value;
    fname=fullfile(PathName,FileList(val).name);
    info=imfinfo(fname);
    updateFileListFigInfo(infoHandles,info);
    setappdata(0,'FileName',FileList(val).name);
end



function updateFileListFigInfo(handles,info)
if ~isempty(info)
    str=[num2str(info(1).Width),' x ',num2str(info(1).Height)];
    set(handles.size,'Value',str);
    set(handles.imgNum,'Value',num2str(length(info)));
    set(handles.colors,'Value',num2str(info(1).SamplesPerPixel));
    set(handles.bits,'Value',num2str(info(1).BitsPerSample(1)));
    set(handles.date,'Value',info(1).FileModDate);
end


function updatePanel(ImgInfo,handles)
zmStr=[num2str(round(ImgInfo.zoomRatios(1)*100)),'%'];
set(handles.edit_view_zoomratio,'String',zmStr);
set(handles.slider_view_zoomratio,'Min',ImgInfo.zoomRatios(1),...
    'Value',ImgInfo.zoomRatios(1),'Max',ImgInfo.zoomRatios(end));
set(handles.text_info_image,'String',ImgInfo.str);
threshold=getappdata(0,'threshold');
set(handles.edit_function_threshold,'String',threshold);
set(handles.edit_color_red_low,'String',ImgInfo.clim(1,1));
set(handles.edit_color_red_high,'String',ImgInfo.clim(2,1));
if ImgInfo.allChs==1
	set(handles.radiobutton_signal_red,'Enable','off');
	set(handles.radiobutton_signal_green,'Enable','off');
	set(handles.radiobutton_signal_blue,'Enable','off');
	set(handles.edit_color_green_low,'Enable','off');
	set(handles.edit_color_green_high,'Enable','off');
	set(handles.edit_color_blue_low,'Enable','off');
	set(handles.edit_color_blue_high,'Enable','off');
	set(handles.pushbutton_color_red,'Background',[.5,.5,.5],'Enable','on');
	set(handles.pushbutton_color_green,'Background',[.5,.5,.5],'Enable','off');
	set(handles.pushbutton_color_blue,'Background',[.5,.5,.5],'Enable','off');
elseif ImgInfo.allChs==2
	set(handles.radiobutton_signal_red,'Enable','on');
	set(handles.radiobutton_signal_green,'Enable','on');
	set(handles.radiobutton_signal_blue,'Enable','off');
	set(handles.edit_color_green_low,'Enable','on');
	set(handles.edit_color_green_high,'Enable','on');
	set(handles.edit_color_blue_low,'Enable','off');
	set(handles.edit_color_blue_high,'Enable','off');
	set(handles.pushbutton_color_red,'Background','r','Enable','on');
	set(handles.pushbutton_color_green,'Background','g','Enable','on');
	set(handles.pushbutton_color_blue,'Background',[.5,.5,.5],'Enable','off');
    set(handles.edit_color_green_low,'String',ImgInfo.clim(1,2));
    set(handles.edit_color_green_high,'String',ImgInfo.clim(2,2));
else
	set(handles.radiobutton_signal_red,'Enable','on');
	set(handles.radiobutton_signal_green,'Enable','on');
	set(handles.radiobutton_signal_blue,'Enable','on');
	set(handles.edit_color_green_low,'Enable','on');
	set(handles.edit_color_green_high,'Enable','on');
	set(handles.edit_color_blue_low,'Enable','on');
	set(handles.edit_color_blue_high,'Enable','on');
	set(handles.pushbutton_color_red,'Background','r','Enable','on');
	set(handles.pushbutton_color_green,'Background','g','Enable','on');
	set(handles.pushbutton_color_blue,'Background','b','Enable','on');
    set(handles.edit_color_green_low,'String',ImgInfo.clim(1,2));
    set(handles.edit_color_green_high,'String',ImgInfo.clim(2,2));
    set(handles.edit_color_blue_low,'String',ImgInfo.clim(1,3));
    set(handles.edit_color_blue_high,'String',ImgInfo.clim(2,3));
end

function initInfoPanel(handles)
set(handles.listbox_ROI,'String',[]);
set(handles.text_info_image,'String','Image Information');
set(handles.edit_info_cursor_x,'String','');
set(handles.edit_info_cursor_y,'String','');
set(handles.edit_info_cursor_colors,'String','');
set(handles.edit_info_cellnumber,'String','0');



function CreateImageFig(Image,ImgInfo,handles)
figImage=getappdata(0,'figImage');
hfig=0;
if ~isempty(figImage)
    if ishandle(figImage)
        hfig=1;
    end
end
if hfig
    set(0,'currentfigure',figImage);clf;
else
    hfg=figure();
    set(gcf,'NumberTitle','off','Resize','off');
    setappdata(0,'figImage',hfg);    
end
set(gcf,'position',[10,100,ImgInfo.dispWid,ImgInfo.dispHei]);
set(gcf,'Name',ImgInfo.Filename);
axes('position',[0,0,1,1]);
axis off;
if ImgInfo.imgNumber>1
    M=Image(:,:,1);
else
    M=Image;
end
imshow(M);
%set functions for the image window
set(gcf,'WindowButtonMotionFcn',{@figImageCursorData,handles});
set(gcf,'WindowButtonDownFcn',{@figImageButtonDown,handles});
set(gcf,'WindowKeyPressFcn',{@figImageKeyPress,handles});


function updateImgLim(xlim,ylim,clim)
figImage=getappdata(0,'figImage');
if ~ishandle(figImage)
    return;
else
    set(0,'currentfigure',figImage);
    if ~isempty(xlim)
        set(gca,'xlim',xlim);
    end
    if ~isempty(ylim)
        set(gca,'ylim',ylim);
    end
    if ~isempty(clim)
        set(gca,'clim',clim);
    end
end

%to display information when moving cursor in the image-figure
function figImageCursorData(hObject, eventdata, handles)
ImgInfo=getappdata(0,'ImgInfo');
Image=getappdata(0,'Image');
xlim=get(hObject.CurrentAxes,'xlim');
ylim=get(hObject.CurrentAxes,'ylim');
x=round(hObject.CurrentPoint(1)*(xlim(2)-xlim(1))/ImgInfo.dispWid+xlim(1));
y=round(ylim(2)-hObject.CurrentPoint(2)*(ylim(2)-ylim(1))/ImgInfo.dispHei);
x=min(max(x,1),ImgInfo.Width);
y=min(max(y,1),ImgInfo.Height);
c=Image(y,x,:);
set(handles.edit_info_cursor_x,'String',x);
set(handles.edit_info_cursor_y,'String',y);
c2=num2str(c(1));
for i=2:length(c)
    c2=[c2,', ',num2str(c(i))];
end
set(handles.edit_info_cursor_colors,'String',c2);
%disp(hObject.CurrentPoint);

%to do when press button down in the image-figure
function figImageButtonDown(hObject, eventdata, handles)
funcTag=getappdata(0,'funcTag');
ImgInfo=getappdata(0,'ImgInfo');
cellMap=getappdata(0,'cellMap');
cellMarker=getappdata(0,'cellMarker');
maskImage=getappdata(0,'maskImage');
xlim=get(hObject.CurrentAxes,'xlim');
ylim=get(hObject.CurrentAxes,'ylim');
x=floor(hObject.CurrentPoint(1)*(xlim(2)-xlim(1))/ImgInfo.dispWid+xlim(1));
y=floor(ylim(2)-hObject.CurrentPoint(2)*(ylim(2)-ylim(1))/ImgInfo.dispHei);
setappdata(0,'prePoint',[x,y]);
if funcTag==1
    %while Adding a ROI 
    ROI=getappdata(0,'ROI');
    cROIn=getappdata(0,'cROIn');
    ROI(cROIn).xy=[ROI(cROIn).xy;x,y];
    %draw the ROI
    if ishandle(ROI(cROIn).handle)
        delete(ROI(cROIn).handle)
    end
    hold on;
    h1=plot(ROI(cROIn).xy(:,1),ROI(cROIn).xy(:,2),'--w');
    ROI(cROIn).handle=h1;
    setappdata(0,'ROI',ROI);
elseif funcTag==2
    %while rejecting cells
    ptIdx=findPoint([x,y],cellMap,cellMarker(2));
    if ~isempty(ptIdx)
        pt=round(cellMap(ptIdx,1:2));
        idx=1:size(cellMap,1);
        cellMap=cellMap(idx~=ptIdx,:);
        setappdata(0,'cellMap',cellMap);
        %also update maskImage
        pts=(maskImage==maskImage(pt(2),pt(1)));
        if isempty(find(pts))
            r0=cellMarker(2);
            x1=max(1,x-r0);
            x2=min(ImgInfo.Width,x+r0);
            y1=max(1,y-r0);
            y2=min(ImgInfo.Height,y+r0);
            maskImage(y1:y2,x1:x2)=0;
        else
            %use object-based method
            maskImage(pts)=0;
        end
        setappdata(0,'maskImage',maskImage);
        %update display
        updateImage([],cellMap,[]);
        set(handles.edit_info_cellnumber,'String',size(cellMap,1));
    end
elseif funcTag==3
    %while adding cells
    cellMap(end+1,1:2)=[x,y];
    setappdata(0,'cellMap',cellMap);
    %also update maskImage
    r0=cellMarker(2);
    x1=max(1,floor(x-r0/2));
    x2=min(ImgInfo.Width,floor(x+r0/2));
    y1=max(1,floor(y-r0/2));
    y2=min(ImgInfo.Height,floor(y+r0/2));
    cnum=max(maskImage(:));
    maskImage(y1:y2,x1:x2)=1+cnum;
    setappdata(0,'maskImage',maskImage);
    %update display
    updateImage([],cellMap,[])
    set(handles.edit_info_cellnumber,'String',size(cellMap,1));
end


%Hot-keys: to do when press keys in the image-figure
function figImageKeyPress(hObject, eventdata, handles)
%disp(hObject.CurrentCharacter);
ImgInfo=getappdata(0,'ImgInfo');
k0=ImgInfo.currentZoomIndex;
updateImgFlag=0;
zoomChangeFlag=0;
viewFlag=getappdata(0,'viewFlag');
cellMarker=getappdata(0,'cellMarker');
switch hObject.CurrentCharacter
    case '+'
        k=min(k0+1,length(ImgInfo.zoomRatios));
        zoomChangeFlag=1;
    case '='
        k=min(k0+1,length(ImgInfo.zoomRatios));
        zoomChangeFlag=1;
    case '-'
        k=max(k0-1,1);
        zoomChangeFlag=1;
    case '_'
        k=max(k0-1,1);
        zoomChangeFlag=1;
    case '1'
        k=floor(length(ImgInfo.zoomRatios)/2);
        zoomChangeFlag=1;
    case '0'
        k=1;
        zoomChangeFlag=1;
    case 'c'
        updateImgFlag=1;
        viewFlag(1)=mod(viewFlag(1)+1,2);
    case 'r'
        updateImgFlag=2;
        viewFlag(2)=mod(viewFlag(2)+1,2);
    case ','
        updateImgFlag=1;
        mksize=max(cellMarker(2)-1,1);
        setappdata(0,'cellMarker',[cellMarker(1),mksize]);
        set(handles.edit_marker_size,'String',mksize);
    case '<'
        updateImgFlag=1;
        mksize=max(cellMarker(2)-1,1);
        setappdata(0,'cellMarker',[cellMarker(1),mksize]);
        set(handles.edit_marker_size,'String',mksize);
    case '.' 
        updateImgFlag=1;
        mksize=cellMarker(2)+1;
        setappdata(0,'cellMarker',[cellMarker(1),mksize]);
        set(handles.edit_marker_size,'String',mksize);
    case '>'
        updateImgFlag=1;
        mksize=cellMarker(2)+1;
        setappdata(0,'cellMarker',[cellMarker(1),mksize]);
        set(handles.edit_marker_size,'String',mksize);
    case 'm'
        updateImgFlag=3;
end
setappdata(0,'viewFlag',viewFlag);

if updateImgFlag==1
    set(handles.checkbox_info_showCellFlag,'value',viewFlag(1));
    cellMap=getappdata(0,'cellMap');
	updateImage([],cellMap,[]);
elseif updateImgFlag==2
    ROI=getappdata(0,'ROI');
	updateImage([],[],ROI);
elseif updateImgFlag==3
    M1=getappdata(0,'maskImage');
    M2=M1>0;
    updateImage(M2,[],[]);
end
if zoomChangeFlag
    ImgInfo.currentZoomIndex=k;
    setappdata(0,'ImgInfo',ImgInfo);
    zmStr=[num2str(round(ImgInfo.zoomRatios(ImgInfo.currentZoomIndex)*100)),'%'];
    set(handles.edit_view_zoomratio,'String',zmStr);
    set(handles.slider_view_zoomratio,'Value',ImgInfo.zoomRatios(ImgInfo.currentZoomIndex));
    [xlim,ylim]=getZoomLim();
    updateImgLim(xlim,ylim,[]);
end


% --- Executes on button press in pushbutton_file_previous.
function pushbutton_file_previous_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_file_previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FileList=getappdata(0,'FileList');
PathName=getappdata(0,'PathName');
infoHandles=getappdata(0,'infoHandles');
val=infoHandles.list.Value;
if val>1
    infoHandles.list.Value=val-1;
    fname=fullfile(PathName,FileList(val-1).name);
    if contains(fname,'.mat')
        info=[];
    else
        info=imfinfo(fname);
    end
    updateFileListFigInfo(infoHandles,info);
    setappdata(0,'FileName',FileList(val-1).name);
end


% --- Executes on button press in pushbutton_file_next.
function pushbutton_file_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_file_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FileList=getappdata(0,'FileList');
PathName=getappdata(0,'PathName');
infoHandles=getappdata(0,'infoHandles');
fnum=length(FileList);
val=infoHandles.list.Value;
if val<fnum
    infoHandles.list.Value=val+1;
    fname=fullfile(PathName,FileList(val+1).name);
    if contains(fname,'.mat')
        info=[];
    else
        info=imfinfo(fname);
    end
    updateFileListFigInfo(infoHandles,info);
    setappdata(0,'FileName',FileList(val+1).name);
end

% --- Executes on button press in pushbutton_file_save.
function pushbutton_file_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_file_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PathName=getappdata(0,'PathName');
FileName=getappdata(0,'FileName');
f0=strcat(FileName(1:end-4),'_data.mat');
fout=fullfile(PathName,f0);
%data to save
Image=getappdata(0,'Image');
ImgInfo=getappdata(0,'ImgInfo');
maskImage=getappdata(0,'maskImage');
ROI=getappdata(0,'ROI');
ROIMap=getappdata(0,'ROIMap');
cellMap=getappdata(0,'cellMap');
signalCh=getappdata(0,'signalCh');
threshold=getappdata(0,'threshold');
allCellMaps=getappdata(0,'allCellMaps');
allMaskImages=getappdata(0,'allMaskImages');
save(fout,'PathName','FileName','Image','ImgInfo','maskImage',...
    'ROI','ROIMap','cellMap','signalCh','threshold','allCellMaps','allMaskImages');
set(handles.text_info_message,'String','MSG: Data saved');

% --- Executes on button press in pushbutton_file_close.
function pushbutton_file_close_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_file_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%close all figures
set(handles.text_info_message,'String','MSG: Image closed');
initInfoPanel(handles);
delAllFigs();
init(handles); 

% --- Executes on button press in pushbutton_function_detect.
function pushbutton_function_detect_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_function_detect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Image=getappdata(0,'Image');
if isempty(Image)
    set(handles.text_info_message,'String','MSG: Load an Image first');
    return;
end
threshold=getappdata(0,'threshold');
signalCh=getappdata(0,'signalCh');
M1=Image(:,:,signalCh);
disp('Searching for cells...');
set(handles.text_info_message,'String','MSG: Searching for cells...');
[cellMap,maskImage]=findCell(M1,threshold);
if ~isempty(cellMap)
    viewFlag=getappdata(0,'viewFlag');
    viewFlag(1)=1;
    setappdata(0,'viewFlag',viewFlag);
    updateImage(M1,cellMap,[]);
    ImgInfo=getappdata(0,'ImgInfo');
    updateImgLim([],[],ImgInfo.clim(:,signalCh));
    set(handles.edit_info_cellnumber,'String',size(cellMap,1));
    set(handles.checkbox_info_showCellFlag,'value',1);
    setappdata(0,'cellMap',cellMap);
    setappdata(0,'maskImage',maskImage);
    fprintf('%d cells detected\r\n',size(cellMap,1));
    %save results to big-Mat
    allCellMaps=getappdata(0,'allCellMaps');
    allMaskImages=getappdata(0,'allMaskImages');
    allCellMaps{signalCh}=cellMap;
    if isempty(allMaskImages)
        allMaskImages=zeros(size(maskImage),'uint16');
    end
    allMaskImages(:,:,signalCh)=maskImage;
    setappdata(0,'allCellMaps',allCellMaps);
    setappdata(0,'allMaskImages',allMaskImages);
end
disp('done');
msgStr=['MSG:Searching done, ',num2str(size(cellMap,1)),' cells found'];
set(handles.text_info_message,'String',msgStr);



% --- Executes on button press in pushbutton_function_count.
function pushbutton_function_count_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_function_count (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cROIn=getappdata(0,'cROIn');
if cROIn>0
    ROI=getappdata(0,'ROI');
    ImgInfo=getappdata(0,'ImgInfo');
    ImgSize=[ImgInfo.Width,ImgInfo.Height];
    ROIMap=getROIMap(ROI,ImgSize);
    %cellMap=getappdata(0,'cellMap');
    allCellMaps=getappdata(0,'allCellMaps');
    chnum=length(allCellMaps);
    ROIcells=zeros(cROIn,chnum);
    for i=1:chnum
        cellMap=allCellMaps{i};
        ROIcells(:,i)=countROIcells(ROIMap,cellMap);
    end
    %update result in ROI-listbox
    listname=cell(cROIn);
    for i=1:cROIn
        numStr=[];
        for j=1:chnum
            numStr=[numStr,num2str(ROIcells(i,j)),'/',];
        end
        listname{i}=[num2str(i),' ',ROI(i).tag,'= ',numStr,' cells'];
        ROI(i).cells=ROIcells(i,:);
    end
    numStr=[];
    for j=1:chnum
        numStr=[numStr,num2str(size(allCellMaps{j},1)),'/',];
    end
    listname{cROIn+1}=['All = ',numStr,' Cells'];
    set(handles.listbox_ROI,'String',listname);
    set(handles.listbox_ROI,'value',cROIn);
    setappdata(0,'ROI',ROI);
    set(handles.text_info_message,'String','MSG: Counting done');
    disp('-------counting cells---------');
    disp(listname);
else
    %disp('Please select ROI first!');
    set(handles.text_info_message,'String','MSG: Select ROI first!');
end


% --- Executes on button press in pushbutton_function_reject.
function pushbutton_function_reject_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_function_reject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
funcTag=getappdata(0,'funcTag');
if funcTag==2
    setappdata(0,'funcTag',0);
    set(hObject,'String','Reject cells','BackgroundColor',[.9,.9,.9]);
    set(handles.text_info_message,'String','MSG: Rejecting cells done');
    %update cellMap 
    cellMap=getappdata(0,'cellMap');
    allCellMaps=getappdata(0,'allCellMaps');
    signalCh=getappdata(0,'signalCh');
    allCellMaps{signalCh}=cellMap;
    setappdata(0,'allCellMaps',allCellMaps);
    %update maskImage 
    maskImage=getappdata(0,'maskImage');
    allMaskImages=getappdata(0,'allMaskImages');
    allMaskImages(:,:,signalCh)=maskImage;
    setappdata(0,'allMaskImages',allMaskImages);
else
    setappdata(0,'funcTag',2);
    set(hObject,'String','Stop Rejecting','BackgroundColor','m');
    set(handles.text_info_message,'String','MSG: Rejecting cells...');
end

% --- Executes on button press in pushbutton_function_add.
function pushbutton_function_add_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_function_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
funcTag=getappdata(0,'funcTag');
if funcTag==3
    setappdata(0,'funcTag',0);
    set(hObject,'String','Add cells','BackgroundColor',[.9,.9,.9]);
    set(handles.text_info_message,'String','MSG: Adding cells done');
    %update cellMap 
    cellMap=getappdata(0,'cellMap');
    allCellMaps=getappdata(0,'allCellMaps');
    signalCh=getappdata(0,'signalCh');
    allCellMaps{signalCh}=cellMap;
    setappdata(0,'allCellMaps',allCellMaps);
    %update maskImage 
    maskImage=getappdata(0,'maskImage');
    allMaskImages=getappdata(0,'allMaskImages');
    allMaskImages(:,:,signalCh)=maskImage;
    setappdata(0,'allMaskImages',allMaskImages);
else
    setappdata(0,'funcTag',3);
    set(hObject,'String','Stop Adding','BackgroundColor','m');
    set(handles.text_info_message,'String','MSG: Adding cells...');
end



% --- Executes on button press in pushbutton_color_red.
function pushbutton_color_red_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_color_red (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Image=getappdata(0,'Image');
ImgInfo=getappdata(0,'ImgInfo');
M1=Image(:,:,1);
M1(:,:,2)=Image(:,:,2)*0;
M1(:,:,3)=Image(:,:,3)*0;
updateImage(M1,[],[]);
updateImgLim([],[],ImgInfo.clim(:,1));
setappdata(0,'colorCh',1);
%highlight selected color-button
set(hObject,'BackgroundColor','r');
set(handles.pushbutton_color_green,'BackgroundColor',[.5,.5,.5]);
set(handles.pushbutton_color_blue,'BackgroundColor',[.5,.5,.5]);

% --- Executes on button press in pushbutton_color_green.
function pushbutton_color_green_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_color_green (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Image=getappdata(0,'Image');
ImgInfo=getappdata(0,'ImgInfo');
M1=Image(:,:,1)*0;
M1(:,:,2)=Image(:,:,2);
M1(:,:,3)=Image(:,:,3)*0;
updateImage(M1,[],[]);
updateImgLim([],[],ImgInfo.clim(:,2));
setappdata(0,'colorCh',2);
%highlight selected color-button
set(hObject,'BackgroundColor','g');
set(handles.pushbutton_color_red,'BackgroundColor',[.5,.5,.5]);
set(handles.pushbutton_color_blue,'BackgroundColor',[.5,.5,.5]);

% --- Executes on button press in pushbutton_color_blue.
function pushbutton_color_blue_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_color_blue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Image=getappdata(0,'Image');
ImgInfo=getappdata(0,'ImgInfo');
M1=Image(:,:,1)*0;
M1(:,:,2)=Image(:,:,2)*0;
M1(:,:,3)=Image(:,:,3);
updateImage(M1,[],[]);
updateImgLim([],[],ImgInfo.clim(:,3));
setappdata(0,'colorCh',3);
%highlight selected color-button
set(hObject,'BackgroundColor','b');
set(handles.pushbutton_color_red,'BackgroundColor',[.5,.5,.5]);
set(handles.pushbutton_color_green,'BackgroundColor',[.5,.5,.5]);

% --- Executes on button press in pushbutton_color_reset.
function pushbutton_color_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_color_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colorCh=getappdata(0,'colorCh');
ImgInfo=getappdata(0,'ImgInfo');
if colorCh==0
    ImgInfo.clim=[ImgInfo.MinSampleValue; ImgInfo.MaxSampleValue];
    set(handles.edit_color_red_low,'String',ImgInfo.clim(1,1));
    set(handles.edit_color_red_high,'String',ImgInfo.clim(2,1));
    set(handles.edit_color_green_low,'String',ImgInfo.clim(1,2));
    set(handles.edit_color_green_high,'String',ImgInfo.clim(2,2));
    set(handles.edit_color_blue_low,'String',ImgInfo.clim(1,3));
    set(handles.edit_color_blue_high,'String',ImgInfo.clim(2,3));
else
    ImgInfo.clim(:,colorCh)=[ImgInfo.MinSampleValue(1),ImgInfo.MaxSampleValue(1)];
    if colorCh==1
        set(handles.edit_color_red_low,'String',ImgInfo.clim(1,1));
        set(handles.edit_color_red_high,'String',ImgInfo.clim(2,1));
    elseif colorCh==2
        set(handles.edit_color_green_low,'String',ImgInfo.clim(1,2));
        set(handles.edit_color_green_high,'String',ImgInfo.clim(2,2));
    elseif colorCh==3
        set(handles.edit_color_blue_low,'String',ImgInfo.clim(1,3));
        set(handles.edit_color_blue_high,'String',ImgInfo.clim(2,3));
    end
    updateImgLim([],[],ImgInfo.clim(:,colorCh));
end
showImgStat(ImgInfo,handles)
setappdata(0,'ImgInfo',ImgInfo);

% --- Executes on button press in pushbutton_color_all.
function pushbutton_color_all_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_color_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Image=getappdata(0,'Image');
updateImage(Image,[],[])
setappdata(0,'colorCh',0);
set(handles.pushbutton_color_red,'BackgroundColor','r');
set(handles.pushbutton_color_green,'BackgroundColor','g');
set(handles.pushbutton_color_blue,'BackgroundColor','b');

% --- Executes on selection change in listbox_ROI.
function listbox_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_ROI contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_ROI


% --- Executes during object creation, after setting all properties.
function listbox_ROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_ROI_add.
function pushbutton_ROI_add_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ROI_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
viewFlag=getappdata(0,'viewFlag');
viewFlag(2)=1;
setappdata(0,'viewFlag',viewFlag);
tagname=get(hObject,'String');
cROIn=getappdata(0,'cROIn');
ROI=getappdata(0,'ROI');
if strcmpi(tagname,'add')
    set(hObject,'String','End');
    setappdata(0,'funcTag',1);
    setappdata(0,'cROIn',cROIn+1);
    ROI_blank=getappdata(0,'ROI_blank');
    ROI(cROIn+1)=ROI_blank;
    setappdata(0,'ROI',ROI);
    set(handles.text_info_message,'String','MSG: Adding ROI...');
    figImage=getappdata(0,'figImage');
    set(0,'currentfigure',figImage);
elseif strcmpi(tagname,'end')
    set(hObject,'String','Add');
    setappdata(0,'funcTag',0);
    ROI(cROIn).id=cROIn;
    ROI(cROIn).tag=get(handles.edit_ROI_tag,'String');
    %add the first point to the end, to form a loop
    ROI(cROIn).xy(end+1,:)=ROI(cROIn).xy(1,:);
    setappdata(0,'ROI',ROI);
    updateImage([],[],ROI);
    %add to listbox
    listname=cell(cROIn);
    for i=1:cROIn
        listname{i}=[num2str(i),' ',ROI(i).tag];
    end
    set(handles.listbox_ROI,'String',listname);
    set(handles.listbox_ROI,'value',cROIn);
    set(handles.text_info_message,'String','MSG: ROI added');
end


% --- Executes on button press in pushbutton_ROI_remove.
function pushbutton_ROI_remove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ROI_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.listbox_ROI,'value');
if isempty(val)
    set(handles.text_info_message,'String','MSG: no ROI to remove');
    return;
end
if val<=0
    set(handles.text_info_message,'String','MSG: no ROI to remove');
    return;
end
cROIn=getappdata(0,'cROIn');
ROI=getappdata(0,'ROI');
kk=1:length(ROI);
idx=(kk~=val);
ROI2=ROI(idx);
delete(ROI(val).handle);
delete(ROI(val).tagHandle);
setappdata(0,'ROI',ROI2);
setappdata(0,'cROIn',cROIn-1);
listname=cell(cROIn-1);
for i=1:cROIn-1
    listname{i}=[num2str(i),' ',ROI2(i).tag];
end
set(handles.listbox_ROI,'String',listname);
set(handles.listbox_ROI,'Value',cROIn-1);
set(handles.text_info_message,'String','MSG: ROI removed');


function edit_ROI_tag_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ROI_tag as text
%        str2double(get(hObject,'String')) returns contents of edit_ROI_tag as a double


% --- Executes during object creation, after setting all properties.
function edit_ROI_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton_ROI_hide.
function pushbutton_ROI_hide_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ROI_hide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tagname=get(hObject,'String');
cROIn=getappdata(0,'cROIn');
ROI=getappdata(0,'ROI');
viewFlag=getappdata(0,'viewFlag');
if strcmpi(tagname,'Hide')
    set(hObject,'String','Show');
    for i=1:cROIn
        if ishandle(ROI(i).handle)
            delete(ROI(i).handle);
            delete(ROI(i).tagHandle);
        end
    end
    viewFlag(2)=0;
elseif strcmpi(tagname,'Show')
    set(hObject,'String','Hide');
    viewFlag(2)=1;
end
setappdata(0,'viewFlag',viewFlag);
updateImage([],[],ROI);


% --- Executes on button press in pushbutton_view_zoomin.
function pushbutton_view_zoomin_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view_zoomin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImgInfo=getappdata(0,'ImgInfo');
if ImgInfo.currentZoomIndex<length(ImgInfo.zoomRatios)
    ImgInfo.currentZoomIndex=ImgInfo.currentZoomIndex+1;
    setappdata(0,'ImgInfo',ImgInfo);
    zmStr=[num2str(round(ImgInfo.zoomRatios(ImgInfo.currentZoomIndex)*100)),'%'];
    set(handles.edit_view_zoomratio,'String',zmStr);
    set(handles.slider_view_zoomratio,'Value',ImgInfo.zoomRatios(ImgInfo.currentZoomIndex));
    [xlim,ylim]=getZoomLim();
    updateImgLim(xlim,ylim,[]);
end

% --- Executes on button press in pushbutton_view_zoomout.
function pushbutton_view_zoomout_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view_zoomout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImgInfo=getappdata(0,'ImgInfo');
if ImgInfo.currentZoomIndex>1
    ImgInfo.currentZoomIndex=ImgInfo.currentZoomIndex-1;
    setappdata(0,'ImgInfo',ImgInfo);
    zmStr=[num2str(round(ImgInfo.zoomRatios(ImgInfo.currentZoomIndex)*100)),'%'];
    set(handles.edit_view_zoomratio,'String',zmStr);
    set(handles.slider_view_zoomratio,'Value',ImgInfo.zoomRatios(ImgInfo.currentZoomIndex));
    [xlim,ylim]=getZoomLim();
    updateImgLim(xlim,ylim,[]);
end

% --- Executes on button press in pushbutton_view_zoomfull.
function pushbutton_view_zoomfull_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view_zoomfull (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImgInfo=getappdata(0,'ImgInfo');
ImgInfo.currentZoomIndex=1;
setappdata(0,'ImgInfo',ImgInfo);
zmStr=[num2str(round(ImgInfo.zoomRatios(ImgInfo.currentZoomIndex)*100)),'%'];
set(handles.edit_view_zoomratio,'String',zmStr);
set(handles.slider_view_zoomratio,'Value',ImgInfo.zoomRatios(ImgInfo.currentZoomIndex));
[xlim,ylim]=getZoomLim();
updateImgLim(xlim,ylim,[]);


% --- Executes on button press in pushbutton_view_zoom11.
function pushbutton_view_zoom11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view_zoom11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImgInfo=getappdata(0,'ImgInfo');
ImgInfo.currentZoomIndex=floor(length(ImgInfo.zoomRatios)/2);
setappdata(0,'ImgInfo',ImgInfo);
set(handles.edit_view_zoomratio,'String','100%');
set(handles.slider_view_zoomratio,'Value',ImgInfo.zoomRatios(ImgInfo.currentZoomIndex));
[xlim,ylim]=getZoomLim();
updateImgLim(xlim,ylim,[]);


function [xlim,ylim]=getZoomLim()
prePoint=getappdata(0,'prePoint');
ImgInfo=getappdata(0,'ImgInfo');
k=ImgInfo.currentZoomIndex;
if k==1
	% full image
	xlim=[0.5,ImgInfo.Width+0.5];
	ylim=[0.5,ImgInfo.Height+0.5];
else
    wid=ImgInfo.dispWid/ImgInfo.zoomRatios(k);
    hei=ImgInfo.dispHei/ImgInfo.zoomRatios(k);
    xlim=[prePoint(1)-wid/2,prePoint(1)+wid/2];
    ylim=[prePoint(2)-hei/2,prePoint(2)+hei/2];
end



% --- Executes on button press in pushbutton_view_maskImage.
function pushbutton_view_maskImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view_maskImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
M1=getappdata(0,'maskImage');
if ~isempty(M1)
    M2=M1>0;
    updateImage(M2,[],[]);
end


function edit_info_cursor_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_info_cursor_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_info_cursor_x as text
%        str2double(get(hObject,'String')) returns contents of edit_info_cursor_x as a double


% --- Executes during object creation, after setting all properties.
function edit_info_cursor_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_info_cursor_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_info_cursor_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_info_cursor_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_info_cursor_y as text
%        str2double(get(hObject,'String')) returns contents of edit_info_cursor_y as a double


% --- Executes during object creation, after setting all properties.
function edit_info_cursor_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_info_cursor_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_info_cursor_colors_Callback(hObject, eventdata, handles)
% hObject    handle to edit_info_cursor_colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_info_cursor_colors as text
%        str2double(get(hObject,'String')) returns contents of edit_info_cursor_colors as a double


% --- Executes during object creation, after setting all properties.
function edit_info_cursor_colors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_info_cursor_colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_function_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_function_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_function_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_function_threshold as a double
val=str2double(get(hObject,'String'));
setappdata(0,'threshold',val);
updateThreshold(val,handles);


function updateThreshold(th,handles)
ImgInfo=getappdata(0,'ImgInfo');
showImgStat(ImgInfo,handles)
signalCh=getappdata(0,'signalCh');
ImgInfo.Threshold(signalCh)=th;
setappdata(0,'ImgInfo',ImgInfo);
%update image
viewFlag=getappdata(0,'viewFlag');
if viewFlag(1)+viewFlag(2)==0
    Image=getappdata(0,'Image');
    M1=Image(:,:,signalCh);
    M2=M1>th;
    figImage=getappdata(0,'figImage');
    if ishandle(figImage)
        set(0,'currentfigure',figImage);
        imshow(M2);
    end
end
set(handles.text_info_message,'String','MSG: threshold updated...');

% --- Executes during object creation, after setting all properties.
function edit_function_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_function_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton_threshold_auto.
function pushbutton_threshold_auto_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_threshold_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%another method to generate threshold: using edge-intensity
Image=getappdata(0,'Image');
ImgInfo=getappdata(0,'ImgInfo');
disp('calculating threshold...');
for i=1:ImgInfo.allChs
    M1=Image(:,:,i);
    M0a=M1>=ImgInfo.clim(1,i);
    M0b=M1<=ImgInfo.clim(2,i);
    M2=double(M1).*M0a.*M0b;
    I1=edge(M1);
    I1=bwareaopen(I1,3);
    th2=round(mean2(M2(I1))+0.5*std2(M2(I1)));
    if ~isnan(th2)
        ImgInfo.Threshold(i)=th2;
    end
end
setappdata(0,'ImgInfo',ImgInfo);
signalCh=getappdata(0,'signalCh');
threshold=ImgInfo.Threshold(signalCh);
setappdata(0,'threshold',threshold);
set(handles.edit_function_threshold,'String',threshold);
updateThreshold(threshold,handles);
disp('done');


% --- Executes when selected object is changed in uibuttongroup_signal.
function uibuttongroup_signal_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup_signal 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Image=getappdata(0,'Image');
allCellMaps=getappdata(0,'allCellMaps');
allMaskImages=getappdata(0,'allMaskImages');
switch get(eventdata.NewValue,'Tag')
    case 'radiobutton_signal_red'
        signalCh=1;
        M1=Image(:,:,1);
    case 'radiobutton_signal_green'
        signalCh=2;
        M1=Image(:,:,2);
    case 'radiobutton_signal_blue'
        signalCh=3;
        M1=Image(:,:,3);
    case 'radiobutton_signal_redgreen'
        signalCh=4;
        M1=Image;
        M1(:,:,3)=Image(:,:,3)*0;
        %detect merged cells
        [cellMap,maskImage]=findMerge(allCellMaps,allMaskImages);
        allCellMaps{4}=cellMap;
        if isempty(maskImage)
            allMaskImages(:,:,4)=zeros(size(allMaskImages(:,:,1)),'uint16');
        else
            allMaskImages(:,:,4)=maskImage;
        end
        setappdata(0,'allCellMaps',allCellMaps);
        setappdata(0,'allMaskImages',allMaskImages);
        setappdata(0,'cellMap',cellMap);
        setappdata(0,'maskImage',maskImage);
end

if ~isempty(allCellMaps{signalCh})
    cellMap=allCellMaps{signalCh};
    maskImage=allMaskImages(:,:,signalCh);
    setappdata(0,'cellMap',cellMap);
    setappdata(0,'maskImage',maskImage);
else
    cellMap=[];
end
updateImage(M1,cellMap,[]);
set(handles.edit_info_cellnumber,'String',size(allCellMaps{signalCh},1));
setappdata(0,'signalCh',signalCh);
if signalCh<=3
    ImgInfo=getappdata(0,'ImgInfo');
    threshold=ImgInfo.Threshold(signalCh);
    setappdata(0,'threshold',threshold);
    set(handles.edit_function_threshold,'String',threshold);
    showImgStat(ImgInfo,handles)
end


function edit_info_cellnumber_Callback(hObject, eventdata, handles)
% hObject    handle to edit_info_cellnumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_info_cellnumber as text
%        str2double(get(hObject,'String')) returns contents of edit_info_cellnumber as a double


% --- Executes during object creation, after setting all properties.
function edit_info_cellnumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_info_cellnumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_info_showCellFlag.
function checkbox_info_showCellFlag_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_info_showCellFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_info_showCellFlag
cellMap=getappdata(0,'cellMap');
viewFlag=getappdata(0,'viewFlag');
if get(hObject,'Value')
    viewFlag(1)=1;
else
    viewFlag(1)=0;
end
setappdata(0,'viewFlag',viewFlag);
updateImage([],cellMap,[]);



function edit_color_red_low_Callback(hObject, eventdata, handles)
% hObject    handle to edit_color_red_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_color_red_low as text
%        str2double(get(hObject,'String')) returns contents of edit_color_red_low as a double
ImgInfo=getappdata(0,'ImgInfo');
r1=str2double(get(hObject,'String'));
ImgInfo.clim(1,1)=r1;
setappdata(0,'ImgInfo',ImgInfo);
updateImgLim([],[],ImgInfo.clim(:,1));
showImgStat(ImgInfo,handles)
if ImgInfo.allChs==1
    set(handles.edit_color_green_low,'String',r1);
    set(handles.edit_color_blue_low,'String',r1);
end

% --- Executes during object creation, after setting all properties.
function edit_color_red_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_color_red_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_color_red_high_Callback(hObject, eventdata, handles)
% hObject    handle to edit_color_red_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_color_red_high as text
%        str2double(get(hObject,'String')) returns contents of edit_color_red_high as a double
ImgInfo=getappdata(0,'ImgInfo');
r2=str2double(get(hObject,'String'));
ImgInfo.clim(2,1)=r2;
setappdata(0,'ImgInfo',ImgInfo);
updateImgLim([],[],ImgInfo.clim(:,1));
showImgStat(ImgInfo,handles)
if ImgInfo.allChs==1
    set(handles.edit_color_green_high,'String',r2);
    set(handles.edit_color_blue_high,'String',r2);
end

% --- Executes during object creation, after setting all properties.
function edit_color_red_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_color_red_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_color_green_low_Callback(hObject, eventdata, handles)
% hObject    handle to edit_color_green_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_color_green_low as text
%        str2double(get(hObject,'String')) returns contents of edit_color_green_low as a double
ImgInfo=getappdata(0,'ImgInfo');
g1=str2double(get(hObject,'String'));
ImgInfo.clim(1,2)=g1;
setappdata(0,'ImgInfo',ImgInfo);
updateImgLim([],[],ImgInfo.clim(:,2));
showImgStat(ImgInfo,handles)

% --- Executes during object creation, after setting all properties.
function edit_color_green_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_color_green_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_color_green_high_Callback(hObject, eventdata, handles)
% hObject    handle to edit_color_green_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_color_green_high as text
%        str2double(get(hObject,'String')) returns contents of edit_color_green_high as a double
ImgInfo=getappdata(0,'ImgInfo');
g2=str2double(get(hObject,'String'));
ImgInfo.clim(2,2)=g2;
setappdata(0,'ImgInfo',ImgInfo);
updateImgLim([],[],ImgInfo.clim(:,2));
showImgStat(ImgInfo,handles)

% --- Executes during object creation, after setting all properties.
function edit_color_green_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_color_green_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_color_blue_low_Callback(hObject, eventdata, handles)
% hObject    handle to edit_color_blue_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_color_blue_low as text
%        str2double(get(hObject,'String')) returns contents of edit_color_blue_low as a double
ImgInfo=getappdata(0,'ImgInfo');
b1=str2double(get(hObject,'String'));
ImgInfo.clim(1,3)=b1;
setappdata(0,'ImgInfo',ImgInfo);
updateImgLim([],[],ImgInfo.clim(:,3));
showImgStat(ImgInfo,handles)

% --- Executes during object creation, after setting all properties.
function edit_color_blue_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_color_blue_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_color_blue_high_Callback(hObject, eventdata, handles)
% hObject    handle to edit_color_blue_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_color_blue_high as text
%        str2double(get(hObject,'String')) returns contents of edit_color_blue_high as a double
ImgInfo=getappdata(0,'ImgInfo');
b2=str2double(get(hObject,'String'));
ImgInfo.clim(2,3)=b2;
setappdata(0,'ImgInfo',ImgInfo);
updateImgLim([],[],ImgInfo.clim(:,3));
showImgStat(ImgInfo,handles)


% --- Executes during object creation, after setting all properties.
function edit_color_blue_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_color_blue_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_marker_size_Callback(hObject, eventdata, handles)
% hObject    handle to edit_marker_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_marker_size as text
%        str2double(get(hObject,'String')) returns contents of edit_marker_size as a double
cellMarker=getappdata(0,'cellMarker');
setappdata(0,'cellMarker',[cellMarker(1),str2double(get(hObject,'String'))]);
%update image
cellMap=getappdata(0,'cellMap');
updateImage([],cellMap,[]);


% --- Executes during object creation, after setting all properties.
function edit_marker_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_marker_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uibuttongroup_marker.
function uibuttongroup_marker_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup_marker 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag')
    case 'radiobutton_marker_circle'
        markerType=1;
    case 'radiobutton_marker_dot'
        markerType=2;
end
cellMarker=getappdata(0,'cellMarker');
setappdata(0,'cellMarker',[markerType,cellMarker(2)]);
%update image
cellMap=getappdata(0,'cellMap');
if ~isempty(cellMap)
    updateImage([],cellMap,[]);
end



function edit_view_zoomratio_Callback(hObject, eventdata, handles)
% hObject    handle to edit_view_zoomratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_view_zoomratio as text
%        str2double(get(hObject,'String')) returns contents of edit_view_zoomratio as a double


% --- Executes during object creation, after setting all properties.
function edit_view_zoomratio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_view_zoomratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_view_zoomratio_Callback(hObject, eventdata, handles)
% hObject    handle to slider_view_zoomratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_view_zoomratio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_view_zoomratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_color_auto.
function pushbutton_color_auto_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_color_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImgInfo=getappdata(0,'ImgInfo');
colorCh=getappdata(0,'colorCh');
if colorCh>0
    auto=ImgInfo.autoScale(:,colorCh);
    if colorCh==1
        set(handles.edit_color_red_low,'String',auto(1));
        set(handles.edit_color_red_high,'String',auto(2));
    elseif colorCh==2
        set(handles.edit_color_green_low,'String',auto(1));
        set(handles.edit_color_green_high,'String',auto(2));
    elseif colorCh==3
        set(handles.edit_color_blue_low,'String',auto(1));
        set(handles.edit_color_blue_high,'String',auto(2));
    end
    ImgInfo.clim(:,colorCh)=ImgInfo.autoScale(:,colorCh);
    updateImgLim([],[],ImgInfo.clim(:,colorCh));
    showImgStat(ImgInfo,handles)
    setappdata(0,'ImgInfo',ImgInfo);
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delAllFigs();

function delAllFigs()
figImage=getappdata(0,'figImage');
if ishandle(figImage)
    delete(figImage);
    setappdata(0,'figImage',[]);
end
figImgStat=getappdata(0,'figImgStat');
if ishandle(figImgStat)
    delete(figImgStat);
    setappdata(0,'figImgStat',[]);
end
figFileList=getappdata(0,'figFileList');
if ishandle(figFileList)
    delete(figFileList);
    setappdata(0,'figFileList',[]);
end
