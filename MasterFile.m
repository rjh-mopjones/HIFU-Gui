%% tabGUI
function MasterFile
f = figure;
%% Figure Properties 
f.Position = [500 200 1000 700];
f.MenuBar = 'none';
f.ToolBar = 'none';
f.Visible = 'off';
f.Color = 'w';
f.Name = 'Pressure Visualiser';
f.NumberTitle = 'off';
%% Default Properties
xaxis = 'x axis (m)';                              
yaxis = 'y axis (m)';
zaxis = 'z axis (m)';

[array,constants] = importDefault();
spacedLimits = struct('Xmin',-2.5e-2,'Xmax', 2.5e-2, 'XStep', 50,...
    'Ymin', -5e-2,'Ymax', 5e-2, 'YStep',50, 'Zmin', -2.5e-2, 'Zmax',2.5e-2,'ZStep',  50); 
inputData = struct('Xmat',linspace(-2.5e-2,2.5e-2,50)' ,'Ymat',linspace(-5e-2,5e-2,50)' ...
       , 'Zmat' ,linspace(-2.5e-2,2.5e-2,50)', 'plane' , 'xy','res',25);
importedData = struct('fileName', '');
i=-37.5;
importedData.fileName = 'FourRibs_2p5mm_f60kHz_v1.dat';
outputData = struct();
pr0_data = struct();
%% main tab group initialisation
tgroup = uitabgroup('Parent', f);
homeTab = uitab('Parent', tgroup, 'Title', 'Home','BackgroundColor', 'w');


tgroup.SelectedTab = homeTab;
 
tgroup.TabLocation = 'top';
%% Home Tab UI controls
%figure title
figureTitle = uicontrol('Style', 'text','String' ,....
    'Pressure Field Visualiser','Units', ...
    'normalized' ,'Position', [.003,.89,.45,.05],...
    'BackgroundColor' ,'White', 'FontSize', 20,'FontWeight','bold', 'Parent', f,'Units', ...
    'normalized');

%statusTicker
statusTicker = uicontrol('Units', 'normalized','Style', 'text','String' ,....
    'Ready to Recieve Input.' ,'Position', [.453,.9,.5,.035],...
    'BackgroundColor' ,'w', 'FontSize', 10, 'Parent', f,'HorizontalAlignment', 'right','ForegroundColor','b');            

menubarButton=uicontrol('Units','normalized','Parent', f,'Style', 'pushbutton','String', 'M' ,...
                'Position', [.02,.926,.03,.03], 'Callback' , @menuBar_callback,'Visible','on','ForegroundColor', 'k');

% side tabs

sideTabs = uitabgroup(homeTab,'Position', [0,.0,1,.9], 'TabLocation', 'left');
introST = uitab(sideTabs,'Title', 'Introduction','BackgroundColor','w');
recBodyST = uitab(sideTabs,'Title', 'Receiving Body','BackgroundColor','w');
constantsST = uitab(sideTabs,'Title', 'Physical Constants','BackgroundColor','w');
arraysetsST = uitab(sideTabs,'Title', 'Array Settings','BackgroundColor','w');
rayTraceST = uitab(sideTabs,'Title', 'Geometric Ray Tracing','BackgroundColor','w');
phaseST = uitab(sideTabs,'Title', 'Phase Conjugation','BackgroundColor','w');
runSt = uitab(sideTabs,'Title', 'RUN','BackgroundColor','w','ForegroundColor',[0 .5 0]);
plotTab = uitab('Parent', sideTabs, 'Title', 'Visualisation','BackgroundColor', 'w', 'ForegroundColor','r');
dataTab = uitab('Parent', sideTabs, 'Title', 'Data','BackgroundColor', 'w','ForegroundColor','r');
%defaults
resetDefaultsButton = uicontrol('Units','normalized','Parent', homeTab,'Style', 'pushbutton','String', 'Restore Defaults' ,...
                'Position', [.011,.027,.117,.11], 'Callback' , @globalDefaults_callback,'Visible','on','BackgroundColor', 'k','ForegroundColor', 'w');
%% Plot Tab UI controls

%contextMenu
contextMenu = uicontextmenu;

m1 = uimenu(contextMenu,'Label','Reset View','Callback',@toggleResetView_callback);
m2 = uimenu(contextMenu,'Label','Auto Rotate','Callback',@autoRotateDialog_callback,'Checked','off');
m3 = uimenu(contextMenu,'Label','Show Array','Callback',@toggleArray_callback,'Checked','off');
m4 = uimenu(contextMenu,'Label','Show Focal Point','Callback',@toggleFocalPoint,'Checked','off');
m5 = uimenu(contextMenu,'Label','Show Ray Lines','Callback',@togglRayLines,'Checked','off');
m6 = uimenu(contextMenu,'Label','Show Intersections','Callback',@toggleIntersectionsCallback,'Checked','off');


topmenu = uimenu('Parent',contextMenu,'Label','Show Pressure Field');
    
    % Create submenu items
    m8 = uimenu('Parent',topmenu,'Label','XY Plane','Callback',@changeField);
    m9 = uimenu('Parent',topmenu,'Label','YZ Plane','Callback',@changeField);
    m10= uimenu('Parent',topmenu,'Label','ZX Plane','Callback',@changeField);
    
  m11 = uimenu(contextMenu,'Label','Flip View','Callback',@flipView_callback,'Checked','off');  
%xPortFigure button
xPortFigureButton = uicontrol('Units','normalized','Parent', plotTab,'Style', 'pushbutton','String', 'Export Figure' ,...
                'Position', [.8,.02,.18,.05], 'Callback' , @xPortFigure_callback,'Visible','off','BackgroundColor', 'k','ForegroundColor', 'w');
            
%XYplaneSelector button
XYplaneSelectorButton = uicontrol('Units','normalized','Parent', plotTab,'Style', 'pushbutton','String', 'XY Plane' ,...
                'Position', [.25,.13,.15,.035], 'Callback' , @XYplaneSelector_callback,'Visible', 'off');

%YZplaneSelector button
YZplaneSelectorButton = uicontrol('Units','normalized','Parent', plotTab,'Style', 'pushbutton','String', 'YZ Plane' ,...
                'Position', [.43,.13,.15,.035], 'Callback' , @YZplaneSelector_callback,'Visible', 'off');

%ZXplaneSelector button
ZXplaneSelectorButton = uicontrol('Units','normalized','Parent', plotTab,'Style', 'pushbutton','String', 'ZX Plane' ,...
                'Position', [.61,.13,.15,.035], 'Callback' , @ZXplaneSelector_callback,'Visible', 'off');                       
%% Data Tab UI Controls
%xPortData button
xPortDataButton = uicontrol('Units','normalized','Parent', dataTab,'Style', 'pushbutton','String', 'Export Data' ,...
    'Position', [.8,.02,.18,.05], 'Callback' , @xPortData_callback,'Visible','off','BackgroundColor', 'k','ForegroundColor', 'w');

labelData = uicontrol('Units','normalized','Parent',dataTab,'Style', 'text' ,'String','' , 'FontSize' ,9 ,'Position',[.03,.4,.262,.56],'HorizontalAlignment','left','BackgroundColor','w');
numData = uicontrol('Units','normalized','Parent',dataTab,'Style', 'text' ,'String','', 'FontSize' ,9 ,'Position',[.213,.4,.262,.56],'HorizontalAlignment','right','BackgroundColor','w');
dataTabs = uitabgroup('Parent', dataTab, 'Position', [.5 .18 .49 .8], 'Visible','off');
pressureDataTab = uitab('Parent', dataTabs, 'Title', 'Mesh Pressure Data','BackgroundColor','w');
activeElementDataTab = uitab('Parent', dataTabs, 'Title', 'Active Element Data','BackgroundColor','w');
intersectionDataTab = uitab('Parent', dataTabs, 'Title', 'Intersection Data','BackgroundColor','w');
gNotPerformed = uicontrol('Style','text','Parent',intersectionDataTab, 'Units', 'normalized','String','Geometric Ray Tracing Has Not Been Performed',...
                                                                        'Visible','off','Position',[.25 .5 .5 .5],'BackgroundColor', 'w');
%% Axes

xyAxes = axes('Units','normalized','Position', [100,50,250,250]);
yzAxes = axes('Units','normalized','Position', [200,50,250,250]);
zxAxes = axes('Units','normalized','Position', [700,50,250,250]);

xyAxes.Visible = 'Off';
yzAxes.Visible = 'Off';
zxAxes.Visible = 'Off';
% Main axes
ha = axes('Units','normalized','Position', [0.248,0.173,0.484,0.743]);
h = rotate3d;
h.UIContextMenu = contextMenu;
h.Enable = 'on';
ha.Visible = 'Off';
HA.colorbar = colorbar;
HA.colorbar.Location = 'manual';
HA.colorbar.Position = [0.893 0.203 0.031 0.743];
HA.colorbar.Label.String = 'Pressure (Pa)';
HA.colorbar.Label.FontSize = 14;
HA.colorbar.Visible = 'Off';
HA.Patch.Visible = 'Off';
ha.Parent = plotTab;
ha.UIContextMenu = contextMenu;

XY.axes = axes('Units','normalized','Position', [0.25,0.25,0.6,0.6]);
XY.Title = title('Incident Pressure Field in the XY plane');
XY.xlabel= xlabel(xaxis);
XY.ylabel= ylabel(yaxis);
XY.zlabel= zlabel(zaxis);
XY.colorbar = colorbar;
XY.colorbar.Label.String = 'Pressure (Pa)';
XY.colorbar.Label.FontSize = 14;
XY.axes.Parent = plotTab;

XY.axes.Visible = 'Off';
XY.colorbar.Visible = 'Off';

YZ.axes = axes('Units','normalized','Position', [0.25,0.25,0.6,0.6]);
YZ.Title = title('Incident Pressure Field in the YZ plane');
YZ.xlabel= xlabel(xaxis);
YZ.ylabel= ylabel(yaxis);
YZ.zlabel= zlabel(zaxis);
YZ.colorbar = colorbar;
YZ.colorbar.Label.String = 'Pressure (Pa)';
YZ.colorbar.Label.FontSize = 14;
YZ.axes.Parent = plotTab;

YZ.axes.Visible = 'Off';
YZ.colorbar.Visible = 'Off';

ZX.axes = axes('Units','normalized','Position', [0.25,0.25,0.6,0.6]);
ZX.Title = title('Incident Pressure Field in the ZX plane');
ZX.xlabel= xlabel(xaxis);
ZX.ylabel= ylabel(yaxis);
ZX.zlabel= zlabel(zaxis);
ZX.colorbar = colorbar;
ZX.colorbar.Label.String = 'Pressure (Pa)';
ZX.colorbar.Label.FontSize = 14;
ZX.axes.Parent = plotTab;

ZX.axes.Visible = 'Off';
ZX.colorbar.Visible = 'Off';






movegui(f,'center');
f.Visible = 'on';
%% Home Tab Callbacks
 function resetDefaults_callback(source,eventdata)
     [array,constants] = importDefault();
     spacedLimits = struct('Xmin',-2.5e-2,'Xmax', 2.5e-2, 'XStep', 50,...
         'Ymin', -5e-2,'Ymax', 5e-2, 'YStep',50, 'Zmin', -2.5e-2, 'Zmax',2.5e-2,'ZStep',  50);
     inputData = struct('Xmat',linspace(-2.5e-2,2.5e-2,50)' ,'Ymat',linspace(-5e-2,5e-2,50)' ...
         , 'Zmat' ,linspace(-2.5e-2,2.5e-2,50)', 'plane' , 'xy','res',25);
     importedData = struct('fileName', '');
     i=-37.5;
     importedData.fileName = 'FourRibs_2p5mm_f60kHz_v1.dat';
     outputData = struct();
     cla(XY.axes)
     cla(YZ.axes)
     cla(ZX.axes)
     XY.axes.Visible = 'Off';
     XY.colorbar.Visible = 'Off';
     YZ.axes.Visible = 'Off';
     YZ.colorbar.Visible = 'Off';
     ZX.axes.Visible = 'Off';
     ZX.colorbar.Visible = 'Off';
     cla(xyAxes)
     cla(yzAxes)
     cla(zxAxes)
     cla(ha)
     ha.Visible = 'Off';
     HA.colorbar.Visible = 'Off';
     xyAxes.Visible = 'Off';
     yzAxes.Visible = 'Off';
     zxAxes.Visible = 'Off';
     HA.Patch.Visible = 'Off';
     dataTabs.Visible = 'Off';
     numData.Visible = 'Off';
     labelData.Visible = 'Off';
     XY.Patch.Visible = 'Off';
     XY.axes.Visible = 'Off';
     XY.colorbar.Visible = 'Off';
     YZ.Patch.Visible = 'Off';
     YZ.axes.Visible = 'Off';
     YZ.colorbar.Visible = 'Off';
     ZX.Patch.Visible = 'Off';
     ZX.axes.Visible = 'Off';
     ZX.colorbar.Visible = 'Off';
     XYplaneSelectorButton.Visible = 'Off';
     YZplaneSelectorButton.Visible = 'Off';
     ZXplaneSelectorButton.Visible ='Off';
     toggleAutoRotationButton.Visible ='Off';
     resetViewButton.Visible = 'Off';
     showArrayButton.Visible = 'Off';
     showFocalPointButton.Visible = 'Off';
     xPortDataButton.Visible = 'Off';
     xPortFigureButton.Visible = 'Off';
     toggleRayLinesButton.Visible = 'Off';
     toggleRayIntersections.Visible = 'Off';
     
        statusTicker.String = 'Defaults Restored. ';
                statusTicker.ForegroundColor = 'b';
 end
    function menuBar_callback(source,eventdata)
        if strcmp(f.MenuBar,'none') ==1
            f.MenuBar = 'figure';
            f.ToolBar = 'figure';
        else
            f.MenuBar = 'none';
            f.ToolBar = 'none';
        end
    end
%% Plot Tab Callbacks
function autoRotateDialog_callback(hObject,eventdata,handles)
    if strcmp(get(hObject,'Checked'),'on') == 0
        m2.Checked = 'on';
    else
        m2.Checked = 'off';

    end

            axes(ha)
            axis vis3d
            while strcmp(m2.Checked,'on') == 1
                drawnow

                view([i,30])
                i = i+0.25;
                pause(0.00001);
           
            
            end
            
end
function toggleResetView_callback(source,eventdata)
        axes(ha)
        view(3)
        i = -37.5;
        pr0_data.patchGridYZ.Visible = 'Off';
        pr0_data.patchGridZX.Visible = 'Off';
        pr0_data.patchGridXY.Visible = 'Off';
        HA.Patch.EdgeColor = 'none';
        HA.Patch.LineStyle = 'none';
        HA.Patch.FaceColor = 'flat';
        statusTicker.String = 'View Reset ';
        statusTicker.ForegroundColor = 'b';
        for i = 1:length(array.blackRays)
            array.blackRays{i}.Visible = 'off';
        end
        for i = 1:length(array.redRays)
            array.redRays{i}.Visible = 'off';
        end
        for i = 1:length(array.allElements)
            array.patches{i}.Visible = 'off';
        end
        if array.performedTracing == 1
        HA.intersect.Visible = 'Off';
        end
        HA.focalPoint.Visible = 'Off';
        m2.Checked= 'off';
        m3.Checked= 'off';
        m4.Checked= 'off';
        m5.Checked= 'off';
        m6.Checked= 'off';
        m8.Checked= 'off';
        m9.Checked= 'off';
        m10.Checked= 'off';
      
end 
function toggleFocalPoint(hObject,source, evendata)
    
            if strcmp(get(hObject,'Checked'),'on') == 0
                statusTicker.String = 'Focal Point On ';
                statusTicker.ForegroundColor = 'b';
            HA.focalPoint.Visible = 'On';
            m4.Checked = 'on';
            else
                statusTicker.String = 'Focal Point Off ';
                statusTicker.ForegroundColor = 'b';
            HA.focalPoint.Visible = 'Off';
            m4.Checked = 'off';
            end
end
function toggleArray_callback(hObject,source, evendata)
    
            if strcmp(get(hObject,'Checked'),'on') == 0
                for i = 1:length(array.allElements)
                    array.patches{i}.Visible = 'on';
                end
                statusTicker.String = 'Array On ';
                statusTicker.ForegroundColor = 'b';     
                 m3.Checked = 'on';
            else
                for i = 1:length(array.allElements)
                    array.patches{i}.Visible = 'off';
                end
                statusTicker.String = 'Array Off ';
                statusTicker.ForegroundColor = 'b';
                 m3.Checked = 'off';
            end

end
function togglRayLines(hObject,source, evendata)
if array.performedTracing == 0
        statusTicker.String = 'Cant show Ray Lines, ray tracing data has not been calculated ';
                statusTicker.ForegroundColor = 'r';
else
    
            if strcmp(get(hObject,'Checked'),'on') == 0
                for i = 1:length(array.blackRays)
                    array.blackRays{i}.Visible = 'on';
                end
                for i = 1:length(array.redRays)
                    array.redRays{i}.Visible = 'on';
                end
                statusTicker.String = 'Ray Lines On ';
                statusTicker.ForegroundColor = 'b';
                m5.Checked = 'on';
            else
                for i = 1:length(array.blackRays)
                    array.blackRays{i}.Visible = 'off';
                end
                for i = 1:length(array.redRays)
                    array.redRays{i}.Visible = 'off';
                end
                statusTicker.String = 'Ray Lines Off ';
                statusTicker.ForegroundColor = 'b';
                m5.Checked = 'off';
            end
end
end
function toggleIntersectionsCallback(hObject,source, evendata)
   if array.performedTracing == 0
        statusTicker.String = 'Cant show Intersections, ray tracing data has not been calculated';
                statusTicker.ForegroundColor = 'r';
    else
            if strcmp(get(hObject,'Checked'),'on') == 0
                HA.intersect.Visible = 'On';
                HA.intersect.MarkerSize = 13;
                statusTicker.String = 'Intersections On ';
                statusTicker.ForegroundColor = 'b';
                m6.Checked = 'on';
                
            else 
                statusTicker.String = 'Intersections Off ';
               HA.intersect.Visible = 'Off';
               statusTicker.ForegroundColor = 'b';
                                m6.Checked = 'off';

            end
   end
    end
function xPortFigure_callback(source, eventdata)
    statusTicker.String = strcat('Exporting Figure');
        statusTicker.ForegroundColor = 'b';
        pause(0.01)
    
    [file,pathName,~] = uiputfile({'*.jpg';'*.fig';'*.m';'*.png';'*.bmp';'*.pdf'},'Save Figure',strcat(array.exportName,'Figure'));
%         figExport = strcat(,'Figure.fig');
%         
%         prompt = {'What would you like to name the file'};
%         dlg_title = 'Export Figure';
%         defaultans = {figExport};
%         numlines = [1 100];
%         OP = inputdlg(prompt,dlg_title,numlines,defaultans);
%         figFile = OP(1);
%         figFile = figFile{1};
        
%         set(0,'showhiddenhandles','on')
  
        fileName = strcat(pathName,file);
        
        Fig = figure('Name','Incident Pressure Field','NumberTitle','off','Visible','off','Position',[300,300,600,600]);
        copyobj([ha,HA.colorbar],Fig);
        saveas(Fig,fileName);
        close(Fig);
        statusTicker.String = strcat('Figure Exported as:- ', fileName);
        statusTicker.ForegroundColor = 'b';
end
function changeField(source,callbackdata)
        switch source.Label
            case 'XY Plane'
                switch source.Checked
                    case 'on'
                        pr0_data.patchGridXY.Visible = 'Off';
                        HA.Patch.FaceColor = 'flat';
                        statusTicker.String = 'XY Pressure Field off ';
                        statusTicker.ForegroundColor = 'b';
                        m8.Checked = 'off';
                        view(3)
                        HA.Patch.EdgeColor = 'none';
                        HA.Patch.LineStyle = 'none';
                        
                    case 'off'
                        pr0_data.patchGridYZ.Visible = 'Off';
                        pr0_data.patchGridZX.Visible = 'Off';
                        pr0_data.patchGridXY.Visible = 'On';
                        HA.Patch.FaceColor = 'w';
                        statusTicker.String = 'XY Pressure Field on ';
                        statusTicker.ForegroundColor = 'b';
                        view([0 -90])                     
                        
                        HA.Patch.EdgeColor = 'k';
                        HA.Patch.LineStyle = '-';
          
                        m8.Checked = 'on';
                        m9.Checked = 'off';
                        m10.Checked = 'off';
                end
                        

            case 'YZ Plane'
                switch source.Checked
                    case 'on'
                        pr0_data.patchGridYZ.Visible = 'Off';
                        HA.Patch.FaceColor = 'flat';
                        statusTicker.String = 'YZ Pressure Field off ';
                        statusTicker.ForegroundColor = 'b';
                        m9.Checked = 'off';
                        HA.Patch.EdgeColor = 'none';
                        HA.Patch.LineStyle = 'none';
                        view(3)  
                        
                    case 'off'
                        pr0_data.patchGridYZ.Visible = 'On';
                        pr0_data.patchGridZX.Visible = 'Off';
                        pr0_data.patchGridXY.Visible = 'Off';
                        HA.Patch.FaceColor = 'w';
                        statusTicker.String = 'YZ Pressure Field on ';
                        statusTicker.ForegroundColor = 'b';
                        
                        m8.Checked = 'off';
                        m9.Checked = 'on';
                        m10.Checked = 'off';
                        view([90 0])  
                        
                        HA.Patch.EdgeColor = 'k';
                        HA.Patch.LineStyle = '-';
                end
                      
            case 'ZX Plane'
                switch source.Checked
                    case 'on'
                        pr0_data.patchGridZX.Visible = 'Off';
                        HA.Patch.FaceColor = 'flat';
                        statusTicker.String = 'ZX Pressure Field off ';
                        statusTicker.ForegroundColor = 'b';
                        m10.Checked = 'off';
                        HA.Patch.EdgeColor = 'none';
                        HA.Patch.LineStyle = 'none';
                         view(3)  
                        
                    case 'off'
                        pr0_data.patchGridYZ.Visible = 'Off';
                        pr0_data.patchGridZX.Visible = 'On';
                        pr0_data.patchGridXY.Visible = 'Off';
                        HA.Patch.FaceColor = 'w';
                        statusTicker.String = 'ZX Pressure Field on ';
                        statusTicker.ForegroundColor = 'b';
                        
                        m8.Checked = 'off';
                        m9.Checked = 'off';
                        m10.Checked = 'on';
                        
                        HA.Patch.EdgeColor = 'k';
                        HA.Patch.LineStyle = '-';
                      view([180 0]) 
                end
 
        end
end
function flipView_callback(source,callbackdata)
    if strcmp(m10.Checked,'on') == 1
        ha.View = ha.View - [180 0];
    else
   ha.View = ha.View * -1;     
    end
end
%% Data Tab Callbacks

    function updateData()
        if array.performedTracing == 0
            traceString = 'No';
        else
            traceString = 'Yes';
        end
        if array.performedPhasing == 0
            phaseString = 'No';
        else
            phaseString = 'Yes';
        end
        rollpitchyaw = [array.roll,array.pitch,array.yaw];
        dataLabels= pad({'Time Initiated:';
                     'Time Taken:';
                     'Was Tracing Performed:';
                     'Was Phasing Performed:';
                     'Loaded Array File:';
                     'Loaded Mesh File:';
                     'Density of the medium:';
                     'Local Speed of Sound:';
                     'Wave Number:';
                     'Activated Elements:';
                     'Detrimental Elements:';
                     'Element Radius:';
                     'Element Resolution:';
                     'Array Curvature:';
                     'Array Translation:';
                     'Array Roll, Pitch, Yaw:';
                     'Array Centre Location:';
                     'Array Focal Point';
                     'Peak Pressure';
                     },'right');
        labelData.String = dataLabels;
        numericalData = pad({sprintf(array.timeInitiated);
                         sprintf('%12.2fs',array.timeTaken);
                         sprintf('%12s',traceString);
                         sprintf('%12s',phaseString);
                         sprintf('%12s', array.fileName);
                         sprintf('%12.30s %s', importedData.fileName , '...');
                         sprintf('%12dm^3',constants.rho0);
                         sprintf('%12dm/s',constants.c);
                         sprintf('%12.2f',constants.k);
                         sprintf('%12s',strcat(num2str(length(array.activeElements)),'/',num2str(length(array.allElements))));
                         sprintf('%12d',length(array.detrimentalElements));
                         sprintf('%12.4fm',array.pRad);
                         sprintf('%12s',strcat(num2str(array.pRes),'x',num2str(array.pRes)));
                         sprintf('%12.2fm',array.curv);
                         sprintf('%.2fm %.2fm %.2fm',array.transMat);
                         sprintf('    %5.4frad %5.4frad %5.4frad',rollpitchyaw);
                         sprintf('%.2fm %.2fm %.2fm',array.center);
                         sprintf('%.2fm %.2fm %.2fm',array.focalPoint);
                         sprintf('%.2gPA',max(HA.Patch.FaceVertexCData))
                       },'left');
                 numData.String = numericalData;         
                 
                 numericalData2 = pad({sprintf(array.timeInitiated);
                         sprintf('%12.2fs',array.timeTaken);
                         sprintf('%12s',traceString);
                         sprintf('%12s',phaseString);
                         sprintf('%12s', array.fileName);
                         sprintf('%12.30s', importedData.fileName);
                         sprintf('%12dm^3',constants.rho0);
                         sprintf('%12dm/s',constants.c);
                         sprintf('%12.2f',constants.k);
                         sprintf('%12s',strcat(num2str(length(array.activeElements)),'/',num2str(length(array.allElements))));
                         sprintf('%12d',length(array.detrimentalElements));
                         sprintf('%12.4fm',array.pRad);
                         sprintf('%12s',strcat(num2str(array.pRes),'x',num2str(array.pRes)));
                         sprintf('%12.2fm',array.curv);
                         sprintf('%.2fm %.2fm %.2fm',array.transMat);
                         sprintf('    %5.4frad %5.4frad %5.4frad',rollpitchyaw);
                         sprintf('%.2fm %.2fm %.2fm',array.center);
                         sprintf('%.2fm %.2fm %.2fm',array.focalPoint);
                         sprintf('%.2gPA',max(HA.Patch.FaceVertexCData))
                       },'left');
                 outputData.Settings = strcat(dataLabels,numericalData2);
                 
                 Face = outputData.Faces;
                 Pressure = outputData.Pressure;
                 xFace = outputData.Xcentroid;
                 yFace = outputData.Ycentroid;
                 zFace = outputData.Zcentroid;
                 
                 
%                  pressureTableCells = {Face,Pressure,x,y,z}
                 outputData.pressureTable = table(Face,Pressure,xFace,yFace,zFace);
                 outputData.pressureTableCells = table2cell(outputData.pressureTable);
                 
                 
                 presTable = uitable(pressureDataTab);
                 presTable.ColumnName = {'Face','Pressure(PA)','x(m)','y(m)','z(m)'};
                 presTable.Data = outputData.pressureTableCells;
                 presTable.Units = 'normalized';
                 presTable.Position = [.0001 .0001 1 1];
                 presTable.RowName = {};   
                 presTable.ColumnWidth ={30 100 60 60 60};
                   
                 element = array.allElements';
                 activated = (ismember(array.allElements,array.activeElements))';
                 speed = constants.uj;
                 xCentroid = array.testroids(:,1);
                 yCentroid = array.testroids(:,2);
                 zCentroid = array.testroids(:,3);
                 
                 if array.performedTracing == 0
                     detrimental = cell(length(array.allElements),1);
                     detrimental(:) = {'N/A'};
                     gNotPerformed.Visible = 'on';
                     
                     
                 else
                     gNotPerformed.Visible = 'off';
                     detrimental = (ismember(array.allElements,array.detrimentalElements))';
                     detElement = array.detrimentalElements';
                     interX = array.intersect(:,1);
                     interY = array.intersect(:,2);
                     interZ = array.intersect(:,3);
                     
                     outputData.intersectionTable = table(detElement,interX,interY,interZ);
                     outputData.intersectionTableCells = table2cell(outputData.intersectionTable);
                     
                     intTable = uitable(intersectionDataTab);
                     intTable.ColumnName = {'Elmnt.','x(m)','y(m)','z(m)'};
                     intTable.Data = outputData.intersectionTableCells;
                     intTable.Units = 'normalized';
                     intTable.Position = [.0001 .0001 1 1];
                     intTable.RowName = {};
                     intTable.ColumnWidth ={50 60 60 60};
                     
                 end
                 
               
                 
                 
                outputData.activeElementTable = table(element,activated,detrimental,speed,xCentroid,yCentroid,zCentroid);
                outputData.activeElementTableCells = table2cell(outputData.activeElementTable);
                
                actTable = uitable(activeElementDataTab);
                actTable.ColumnName = {'Elmnt.','Actv.','Det.','Uj','x(m)','y(m)','z(m)'};
                actTable.Data = outputData.activeElementTableCells;
                actTable.Units = 'normalized';
                actTable.Position = [.0001 .0001 1 1];
                actTable.RowName = {};
                actTable.ColumnWidth ={40 40 30 40 60 60 60};
                           
dataTabs.Visible = 'on';
    end
        function xPortData_callback(source,eventdata)
            datExport = strcat(array.exportName,'Data');
            
%             prompt = {'What would you like to name the file'};
%             dlg_title = 'Export Data';
%             defaultans = {datExport};
%             numlines = [1 100];
%             OP = inputdlg(prompt,dlg_title,numlines,defaultans);
%             datFile = OP(1);
%             datFile = datFile{1};
statusTicker.String = strcat('Exporting Data');
        statusTicker.ForegroundColor = 'b';
        pause(0.01)
    
    [file,pathName,~] = uiputfile({'*.dat';'*.txt'},'Save Data',datExport);
            fileName = strcat(pathName,file);
            
            
            writeSettings = cell2mat(outputData.Settings);
            
            fileID = fopen(fileName,'w');
            for i = 1:size(writeSettings,1)
            fprintf(fileID,'%s\r\n',writeSettings(i,1:size(writeSettings,2)));
            end
             pressureTable = cell2mat(outputData.pressureTableCells);
            activeElementTable = outputData.activeElementTableCells;
            intersectionTable = cell2mat(outputData.intersectionTableCells);
            
            fprintf(fileID,'%s\r\n','------------------------------------------------------------');    
            fprintf(fileID,'%s\r\n','$PressureData');   
            fprintf(fileID,'%-6s %11s %11s %11s %11s \r\n','Face','Pressure(PA)','x(m)','y(m)','z(m)');
            fprintf(fileID,'%6g %12.5f %12.5f %12.5f %12.5f\r\n', pressureTable');
            fprintf(fileID,'%s\r\n','$EndPressureData');   
            fprintf(fileID,'%s\r\n','$ActiveElementData');   
            fprintf(fileID,'%-5s %5s %5s %7s %10s %10s %10s \r\n','Element','Active','Detrimental','Uj','x(m)','y(m)','z(m)');
            if array.performedTracing == 0
                for i = 1:size(activeElementTable,1)
            fprintf(fileID,'%6g %5g %5s %17.5f %10.5f %10.5f %10.5f\r\n', activeElementTable{i,:});
                end
            else
                for i = 1:size(activeElementTable,1)
                    fprintf(fileID,'%6g %5g %5g %17.5f %10.5f %10.5f %10.5f\r\n', activeElementTable{i,:});
                end
            end
            fprintf(fileID,'%s\r\n','$EndActiveElementData');   
            fprintf(fileID,'%s\r\n','$IntersectionData');   
            if array.performedTracing == 0
                fprintf(fileID,'%s\r\n','No Intersection Data as Ray Tracing was not Performed');
            else
                fprintf(fileID,'%-5s %12s %10s %10s \r\n','Element','x(m)','y(m)','z(m)');
                fprintf(fileID,'%6g %12.5f %12.5f %12.5f\r\n', intersectionTable');
            end
            fprintf(fileID,'%s\r\n','$EndIntersectionData');
            fprintf(fileID,'%s\r\n','------------------------------------------------------------');    
            fprintf(fileID,'%s\r\n','Code Written By Rory Hedderman');  
            fprintf(fileID,'%s\r\n','Supervised by Dr Pierre Gelat');    
            fprintf(fileID,'%s\r\n','For Fulfillment of MECH3002');    
            fprintf(fileID,'%s\r\n','University College London');    
            fprintf(fileID,'%s\r\n','Mechanical Engineering Department');    
            fprintf(fileID,'%s\r\n','April 2018');    
            fclose(fileID);
            
            
            
            statusTicker.String = strcat('Data Exported as:- ', fileName);
            statusTicker.ForegroundColor = 'b';
            
            
        end
%% Introduction Side Tab


ax1 = axes('Units','normalized','Parent', introST,'Position', [.0,.0,1,1],'Visible','off','PickableParts','none');
setAllowAxesRotate(h,ax1,false);
text(.015,.715,{'This is a GUI designed and created for the use in the pre-treatement processing of a HIFU treatment plan.';' This GUI specialises in the ability to output incident pressure field and ray intersection data.'...
    ;''...   
    ;'\bf{Receiving Body}';'\rm Here you can input the receiving mesh file, or cuboidal planes.'...
    ;'\bf{Physical Constants}';'\rm Here you can input constants specific to the procedure.'...
    ;'\bf{Geometric Ray Tracing}';'\rm Here you can run ray tracing before the pressure field is calculated, and neutralise detrimental elements.'...
    ;'\bf{Phase Conjugation}';'\rm Here you can "steer" the beam of the array, bear in mind that ray tracing cannot be run on an array that ';' had its phases conjugated.'...
    ;'\bf{Run}';'\rm Here you can run the computation, there is an option to compute ray intersections as well as computing the ';'pressure field.'...
    ;''...
    ;'\bf{Plot}';'\rm The mesh and the overlaid pressure field will be plotted in the "plot" tab, with an option to export the figure.'...    
    ;'\bf{Data}';'\rm The data output from the computation is interpreted in tables, with the option to export the data.'})

intro.axes = axes('Units','normalized','Parent', introST,'Position', [.25,-.05,.464,.56],'PickableParts','none');
setAllowAxesRotate(h,intro.axes,false); % disable rotating for second plot
hold on
discArray(array,'colouring','none','view','fixed','rays','none')
setAllowAxesRotate(h,intro.axes,false);
axis equal
view(3)
intro.axes.Visible = 'Off';
axes(intro.axes)
            axis vis3d      
%% Recieving Body Side Tab

%recevingLimits button
rlButton = uicontrol('Units','normalized','Style', 'pushbutton','String', 'Input Limits' , ...
                  'Position', [.095,.475,.35,.085], 'Callback' , @limitDialog_callback ,...
                      'Parent', recBodyST,'enable','off','BackgroundColor', 'k','ForegroundColor', 'w');

%meshFile button
mfButton = uicontrol('Units','normalized', 'Style', 'pushbutton','String', 'Import Mesh File' ,...
                'Position', [.095,.825,.35,.085], 'Callback' , @readfileDialog_callback,...
                'Parent', recBodyST,'enable','on','BackgroundColor', 'k','ForegroundColor', 'w');
            
%Button Group
bg = uibuttongroup('Visible','off',...
                  'Position',[0 0 .2 1],...
                  'SelectionChangedFcn',@bselection,'Parent', recBodyST);
r1 = uicontrol(bg,'Style',...
                  'radiobutton',...
                  'String','Use Mesh File',...
                   'Units','normalized',...
              'Position',[.03,.92,.144,.06],...
                  'HandleVisibility','off','Parent', recBodyST,'BackgroundColor','w','callback',@r1selection,'Value',1);           
r2 = uicontrol(bg,'Style',...
                  'radiobutton',...
                  'String','Use Inputted Planes',...
                   'Units','normalized',...
              'Position',[.025 .618 .178 .052],...
                  'HandleVisibility','off','Parent', recBodyST,'BackgroundColor','w','callback',@r2selection,'Value',0);                       
%CurrentfILE
fileTitle = uicontrol('Style', 'text','String' ,....
    strcat('Current File =  ',importedData.fileName),'Units', ...
    'normalized' ,'Position', [.095,.675,.8,.085],...
    'BackgroundColor' ,'White', 'FontSize', 10,'Parent', recBodyST,'Units', ...
    'normalized','HorizontalAlignment','left');


function [Xmat,Ymat,Zmat] = limitDialog_callback(source,eventdata)
        
        %% Converting the Input
        importedData.fileName = '';
        prompt = {'Xmin' ;'Xmax'; 'X Step'; 'Ymin'; 'Ymax' ;'Y Step'; 'Zmin'; 'Zmax'; 'Z Step'};
        dlg_title = 'Input Linearly Spaced Limits';
        numlines = [1 10];
        defaultans = {num2str(spacedLimits.Xmin);num2str(spacedLimits.Xmax);...
            num2str(spacedLimits.XStep);num2str(spacedLimits.Ymin);num2str(spacedLimits.Ymax);...
            num2str(spacedLimits.YStep);num2str(spacedLimits.Zmin);num2str(spacedLimits.Zmax);...
            num2str(spacedLimits.ZStep)};
        OP = inputdlg(prompt,dlg_title,numlines, defaultans);
        OP1 = OP(1);
        OP2 = OP(2);
        OP3 = OP(3);
        OP4 = OP(4);
        OP5 = OP(5);
        OP6 = OP(6);
        OP7 = OP(7);
        OP8 = OP(8);
        OP9 = OP(9);
        
        spacedLimits.Xmin = str2num(OP1{:});
        spacedLimits.Xmax = str2num(OP2{:});
        spacedLimits.XStep = str2num(OP3{:});
        spacedLimits.Ymin = str2num(OP4{:});
        spacedLimits.Ymax = str2num(OP5{:});
        spacedLimits.YStep = str2num(OP6{:});
        spacedLimits.Zmin = str2num(OP7{:});
        spacedLimits.Zmax = str2num(OP8{:});
        spacedLimits.ZStep = str2num(OP9{:});
       
       inputData.Xmat = linspace(spacedLimits.Xmin,spacedLimits.Xmax,spacedLimits.XStep)';
       inputData.Ymat = linspace(spacedLimits.Ymin,spacedLimits.Ymax,spacedLimits.YStep)';
       inputData.Zmat = linspace(spacedLimits.Zmin,spacedLimits.Zmax,spacedLimits.ZStep)';
       %% Displaying the visual planes
       axes(xyAxes)
       cla
       axis equal
       plot3(array.defaultXvalue,array.defaultYvalue,array.defaultZvalue,'r.')
       [patchGridxy,XY_j] = triPlaneGenerator(inputData.Xmat,inputData.Ymat,inputData.Zmat,'xy');
       hold on
       plot3(XY_j(:,1),XY_j(:,2),XY_j(:,3))
       title('XY plane');
       xlabel(xaxis,'FontSize', 8);
       ylabel(yaxis,'FontSize', 8);
       zlabel(zaxis,'FontSize', 8);
       axis equal
        
   
        axes(yzAxes)
        cla
        axis equal
        plot3(array.defaultXvalue,array.defaultYvalue,array.defaultZvalue,'r.')
        [patchGridyz,YZ_j] = triPlaneGenerator(inputData.Xmat,inputData.Ymat,inputData.Zmat,'yz');
        hold on
        plot3(YZ_j(:,1),YZ_j(:,2),YZ_j(:,3))
        title('YZ plane');
        xlabel(xaxis,'FontSize', 8);
        ylabel(yaxis,'FontSize', 8);
        zlabel(zaxis,'FontSize', 8);
        axis equal
        
        
        axes(zxAxes)
        cla
        axis equal
        plot3(array.defaultXvalue,array.defaultYvalue,array.defaultZvalue,'r.')
        [patchGridzx,ZX_j] = triPlaneGenerator(inputData.Xmat,inputData.Ymat,inputData.Zmat,'zx');
        hold on
        plot3(ZX_j(:,1),ZX_j(:,2),ZX_j(:,3))
        title('ZX plane');
        xlabel(xaxis,'FontSize', 8);
        ylabel(yaxis,'FontSize', 8);
        zlabel(zaxis,'FontSize', 8);
        axis equal
        
        statusTicker.String = 'Limits Read, Calculating Pressure Field...';
        statusTicker.ForegroundColor = 'b';
        %% Constructing and hiding the Patch Pressure Data
        
        axes(XY.axes);
        
        cla
        XY.Patch = patch(patchGridxy);
        view([0 90])
        axis equal
        axes(YZ.axes);
        cla
        YZ.Patch = patch(patchGridyz);
        view([90 0])
        axis equal
        axes(ZX.axes);
        cla
        ZX.Patch = patch(patchGridzx);
        view([180 0]);
        axis equal
        XY.Patch.FaceVertexCData = pressureFieldV6(array,XY_j,constants);
        YZ.Patch.FaceVertexCData = pressureFieldV6(array,YZ_j,constants);
        ZX.Patch.FaceVertexCData = pressureFieldV6(array,ZX_j,constants);
        XY.Patch.FaceColor = 'flat';
        YZ.Patch.FaceColor = 'flat';
        ZX.Patch.FaceColor = 'flat';
        
   
       xyAxes.Visible = 'On';
       yzAxes.Visible = 'On';
       zxAxes.Visible = 'On';
       cla(ha)
       ha.Visible = 'Off';
       HA.colorbar.Visible = 'Off';
       hold on
       HA.focalPoint = plot3(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),'r.','MarkerSize',20) ;
       HA.focalPoint.Visible = 'Off';
        
        
        XY.Patch.Visible = 'Off';
        XY.axes.Visible = 'Off';
        XY.colorbar.Visible = 'Off';
        YZ.Patch.Visible = 'On';
        YZ.axes.Visible = 'Off';
        YZ.colorbar.Visible = 'Off';
        ZX.Patch.Visible = 'Off';
        ZX.axes.Visible = 'Off';
        ZX.colorbar.Visible = 'Off';

        statusTicker.String = 'Pressure Field Calculated, Press Go to Show Plot';
        statusTicker.ForegroundColor = 'b';
end
function readfileDialog_callback(source,eventdata)
        [file,path] = uigetfile('*.dat');
%         prompt = {'Input File Name and Location  (if the file is not in the home folder)'};
%         dlg_title = 'Import Mesh File';
%         defaultans = {'FourRibs_2p5mm_f60kHz_v1.dat'};
%         numlines = [1 100];
%         
%         OP = inputdlg(prompt,dlg_title,numlines,defaultans);
        statusTicker.String = 'Mesh Location Inputted';
        statusTicker.ForegroundColor = 'b';
%         
%         fileName = OP(1);
        importedData.fileName = strcat(path,file);
        fileTitle.String = sprintf('%s %3s', 'Current File = ',  importedData.fileName);
        updateControls()
end
function r1selection(source,event)
        r2.Value = 0;
        rlButton.Enable = 'off';
        fileTitle.Visible = 'on';
        mfButton.Enable = 'on';
    end
function r2selection(source,event)
        r1.Value = 0;
        mfButton.Enable = 'off';
        fileTitle.Visible = 'off';
        rlButton.Enable = 'on';
    end
%% Physical Constants Side Tab
%%%%%%% Ui Controls %%%%%%%
densityInput = uicontrol('Parent' , constantsST, 'Style','edit','Units','normalized','Position',[.45,.69,.205,.059], 'CallBack',@density_callback,...
                            'String',num2str(constants.rho0));

     
speedOfSoundInput= uicontrol('Parent' , constantsST, 'Style','edit','Units','normalized','Position',[.45,.59,.205,.059], 'CallBack',@sos_callback,...
                            'String',num2str(constants.c));
frequencyInput = uicontrol('Parent' , constantsST, 'Style','edit','Units','normalized','Position',[.45,.49,.205,.059], 'CallBack',@frequency_callback,...
                            'String',num2str(constants.f));
constantsDefaultsButton = uicontrol('Units','normalized','Style', 'pushbutton','String',...
                            'Restore Default Constants' , 'Position', [.776,.032,.205,.059], ...
                            'Callback', @constantsDefault_callback, 'Parent', constantsST);


densityTitle = uicontrol('Units','normalized','Style', 'text','String',('Density of the medium in m^3'), ...
    'Position', [.68,.69,.3,.059], ...
    'BackgroundColor' ,'White', 'FontSize',9,'Parent', constantsST);


speedofSoundTitle = uicontrol('Units','normalized','Style', 'text','String','Local speed of sound, in m/s' , ...
    'Position', [.68,.59,.3,.059],...
    'BackgroundColor' ,'White', 'FontSize', 9,'Parent', constantsST);


freqReadback = uicontrol('Units','normalized','Style', 'text','String','Frequency, in Hz', ...
    'Position', [.68,.49,.3,.059],...
    'BackgroundColor' ,'White', 'FontSize', 9,'Parent', constantsST);

rhoTitle = uicontrol('Units','normalized','Style', 'text','String',char(961), ...
    'Position', [.327,.67,.08,.085], ...
    'BackgroundColor' ,'White', 'FontSize',18,'Parent', constantsST);
cTitle = uicontrol('Units','normalized','Style', 'text','String','c', ...
    'Position', [.327,.57,.08,.085], ...
    'BackgroundColor' ,'White', 'FontSize',18,'Parent', constantsST,'FontAngle','Italic');
cTitle = uicontrol('Units','normalized','Style', 'text','String','f', ...
    'Position', [.327,.47,.08,.085], ...
    'BackgroundColor' ,'White', 'FontSize',18,'Parent', constantsST,'FontAngle','Italic');
%%%%%%% Call backs %%%%%%%%%%%%%%%%%
function density_callback(hObject,source,eventdata)
        constants.rho0 = get(hObject,'String');
updateControls()
end
function sos_callback(hObject,source,eventdata)
        constants.c = get(hObject,'String');
updateControls()
end
function frequency_callback(hObject,source,eventdata)
    constants.f = get(hObject,'String');
    constants.w    = 2*pi*constants.f;                           %% Rotational speed
    constants.k    = (constants.w/constants.c);                       %% wave number
updateControls()
    function constantsDefault_callback(source,eventdata)
        constants.rho0 = 1000;                                           %% density of the medium
        constants.uj   = ones(length(array.centroids),1);              %% magnitude of normal velocity of piston
        constants.c    = 1500;                                          %% local speed of sound
        constants.f    = 1E6    ;                                    %% Frequency
        constants.w    = 2*pi*constants.f;                           %% Rotational speed
        constants.k    = (constants.w/constants.c);   %% wave number
        updateControls()
    end
end
%% Array Settings Side Tab
%%%%%%%%%%%%%%% UI CONTROLS %%%%%%%%%%%%%%%

% import file
adButton = uicontrol('Units','normalized','Style', 'pushbutton','String', 'Import Array File' ,...
    'Position', [.05,.89,.205,.059], 'Callback' , @arrayFileDialog_callback,'Parent', arraysetsST,'BackgroundColor', 'k','ForegroundColor', 'w');
%Slider Resolution input
resSlider = uicontrol('Units','normalized','Style', 'slider', 'Min', 3, 'Max' , 50, 'Value' ,6, 'SliderStep', [0.0201,0.1042], ...
    'Position', [.085,.77,.2,.02], 'Callback',@slider_callback,'Parent', arraysetsST,'BackgroundColor', 'k','ForegroundColor', 'w');
%Pitch Slider input
pitchSlider = uicontrol('Units','normalized','Style', 'slider', 'Min', 0, 'Max' , 360, 'Value' ,0, 'SliderStep', [0.00278,0.00278], ...
    'Position', [.05,.2,.2,.02], 'Callback',@pitchSlider_callback,'Parent', arraysetsST,'BackgroundColor', 'k','ForegroundColor', 'w');
%Yaw Slider input
yawSlider = uicontrol('Units','normalized','Style', 'slider', 'Min', 0, 'Max' , 360, 'Value' ,0, 'SliderStep', [0.00278,0.00278], ...
    'Position', [.05,.1,.2,.02], 'Callback',@yawSlider_callback,'Parent', arraysetsST,'BackgroundColor', 'k','ForegroundColor', 'w');
%Roll Slider input
rollSlider = uicontrol('Units','normalized','Style', 'slider', 'Min', 0, 'Max' , 360, 'Value' ,0, 'SliderStep', [0.00278,0.00278], ...
    'Position', [.05,.3,.2,.02], 'Callback',@rollSlider_callback,'Parent', arraysetsST,'BackgroundColor', 'k','ForegroundColor', 'w');
%rollReadback
rollReadback = uicontrol('Units','normalized','Style', 'text','String',(['(x axis) Roll  ',char(952), ' - ']), ...
    'Position', [.05,.32,.2,.05], 'Callback' , @rollread_callback, ...
    'BackgroundColor' ,'White', 'FontSize', 10,'Parent', arraysetsST,'HorizontalAlignment','left');
%pitchReadback
pitchReadback = uicontrol('Units','normalized','Style', 'text','String',(['(y axis) Pitch  ',char(981), ' - ']), ...
    'Position', [.05,.22,.222,.05], 'Callback' , @pitchread_callback,...
    'BackgroundColor' ,'White', 'FontSize', 10,'Parent', arraysetsST,'HorizontalAlignment','left');
%yawReadbcak
yawReadback = uicontrol('Units','normalized','Style', 'text','String',(['(z axis) Yaw  ',char(936), ' - ']), ...
    'Position', [.05,.12,.2,.05], 'Callback' , @yawRead_callback, ...
    'BackgroundColor' ,'White', 'FontSize', 10,'Parent', arraysetsST,'HorizontalAlignment','left');

%Restore Array Defaults
arrayDefaultsButton = uicontrol('Units','normalized','Style', 'pushbutton','String', 'Restore Array Defaults' ,...
    'Position', [.776,.032,.205,.059], 'Callback' , @arrayDefaults_callback,'Parent', arraysetsST,'BackgroundColor', 'k','ForegroundColor', 'w');

%Fixed Focal Checkbox
fixedFocalCheckbox = uicontrol('Units','normalized','Style','check','Value',0,'String', 'Fix Focal Point','Parent', arraysetsST,...
    'Position', [.05,.4,.156,.05],'BackgroundColor' ,'White', 'Callback' , @fixFocal_callback);
% Piston Title
pistonTitle = uicontrol('Units','normalized','Style', 'text','String',({'Discretisation of One Element';'x'}), ...
    'Position', [.05,.813,.27,.06],...
    'BackgroundColor' ,'White', 'FontSize', 9,'Parent', arraysetsST,'FontWeight','bold');
% Piston Edit Boxes
pistonInput_1 = uicontrol('Parent' , arraysetsST, 'Style','edit','Units','normalized','Position',[.12,.8,.054,.041], 'CallBack',@callb,...
                            'String',num2str(array.pRes),'Callback',@pistonEditBox_callback);
pistonInput_2 = uicontrol('Parent' , arraysetsST, 'Style','edit','Units','normalized','Position',[.19,.8,.054,.041], 'CallBack',@callb,...
                            'String',num2str(array.pRes),'Callback',@pistonEditBox_callback);
                        

% roll pitch yaw degree titles
rollDegree = uicontrol('Units','normalized','Style', 'text','String',char(176), ...
    'Position', [.27,.34,.03,.03],...
    'BackgroundColor' ,'w', 'FontSize', 9,'Parent', arraysetsST);
pitchDegree = uicontrol('Units','normalized','Style', 'text','String',char(176), ...
    'Position', [.27,.24,.03,.03],...
    'BackgroundColor' ,'w', 'FontSize', 9,'Parent', arraysetsST);
yawDegree = uicontrol('Units','normalized','Style', 'text','String',char(176), ...
    'Position', [.27,.14,.03,.03],...
    'BackgroundColor' ,'w', 'FontSize', 9,'Parent', arraysetsST);

% roll pitch yaw edit boxes

rollInput = uicontrol('Parent' , arraysetsST, 'Style','edit','Units','normalized','Position',[.22,.33,.054,.041], 'CallBack',@callb,...
                            'String',num2str(rad2deg(array.roll)),'Callback',@rollEditBox_callback);
pitchInput = uicontrol('Parent' , arraysetsST, 'Style','edit','Units','normalized','Position',[.22,.23,.054,.041], 'CallBack',@callb,...
                            'String',num2str(rad2deg(array.pitch)),'Callback',@pitchEditBox_callback);
yawInput = uicontrol('Parent' , arraysetsST, 'Style','edit','Units','normalized','Position',[.22,.13,.054,.041], 'CallBack',@callb,...
                            'String',num2str(rad2deg(array.yaw)),'Callback',@yawEditBox_callback);
                        
 % translation title
 pistonTitle = uicontrol('Units','normalized','Style', 'text','String','Translate the x, y, z, center coordinates (in m)', ...
    'Position', [.305,.105,.45,.023],...
    'BackgroundColor' ,'White', 'FontSize', 9,'Parent', arraysetsST);
% x y z translate edit boxes
xInput = uicontrol('Parent' , arraysetsST, 'Style','edit','Units','normalized','Position',[.393,.05,.054,.041], 'CallBack',@callb,...
                            'String',num2str(array.transMat(1)),'Callback',@xEditBox_callback);
yInput = uicontrol('Parent' , arraysetsST, 'Style','edit','Units','normalized','Position',[.493,.05,.054,.041], 'CallBack',@callb,...
                            'String',num2str(array.transMat(2)),'Callback',@yEditBox_callback);
zInput = uicontrol('Parent' , arraysetsST, 'Style','edit','Units','normalized','Position',[.593,.05,.054,.041], 'CallBack',@callb,...
                            'String',num2str(array.transMat(3)),'Callback',@zEditBox_callback);

%%%%%%%%%%%%%%% Axes %%%%%%%%%%%%%%%
% plot of discretised piston data
pistonAxes.axes = axes('Units','normalized','Parent', arraysetsST,'Position', [.086,.535,.2,.2],'PickableParts','none');
setAllowAxesRotate(h,pistonAxes.axes,false);
pistonAxes.xlabel= xlabel(xaxis);
pistonAxes.ylabel= ylabel(yaxis);
pistonAxes.zlabel= zlabel(zaxis);
pistonAxes.axes.Visible = 'Off';
np = array.pRes;
xg = linspace(-(array.pRad), array.pRad, np);
yg = linspace(-(array.pRad), array.pRad, np);
[Xg,Yg] =  meshgrid(xg,yg);
sj = (xg(2) - xg(1))^2;
x2 = reshape(Xg, np*np, 1);
y2 = reshape(Yg, np*np, 1);
z2 = zeros(np*np,1);
xyz = [x2 y2 z2];
axes(pistonAxes.axes)
cla
hold on
plot3(xyz(:,1), xyz(:,2), xyz(:,3), 'b+')
n=find(sqrt(xyz(:,1).^2+xyz(:,2).^2)>= array.pRad);
xyz(n,:)=[];
hold on
plot3(xyz(:,1),xyz(:,2),xyz(:,3),'r+')
axis equal
pistonAxes.axes.Visible = 'On';

%preview Position axes
preview.axes = axes('Units','normalized','Parent', arraysetsST,'Position', [.45,.23,.464,.56],'PickableParts','none');
preview.Title= title('Array');
setAllowAxesRotate(h,preview.axes,false);
hold on
preview.xlabel= xlabel(xaxis);
preview.ylabel= ylabel(yaxis);
preview.zlabel= zlabel(zaxis);
discArray(array,'colouring','none','view','fixed','rays','none')
axis equal
view(3)
preview.axes.Visible = 'On';
%%%%%%%%%%%%%%% Callbacks %%%%%%%%%%%%%%%

function arrayFileDialog_callback(source,eventdata)
        prompt = {'Input File Name and Location  (if the file is not in the home folder)';...
            'Input the radius of curvature of the Array (in m)';...
            'Input the element radius'};
        defaultans = { array.fileName; num2str(array.curv);num2str(array.pRad)};
        dlg_title = 'Import Array File';
        numlines = [1 50; 1 50;1 50];
        OP = inputdlg(prompt,dlg_title,numlines,defaultans);
        array.fileName = OP(1);
        statusTicker.String = 'New array file imported.';
        statusTicker.ForegroundColor = 'b';
        R =OP(2);
        prad = OP(3);    
        array.fileName = array.fileName{:};
        array.curv = str2num(R{:});
        array.pRad = str2num(prad{:});
        array.originX = 0;
array.originY = 0;
array.originZ = 0;
xyz_data=load(array.fileName)';
array.defaultXvalue = xyz_data(:,1);
array.defaultYvalue = xyz_data(:,2);
array.defaultZvalue = xyz_data(:,3);
array.centroids = [array.defaultXvalue , array.defaultYvalue array.defaultZvalue];
array.normalRays = [];
array.focalPoint = [0 0 0];
array.center = [0 0 0-array.curv];
array.centerNormal = [0 0 1];
array.activeElements = 1:length(array.centroids);
array.allElements = 1:length(array.centroids);
array.deactiveElements = [];
array.detrimentalElements = [];
array.healthyElements = 1:length(array.centroids);
array.fixedFocal = 0;
array.transX = 0;
array.transY = 0;
array.transZ = 0;
array.transMat = [array.transX, array.transY, array.transZ];
array.performedTracing = 0;
array.performedPhasing = 0;
array.testroids = array.centroids;
constants.uj   = ones(length(array.centroids),1);
        
        
    end
function resDialog_callback(source,eventdata)
        prompt = {'Input the incrementation of each axis over the element';'Input the radius of the piston (in m)'};
        defaultans = { num2str(array.pRes); num2str(array.pRad)};
        dlg_title = 'Input Resolution';
        numlines = [1 60;1 60];
        OP = inputdlg(prompt,dlg_title,numlines,defaultans);
        res = OP(1);
        rad = OP(2);
        array.pRes = str2num(res{1});
        array.pRad = str2num(rad{:});
        statusTicker.String = 'New piston resolution inputted.';
        statusTicker.ForegroundColor = 'b';
        if array.pRes> 50
            array.pRes = 50;
        end
        
        pistonAxes.Title= title({'Discretisation of one element';' '});

           np = array.pRes;
           xg = linspace(-(array.pRad), array.pRad, np);
           yg = linspace(-(array.pRad), array.pRad, np);
           [Xg,Yg] =  meshgrid(xg,yg);
           sj = (xg(2) - xg(1))^2;
           x2 = reshape(Xg, np*np, 1);
           y2 = reshape(Yg, np*np, 1);
           z2 = zeros(np*np,1);
           xyz = [x2 y2 z2];
           axes(pistonAxes.axes)
           cla
           hold on
           plot3(xyz(:,1), xyz(:,2), xyz(:,3), 'b+')
           n=find(sqrt(xyz(:,1).^2+xyz(:,2).^2)>= array.pRad);
           xyz(n,:)=[];
           hold on
           plot3(xyz(:,1),xyz(:,2),xyz(:,3),'r+')
           axis equal
           pistonAxes.axes.Visible = 'On';
           array.sj = (pi*(array.pRad^2))/size(xyz,1);
        
end
function slider_callback(source,eventdata)
        array.pRes = floor(source.Value);
        statusTicker.String = 'New piston resolution inputted.';
        statusTicker.ForegroundColor = 'b';
           
           updateControls()
end
function pitchSlider_callback(source,eventdata)
        array.pitch = (deg2rad(source.Value));
        updateControls()  
        statusTicker.String = 'New pitch inputted.';
        statusTicker.ForegroundColor = 'b';
end
function yawSlider_callback(source,eventdata)
        array.yaw = (deg2rad(source.Value));
        hold on
       updateControls()  
       statusTicker.String = 'New yaw inputted.';
       statusTicker.ForegroundColor = 'b';
end
function rollSlider_callback(source,eventdata)
        array.roll = (deg2rad(source.Value));        
        updateControls()  
        statusTicker.String = 'New roll inputted.';
        statusTicker.ForegroundColor = 'b';
end

function pyrDialog_callback(source,eventdata)
        prompt = {'Roll (in Degrees)';'Pitch (in Degrees)';'Yaw (in Degrees)'};
        defaultans = { num2str(rad2deg(array.roll)); num2str(rad2deg(array.pitch)); num2str(rad2deg(array.yaw)) };
        dlg_title = 'Roll, Pitch, Yaw, Input';
        numlines = [1 60;1 60;1 60];
        OP = inputdlg(prompt,dlg_title,numlines,defaultans);
        r = OP(1);
        p = OP(2);
        y = OP(3);
        array.pitch = deg2rad(str2num(p{:}));
        array.yaw = deg2rad(str2num(y{:}));
        array.roll = deg2rad(str2num(r{:}));
        
        axes(roll.axes)
        hold on
        roll.Title= title(['Roll \theta =   ', num2str(rad2deg(array.roll)),char(176)]);
        axes(pitch.axes)
        hold on
        pitch.Title= title(['Pitch \Phi =   ', num2str(rad2deg(array.pitch)),char(176)]);
        axes(yaw.axes)
        hold on
        yaw.Title= title(['Yaw \Psi =   ', num2str(rad2deg(array.yaw)),char(176)]);
        updateControls()  
        statusTicker.String = 'New values for roll,pitch,yaw inputted.';
        statusTicker.ForegroundColor = 'b';
end
function transl_callback(source,eventdata)
        prompt = {'X value (in m)';'Y value (in m)';'Z value (in m)'};
        defaultans = { num2str(array.transX); num2str(array.transY); num2str(array.transZ) };
        dlg_title = 'Translate the centre of the array';
        numlines = [1 60;1 60;1 60];
        OP = inputdlg(prompt,dlg_title,numlines,defaultans);
        oX = OP(1);
        oY = OP(2);
        oZ = OP(3);
        array.transX = str2num(oX{:});
        array.transY = str2num(oY{:});
        array.transZ = str2num(oZ{:});
        array.transMat = [array.transX, array.transY, array.transZ];
        
        updateControls()  
        statusTicker.String = 'New Translation Inputted';
        statusTicker.ForegroundColor = 'b';
        
end
function arrayDefaults_callback(source,eventdata)
    [array,constants] = importDefault();
    updateControls()
    statusTicker.String = 'Array Defaults Restored.';
    statusTicker.ForegroundColor = 'b';
end
function fixFocal_callback(hObject,eventData,checkBoxId)
    array.fixedFocal = get(hObject,'Value');
    if array.fixedFocal == 1
    statusTicker.String = 'Focal Point Fixed.';
    statusTicker.ForegroundColor = 'b';
    else
        statusTicker.String = 'Focal Point unfixed.';
        statusTicker.ForegroundColor = 'b';
    end
    updateControls()
end
 function pistonEditBox_callback(hObject,source,eventdata)
 array.pRes = str2double(get(hObject,'String'));
updateControls()
     
 end
    function rollEditBox_callback(hObject,source,eventdata)
        array.roll = deg2rad(str2double(get(hObject,'String')));
updateControls()
    end
function pitchEditBox_callback(hObject,source,eventdata)
        array.pitch = deg2rad(str2double(get(hObject,'String')));
updateControls()
end
function yawEditBox_callback(hObject,source,eventdata)
        array.yaw = deg2rad(str2double(get(hObject,'String')));
updateControls()
end
    function xEditBox_callback(hObject,source,eventdata)
        array.transMat(1) = (str2double(get(hObject,'String')));
updateControls()
    end
function yEditBox_callback(hObject,source,eventdata)
        array.transMat(2) = (str2double(get(hObject,'String')));
updateControls()
end
function zEditBox_callback(hObject,source,eventdata)
        array.transMat(3) =(str2double(get(hObject,'String')));
updateControls()
    end
%% Geometric Ray Tracing Side Tab
%%%%%%%%%%%%%%%%% UI Controls %%%%%%%%%%%%%%%%%%%%%%

%Restore ray tracing Defaults
rayTracingDefaultButton = uicontrol('Units','normalized','Style', 'pushbutton','String', 'Restore Tracing Defaults' ,...
    'Position', [.776,.032,.205,.059], 'Callback' , @tracingDefaults_callback,'Parent', rayTraceST,'BackgroundColor', 'k','ForegroundColor', 'w');
runTracingButton = uicontrol('Units','normalized','Style', 'pushbutton','String', 'Run Ray Tracing' ,...
    'Position', [.05,.89,.205,.059], 'Callback' , @runTracing_callback,'Parent', rayTraceST,'BackgroundColor', 'k','ForegroundColor', 'w');
reRunTracingButton = uicontrol('Units','normalized','Style', 'pushbutton','String', 'Rerun Ray Tracing' ,...
    'Position', [.05,.89,.205,.059], 'Callback' , @reRunTracing_callback,'Parent', rayTraceST,'Visible','off','BackgroundColor', 'k','ForegroundColor', 'w');
neutraliseElementsButton = uicontrol('Units','normalized','Style', 'pushbutton','String', 'Neutralise Elements' ,...
    'Position', [.1,.26,.18,.05], 'Callback' , @neutraliseElements_callback,'Parent', rayTraceST,'Visible','off','BackgroundColor', 'k','ForegroundColor', 'w');
currentMeshText  = uicontrol('Units','normalized','Style', 'text','String' ,....
    {'Loaded Mesh is : ', importedData.fileName} ,'Position', [.056,.756,.318,.108],...
    'BackgroundColor' ,'White', 'FontSize', 10,'Parent', rayTraceST,'HorizontalAlignment', 'left');
tracingDataText = uicontrol('Units','normalized','Style', 'text','String' ,....
    '' ,'Position', [.4,.1,.58,.21],...
     'FontSize', 9,'Parent', rayTraceST,'HorizontalAlignment', 'left','BackgroundColor' ,'White','Visible','off');
 
%%%%%%%%%%%%%% Axes %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

raySystemAxes.axes= axes('Units','normalized','Parent', rayTraceST,'Position', [.4,.4,.45,.45]);
raySystemAxes.Title= title('Array-Mesh Intersections');
raySystemAxes.xlabel= xlabel(xaxis);
raySystemAxes.ylabel= ylabel(yaxis);
raySystemAxes.zlabel= zlabel(zaxis);
raySystemAxes.axes.Visible = 'Off';
view(3)

intersectElementsAxes.axes= axes('Units','normalized','Parent', rayTraceST,'Position', [.1,.425,.2,.2],'PickableParts','none');
setAllowAxesRotate(h,intersectElementsAxes.axes,false);
intersectElementsAxes.Title= title('Detrimental Elements');
intersectElementsAxes.xlabel= xlabel(xaxis);
intersectElementsAxes.ylabel= ylabel(yaxis);
intersectElementsAxes.zlabel= zlabel(zaxis);
intersectElementsAxes.axes.Visible = 'Off';


%%%%%%%%%%%%%% Callbacks %%%%%%%%%%%%%%%%%%%%%%

    function runTracing_callback(~,eventdata)
        runTracingButton.Visible = 'off';
        if array.performedTracing == 0
            statusTicker.ForegroundColor = 'b';
            statusTicker.String = 'Performing Ray Tracing...';
            pause(0.01)
            statusTicker.String = 'Reading Mesh File...';
           
            [centroidCoords,patchData] = readTriMeshFileVectorised(importedData.fileName);
            pause(0.01)
            statusTicker.String = 'Mesh File Read, Computing Intersections...';
            [array,~] = performAnalysis(array,centroidCoords,constants,patchData,'tracing','yes','pressure','no');
            
       
        else 
            statusTicker.String = 'Tracing Data Grabbed.';
            statusTicker.ForegroundColor = 'b';
            pause(0.01)
           array.rayPatchData = HA.Patch;
        end
       
        
        axes(raySystemAxes.axes)
        cla
        patch(array.rayPatchData)
        hold on
        if ~isempty(array.intersect)
        plot3(array.intersect(:,1), array.intersect(:,2), array.intersect(:,3), 'r.', 'MarkerSize', 10);
        end
        hold on
        discArray(array,'colouring','all','view','active','rays','det')
%         hold on
%         plot3(0,0,0,'b.','MarkerSize',30);
        axis equal
        raySystemAxes.axes.Visible = 'On';
        
        axes(intersectElementsAxes.axes)
        cla
        hold on
        discArray(array,'colouring','all','view','fixed','rays','none')
        view([0 90])
        
        axis equal
        intersectElementsAxes.axes.Visible = 'On';
        
        reRunTracingButton.Visible = 'on';
        neutraliseElementsButton.Visible = 'on';
        
        
        tracingDataTextString = strcat({num2str(length(array.detrimentalElements))}, {' out of '},...
            {num2str(length(array.activeElements))},...
           {' Elements have a Detrimental Pressure Effect on the Imported Mesh.'});
        tracingDataTextString = [tracingDataTextString...
            strcat({'Giving a Focal Point Pressure Coverage of '},...
            {num2str(((1 - (length(array.healthyElements)/length(array.activeElements)))*100))} , {' %.'})];
        
        tracingDataText.String = tracingDataTextString;
        
        tracingDataText.Visible = 'on';
        updateControls()
        statusTicker.String = 'Tracing Data Plotted.';
        statusTicker.ForegroundColor = 'b';
        pause(0.01)
    end
    function neutraliseElements_callback(source,eventdata)
         axes(raySystemAxes.axes)
         cla
          justNeutralised = array.detrimentalElements;
         array.activeElements = array.healthyElements;
         array.deactiveElements = (sort([array.detrimentalElements';array.deactiveElements']))';
         array.detrimentalElements = [];
        patch(array.rayPatchData)
        hold on 
        discArray(array,'colouring','all','view','active','rays','none')
        
        
        axes(intersectElementsAxes.axes)
        cla
        discArray(array,'colouring','all','view','fixed','rays','none')
        view([0 90])
        
        axis equal
       
        
        tracingDataTextString = strcat({num2str(length(justNeutralised))}, {' Elements have been Neutralised. '});
        tracingDataTextString = [tracingDataTextString strcat({'Bringing the total Neutralised Elements to '}, {num2str(length(array.deactiveElements))})]; 
        tracingDataTextString = [tracingDataTextString newline 'Press Rerun to get an updated Reading.'];
        tracingDataText.String = tracingDataTextString;
        statusTicker.String = 'Detrimental Elements Neutralised.';
        statusTicker.ForegroundColor = 'b';
        updateControls()
end
    function reRunTracing_callback(source,eventdata)
        statusTicker.String = 'Recalculating Tracing...';
        statusTicker.ForegroundColor = 'b';
        [centroidCoords,patchData] = readTriMeshFileVectorised(importedData.fileName);
        [array,~] = performAnalysis(array,centroidCoords,constants,patchData,'tracing','yes','pressure','no');
        axes(raySystemAxes.axes)
        cla
        patch(array.rayPatchData)
        hold on
        if ~isempty(array.intersect)
        plot3(array.intersect(:,1), array.intersect(:,2), array.intersect(:,3), 'r.', 'MarkerSize', 10);
        hold on
        end
        discArray(array,'colouring','all','view','active','rays','det')
%         hold on
%         plot3(0,0,0,'b.','MarkerSize',30);
        hold on
        axis equal
        raySystemAxes.axes.Visible = 'On';
        
        axes(intersectElementsAxes.axes)
        cla
        hold on
        discArray(array,'colouring','all','view','fixed','rays','none')
        view([0 90])
        axis equal
        intersectElementsAxes.axes.Visible = 'On';
        
        reRunTracingButton.Visible = 'on';
        neutraliseElementsButton.Visible = 'on';
        
        tracingDataTextString = strcat({num2str(length(array.deactiveElements))},...
            {' elements are currently Neutalised'});
        
        tracingDataTextString = [tracingDataTextString strcat({num2str(length(array.detrimentalElements))}, {' out of '},...
            {num2str(length(array.activeElements))},...
           {' Activated Elements have a Detrimental Pressure Effect on the Imported Mesh.'})];
        tracingDataTextString = [tracingDataTextString ...
            strcat({'Giving a Focal Point Pressure Coverage of '},...
            {num2str(((1 - (length(array.healthyElements)/length(array.activeElements)))*100))} , {' %.'})];
        
        tracingDataText.String = tracingDataTextString;
        
        tracingDataText.Visible = 'on';
        statusTicker.String = 'Tracing Data Plotted.';
        statusTicker.ForegroundColor = 'b';
        updateControls()
    end
    function tracingDefaults_callback(source,eventdata)
        array.activeElements = 1:length(array.centroids);
        array.deactiveElements = [];
        array.detrimentalElements = [];
        array.healthyElements = 1:length(array.centroids);
        cla(raySystemAxes.axes)
        raySystemAxes.axes.Visible = 'Off';
        cla(intersectElementsAxes.axes)
        intersectElementsAxes.axes.Visible = 'Off';
        runTracingButton.Visible = 'on';
        tracingDataText.Visible = 'off';
        reRunTracingButton.Visible = 'off';
        neutraliseElementsButton.Visible = 'off';
        statusTicker.String = 'Tracing Defaults Restored.';
        statusTicker.ForegroundColor = 'b';
        updateControls()
    end
%% Phase Conjugation Side Tab

%%%%%%%%%% UI CONTROLS %%%%%%%%%%%%%%%%%
phasingDefaultButton = uicontrol('Units','normalized','Style', 'pushbutton','String', 'Restore Phasing Defaults' ,...
    'Position', [.776,.032,.205,.059], 'Callback' , @rayTracingDefaults_callback,'Parent', phaseST,'BackgroundColor', 'k','ForegroundColor', 'w');

importNewFocalPointButton =uicontrol('Units','normalized','Style', 'pushbutton','String', 'Input New Focal Point' ,...
    'Position', [.2,.85,.2,.05], 'Callback' , @newFocalPoint_Callback,'Parent', phaseST,'BackgroundColor', 'k','ForegroundColor', 'w');

steerButton =uicontrol('Units','normalized','Style', 'pushbutton','String', 'Conjugate Phases' ,...
    'Position', [.6,.85,.2,.05], 'Callback' , @conjugate_callback,'Parent', phaseST,'BackgroundColor', 'k','ForegroundColor', 'w');

focalDataText = uicontrol('Units','normalized','Style', 'text','String' ,....
    sprintf('%s %.4fm %.4fm %.4fm','Current Focal Point     =  ', array.focalPoint),'Position', [.036,.02,.5,.05],...
     'FontSize', 9,'Parent', phaseST,'HorizontalAlignment', 'left','BackgroundColor' ,'White','Visible','on');
proposedfocalDataText = uicontrol('Units','normalized','Style', 'text','String' ,....
    sprintf('%s %.4fm %.4fm %.4fm','Proposed Focal Point     =  ', array.focalPoint),'Position', [.015,-.005,.5,.05],...
     'FontSize', 9,'Parent', phaseST,'HorizontalAlignment', 'left','BackgroundColor' ,'White','Visible','off');
 %%%%%%%%%% Axes %%%%%%%%%%%%%%%%%
 
 
 %Steering Position axes
phaseSteer.axes = axes('Units','normalized','Parent', phaseST,'Position', [.12,.15,.8,.8],'PickableParts','none');
setAllowAxesRotate(h,intersectElementsAxes.axes,false);
phaseSteer.Title= title('');
hold on
phaseSteer.xlabel= xlabel(xaxis);
phaseSteer.ylabel= ylabel(yaxis);
phaseSteer.zlabel= zlabel(zaxis);
discArray(array,'colouring','none','view','fixed','rays','none')
hold on
plot3(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),'r.','MarkerSize',20)
hold on
text(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),' \leftarrow  Focal Point');
hold on
axis equal
view(3)
phaseSteer.axes.Visible = 'On';

%%%%%%%%%%%%% Callbacks %%%%%%%%%%%%%%%%%%%%
    function newFocalPoint_Callback(source,eventdata)
prompt = {'X value (in m)';'Y value (in m)';'Z value (in m)'};
        defaultans = { num2str(array.focalPoint(:,1)); num2str(array.focalPoint(:,2)); num2str(array.focalPoint(:,3)) };
        dlg_title = 'Insert New Focal Point';
        numlines = [1 60;1 60;1 60];
        OP = inputdlg(prompt,dlg_title,numlines,defaultans);
        oX = OP(1);
        oY = OP(2);
        oZ = OP(3);
        array.newFocalPoint(:,1) = str2num(oX{:});
        array.newFocalPoint(:,2) = str2num(oY{:});
        array.newFocalPoint(:,3) = str2num(oZ{:});
        
        axes(phaseSteer.axes)
        cla
        discArray(array,'colouring','none','view','active','rays','none')
        hold on
%         quiver3(array.testroids(:,1),array.testroids(:,2),array.testroids(:,3),...
%             array.normalRays(:,1),array.normalRays(:,2),array.normalRays(:,3),13 ,'LineStyle', ':','LineWidth',0.0001,'Color','y');
%         hold on
        plot3(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),'r.','MarkerSize',20)
        hold on
        text(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),' \leftarrow  Focal Point');
        hold on
        plot3(array.newFocalPoint(:,1),array.newFocalPoint(:,2),array.newFocalPoint(:,3),'b.','MarkerSize',20)
        hold on
        text(array.newFocalPoint(:,1),array.newFocalPoint(:,2),array.newFocalPoint(:,3),' \leftarrow  Proposed Focal Point');
        
        
        proposedfocalDataText.String = sprintf('%s %.4fm %.4fm %.4fm','Proposed Focal Point     =  ', array.newFocalPoint);
        proposedfocalDataText.Visible = 'on';
        
        statusTicker.String = 'New focal point proposal inputted.';
        statusTicker.ForegroundColor = 'b';
        
        
    end
    function conjugate_callback(source,eventdata)
        statusTicker.String = 'Conjugating Phases...';
        statusTicker.ForegroundColor = 'b';
        [array] = streeringTimeReversal(array,constants,array.newFocalPoint);
        axes(phaseSteer.axes)
        array.focalPoint = array.newFocalPoint;
        cla
       discArray(array,'colouring','none','view','active','rays','none')
        hold on
        plot3(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),'r.','MarkerSize',20)
        hold on
        text(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),' \leftarrow  Focal Point');
        hold on
        constants.uj = array.steerVector;   
      focalDataText.String = sprintf('%s %.4fm %.4fm %.4fm','Current Focal Point     =  ', array.focalPoint);
      proposedfocalDataText.Visible = 'off';
      statusTicker.String = 'Phases conjugated, new element speed outputted.';
      HA.focalPoint = plot3(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),'r.','MarkerSize',20);
      statusTicker.ForegroundColor = 'b';
      array.performedPhasing = 1;
      raytraceCheckbox.String = 'Cannot run Tracing with conjugated Phases';
      raytraceCheckbox.Value = 0;
      raytraceCheckbox.Enable = 'off';
      runTracingButton.Enable = 'off';
      reRunTracingButton.Enable = 'off';
      currentMeshText.String = 'Cannot run Tracing with conjugated Phases';
      array.fullAnalysis = 0;
      updateControls()
    end
    function rayTracingDefaults_callback(source,eventdata)
        array.focalPoint = [0 0 0];
        focalDataText.String = sprintf('%s %.4fm %.4fm %.4fm','Current Focal Point     =  ', array.focalPoint);
        axes(phaseSteer.axes)
        cla
        discArray(array,'colouring','none','view','fixed','rays','none')
        hold on
        plot3(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),'r.','MarkerSize',20)
        hold on
        text(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),' \leftarrow  Focal Point');
        statusTicker.String = 'Phasing defaults Restored.';
        array.performedPhasing = 0;
        statusTicker.ForegroundColor = 'b';
        proposedfocalDataText.Visible = 'off';
        raytraceCheckbox.Enable = on;
        raytraceCheckbox.String = 'Run Ray Tracing as well as Pressure Analysis';
        raytraceCheckbox.Value = 1;
        runTracingButton.Enable = 'on';
      reRunTracingButton.Enable = 'on';
      currentMeshText.String = {'Loaded Mesh is : ', importedData.fileName};
    end
%% Run Side Tab
% UI controls
% Run Button
runButton = uicontrol('Units','normalized','Style', 'pushbutton','String',...
    'Run' , 'Position', [.393,.062,.205,.059], ...
    'Callback', @runbutton_callback, 'Parent', runSt,'BackgroundColor', 'k','ForegroundColor', 'w');
% Run ray tracing checkbox
%Fixed Focal Checkbox
raytraceCheckbox = uicontrol('Units','normalized','Style','check','Value',1,'String', 'Run Ray Tracing as well as Pressure Analysis','Parent', runSt,...
    'Position', [.302,.193,.42,.043],'BackgroundColor' ,'White', 'Callback' , @raytraceCheck_callback);

preLabelData = uicontrol('Units','normalized','Parent',runSt,'Style', 'text' ,'String','' , 'FontSize' ,9 ,...
    'Position',[.02,.525,.262,.46],'HorizontalAlignment','left','BackgroundColor','w');
preNumData = uicontrol('Units','normalized','Parent',runSt,'Style', 'text' ,'String','', 'FontSize' ,9 ,...
    'Position',[.3,.525,.691,.46],'HorizontalAlignment','right','BackgroundColor','w');
% callbacks
function runbutton_callback(source,eventdata)
      if strcmp(importedData.fileName,'') == 1   
                XY.Patch.Visible = 'On';
                XY.axes.Visible = 'On';
                XY.colorbar.Visible = 'On';
                YZ.Patch.Visible = 'Off';
                YZ.axes.Visible = 'Off';
                YZ.colorbar.Visible = 'Off';
                ZX.Patch.Visible = 'Off';
                ZX.axes.Visible = 'Off';
                ZX.colorbar.Visible = 'Off';
            XYplaneSelectorButton.Visible = 'On';
            YZplaneSelectorButton.Visible = 'On';
            ZXplaneSelectorButton.Visible ='On';
            toggleAutoRotationButton.Visible ='Off';
            resetViewButton.Visible = 'Off';
            showArrayButton.Visible = 'Off';
            showFocalPointButton.Visible = 'Off';
            xPortDataButton.Visible = 'On';
            xPortFigureButton.Visible = 'On';
            toggleRayLinesButton.Visible = 'Off';
            toggleRayIntersections.Visible = 'Off';
            dataTabs.Visible = 'On';
            numData.Visible = 'On';
            labelData.Visible = 'On';
            
            
            
      elseif strcmp(importedData.fileName,'') == 0
          statusTicker.String = 'Reading Mesh File...';
          statusTicker.ForegroundColor = 'b';
          pause(0.1)
          array.timeInitiated = char(datetime('now','InputFormat', 'MMMM d, yyyy HH:mm:ss'));
        array.exportName = char(datetime('now','Format','dd-MM-yy--HHmmss'));
        tic
        [centroidCoords,HA.Patch] = readTriMeshFileVectorised(importedData.fileName);
        
        if array.fullAnalysis == 1
            statusTicker.String = 'Mesh File Read, Running Geometric Ray Tracing and Pressure analysis...';
            statusTicker.ForegroundColor = 'b';
            pause(0.1)
            [array,pr0_data] = performAnalysis(array,centroidCoords,constants,HA.Patch,'Tracing','yes','pressure','yes');
            statusTicker.String = 'Geometric Ray Tracing and Pressure Field Finished, Patching...';
            statusTicker.ForegroundColor = 'b';
            
        else
             [array,pr0_data] = performAnalysis(array,centroidCoords,constants,HA.Patch,'Tracing','no','pressure','yes');
            statusTicker.String = 'Pressure Field Calculated, Patching Object...';
            statusTicker.ForegroundColor = 'b';
            pause(0.1)
        end
        statusTicker.String = 'Pressure Field Calculated, Patching Object...';
        statusTicker.ForegroundColor = 'b';
        pause(0.1)
          
          
          outputData.Faces = (1:length(centroidCoords))';
          outputData.Pressure = pr0_data.MeshPressure;
          outputData.Xcentroid = centroidCoords(:,1);
          outputData.Ycentroid = centroidCoords(:,2);
          outputData.Zcentroid = centroidCoords(:,3);
          
          
          
          
          cla(ha)
          axes(ha)
          HA.Patch = patch(HA.Patch);
          HA.Patch.FaceVertexCData = pr0_data.MeshPressure;
          HA.Patch.FaceColor = 'Flat';
          HA.Patch.EdgeColor = 'none';
          HA.Patch.LineStyle = 'none';         
          ha.Visible = 'Off';
          HA.colorbar.Visible = 'Off';
          HA.Patch.Visible = 'Off';
          
          axis equal
          hold on
          HA.focalPoint = plot3(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),'r.','MarkerSize',20);
          hold on
          
          if pr0_data.pressurePlaneField == 1
               pr0_data.patchGridYZ = patch(pr0_data.patchGridYZ);
               pr0_data.patchGridYZ.Visible = 'Off';
              pr0_data.patchGridYZ.FaceColor = 'Flat';
          pr0_data.patchGridYZ.EdgeColor = 'none';
          pr0_data.patchGridYZ.LineStyle = 'none';
          
          pr0_data.patchGridXY = patch(pr0_data.patchGridXY);
               pr0_data.patchGridXY.Visible = 'Off';
              pr0_data.patchGridXY.FaceColor = 'Flat';
          pr0_data.patchGridXY.EdgeColor = 'none';
          pr0_data.patchGridXY.LineStyle = 'none';
          
          pr0_data.patchGridZX = patch(pr0_data.patchGridZX);
               pr0_data.patchGridZX.Visible = 'Off';
              pr0_data.patchGridZX.FaceColor = 'Flat';
          pr0_data.patchGridZX.EdgeColor = 'none';
          pr0_data.patchGridZX.LineStyle = 'none';
          hold on
         
          elseif pr0_data.pressurePlaneField == 2
             
          end
          
          
          if ~isempty(array.intersect)
          if array.fullAnalysis == 1


              HA.intersect = plot3(array.intersect(:,1),array.intersect(:,2),array.intersect(:,3),'r.');
               HA.intersect.Visible = 'Off';
          
          end
          end
          hold on
          
         
          HA.focalPoint.Visible = 'Off';
          hold on
         
          HA.arrayPlot.Visible = 'Off';
          hold on
          title('')
          xlabel(xaxis)
          ylabel(yaxis)
          zlabel(zaxis)
          view(3);
          axis equal
          statusTicker.String = 'Object Patched, Plotting...';
          statusTicker.ForegroundColor = 'b';
          pause(0.1)
          XYplaneSelectorButton.Visible = 'Off';
          YZplaneSelectorButton.Visible = 'Off';
          ZXplaneSelectorButton.Visible = 'off';
       
        
        
          cla(XY.axes)
          cla(YZ.axes)
          cla(ZX.axes)
%           XY.Patch.Visible = 'Off';
          XY.axes.Visible = 'Off';
          XY.colorbar.Visible = 'Off';
%           YZ.Patch.Visible = 'Off';
          YZ.axes.Visible = 'Off';
          YZ.colorbar.Visible = 'Off';
%           ZX.Patch.Visible = 'Off';
          ZX.axes.Visible = 'Off';
          ZX.colorbar.Visible = 'Off';
          cla(xyAxes)
          cla(yzAxes)
          cla(zxAxes)
          xyAxes.Visible = 'Off';
          yzAxes.Visible = 'Off';
          zxAxes.Visible = 'Off';
          HA.Patch.Visible = 'On';
          dataTabs.Visible = 'On';
            numData.Visible = 'On';
            labelData.Visible = 'On';
            
          axes(ha)
          [array.patches,array.blackRays,array.redRays] = toggleDiscArray(array);
%           if array.performedTracing == 1
%           discArray(array,'colouring','det','view','active','rays','det')
%           else
%               discArray(array,'colouring','none','view','active','rays','none')
%           end
       
          ha.Visible = 'On';
          HA.colorbar.Visible = 'On';
          HA.Patch.Visible = 'On';
          axis equal
          XYplaneSelectorButton.Visible = 'Off';
          YZplaneSelectorButton.Visible = 'Off';
          ZXplaneSelectorButton.Visible ='Off';
          toggleAutoRotationButton.Visible ='On';
          resetViewButton.Visible = 'On';
          showArrayButton.Visible = 'On';
          showFocalPointButton.Visible = 'On';
          xPortDataButton.Visible = 'On';
          xPortFigureButton.Visible = 'On';
          toggleRayLinesButton.Visible = 'On';
            toggleRayIntersections.Visible = 'On';
            
          
            statusTicker.String = 'Object Plotted, Analysis Complete.';
            pause(0.1)
            sideTabs.SelectedTab = plotTab;
            plotTab.ForegroundColor = 'b';
            dataTab.ForegroundColor = 'b';
            
            array.timeTaken = toc;
            updateControls()
            updateData()
            
      end
          statusTicker.String = 'Plotted.';
          statusTicker.ForegroundColor = 'b';
          pause(0.1)
          
end
function raytraceCheck_callback(hObject,eventData,checkBoxId)
    array.fullAnalysis = get(hObject,'Value');
end
%% Global Axes
%% Global Callback
    function updateControls()
        
        
        axes(preview.axes)
        cla
        hold on
        discArray(array,'colouring','none','view','active','rays','none')

        axis equal
        
        %% Update Piston discrete
        axes(pistonAxes.axes)
           np = array.pRes;
           xg = linspace(-(array.pRad), array.pRad, np);
           yg = linspace(-(array.pRad), array.pRad, np);
           [Xg,Yg] =  meshgrid(xg,yg);
           sj = (xg(2) - xg(1))^2;
           x2 = reshape(Xg, np*np, 1);
           y2 = reshape(Yg, np*np, 1);
           z2 = zeros(np*np,1);
           xyz = [x2 y2 z2];
           axes(pistonAxes.axes)
           cla
           hold on
           plot3(xyz(:,1), xyz(:,2), xyz(:,3), 'b+')
           n=find(sqrt(xyz(:,1).^2+xyz(:,2).^2)>= array.pRad);
           xyz(n,:)=[];
           hold on
           plot3(xyz(:,1),xyz(:,2),xyz(:,3),'r+')
           axis equal
           pistonAxes.axes.Visible = 'On';
           array.sj = (pi*(array.pRad^2))/size(xyz,1);
           

        %% readbacks  
        % Ray Tracing Update
        if isempty(tracingDataText.String)
        tracingDataText.String = {' '};
        end
       
        tracingDataText.String = [tracingDataText.String; newline; 'Note the array has been changed, you may need to Rerun to get an updated Reading.'];
        currentMeshText.String = {'Loaded Mesh is : ', importedData.fileName};
        %% Change focal point
        
        Mx_roll = [1 0 0;
        0 cos(array.roll) -sin(array.roll);
        0 sin(array.roll) cos(array.roll)];
    
    My_pitch = [cos(array.pitch) 0 sin(array.pitch);
        0 1 0;
        -sin(array.pitch) 0 cos(array.pitch)];
    Mz_yaw = [cos(array.yaw) -sin(array.yaw) 0;
        sin(array.yaw) cos(array.yaw) 0;
        0 0 1];
movingCenter = ((Mx_roll * My_pitch * Mz_yaw * array.center'))';
if array.fixedFocal == 0
%     array.focalPoint = [0 0 -array.curv] - movingCenter + array.transMat;
    array.focalPoint = array.focalPoint + [0 0 -array.curv] - movingCenter + array.transMat;
        
end 

axes(phaseSteer.axes)
cla
discArray(array,'colouring','none','view','active','rays','none')
hold on
plot3(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),'r.','MarkerSize',20)
        hold on
        text(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),' \leftarrow  Focal Point');
        hold on
focalDataText.String = sprintf('%s %.4fm %.4fm %.4fm','Current Focal Point     =  ', array.focalPoint);

        %% Edit Boxes
        pistonInput_1.String = num2str(array.pRes);
        pistonInput_2.String = num2str(array.pRes);
        rollInput.String = num2str(floor(rad2deg(array.roll)));
        pitchInput.String = num2str(floor(rad2deg(array.pitch)));
        yawInput.String = num2str(floor(rad2deg(array.yaw)));
        xInput.String = num2str(array.transMat(1));
        yInput.String = num2str(array.transMat(2));
        zInput.String = num2str(array.transMat(3));
        
        %% data
        if array.performedTracing == 0
            traceString = 'No';
        else
            traceString = 'Yes';
        end
        if array.performedPhasing == 0
            phaseString = 'No';
        else
            phaseString = 'Yes';
        end
        rollpitchyaw = [array.roll,array.pitch,array.yaw];
        dataLabels= pad({'Has Tracing been Performed:';
                     'Has Phasing been Performed:';
                     'Loaded Array File:';
                     'Loaded Mesh File:';
                     'Density of the medium:';
                     'Local Speed of Sound:';
                     'Wave Number:';
                     'Activated Elements:';
                     'Detrimental Elements:';
                     'Element Radius:';
                     'Element Resolution:';
                     'Array Curvature:';
                     'Array Translation:';
                     'Array Roll, Pitch, Yaw:';
                     'Array Centre Location:';
                     'Array Focal Point';
                     },'right');
        numericalData = pad({sprintf('%12s',traceString);
                         sprintf('%12s',phaseString);
                         sprintf('%12s', array.fileName);
                         sprintf('%12s', importedData.fileName);
                         sprintf('%12dm^3',constants.rho0);
                         sprintf('%12dm/s',constants.c);
                         sprintf('%12.2f',constants.k);
                         sprintf('%12s',strcat(num2str(length(array.activeElements)),'/',num2str(length(array.allElements))));
                         sprintf('%12d',length(array.detrimentalElements));
                         sprintf('%12.4fm',array.pRad);
                         sprintf('%12s',strcat(num2str(array.pRes),'x',num2str(array.pRes)));
                         sprintf('%12.2fm',array.curv);
                         sprintf('%.2fm %.2fm %.2fm',array.transMat);
                         sprintf('    %5.4frad %5.4frad %5.4frad',rollpitchyaw);
                         sprintf('%.2fm %.2fm %.2fm',array.center);
                         sprintf('%.2fm %.2fm %.2fm',array.focalPoint);                 
                       },'left');   
                   
                   preLabelData.String = dataLabels;
                   preNumData.String = numericalData;
%             while tgroup.SelectedTab == homeTab
%                 
%                 drawnow
%                 view([i,30])
%                 i = i+0.1;
%                 pause(0.01);
%             end       
                   
    end

    function globalDefaults_callback(source,eventdata)
        statusTicker.String = 'Restoring Defaults ';
        pause(0.1)
        [array,constants] = importDefault();
     spacedLimits = struct('Xmin',-2.5e-2,'Xmax', 2.5e-2, 'XStep', 50,...
         'Ymin', -5e-2,'Ymax', 5e-2, 'YStep',50, 'Zmin', -2.5e-2, 'Zmax',2.5e-2,'ZStep',  50);
     inputData = struct('Xmat',linspace(-2.5e-2,2.5e-2,50)' ,'Ymat',linspace(-5e-2,5e-2,50)' ...
         , 'Zmat' ,linspace(-2.5e-2,2.5e-2,50)', 'plane' , 'xy','res',25);
     importedData = struct('fileName', '');
     i=-37.5;
     importedData.fileName = 'FourRibs_2p5mm_f60kHz_v1.dat';
     outputData = struct();
     cla(XY.axes)
     cla(YZ.axes)
     cla(ZX.axes)
     XY.axes.Visible = 'Off';
     XY.colorbar.Visible = 'Off';
     YZ.axes.Visible = 'Off';
     YZ.colorbar.Visible = 'Off';
     ZX.axes.Visible = 'Off';
     ZX.colorbar.Visible = 'Off';
     cla(xyAxes)
     cla(yzAxes)
     cla(zxAxes)
     cla(ha)
     ha.Visible = 'Off';
     HA.colorbar.Visible = 'Off';
     xyAxes.Visible = 'Off';
     yzAxes.Visible = 'Off';
     zxAxes.Visible = 'Off';
     dataTabs.Visible = 'Off';
     numData.Visible = 'Off';
     labelData.Visible = 'Off';
     XY.Patch.Visible = 'Off';
     XY.axes.Visible = 'Off';
     XY.colorbar.Visible = 'Off';
     YZ.Patch.Visible = 'Off';
     YZ.axes.Visible = 'Off';
     YZ.colorbar.Visible = 'Off';
     ZX.Patch.Visible = 'Off';
     ZX.axes.Visible = 'Off';
     ZX.colorbar.Visible = 'Off';
     XYplaneSelectorButton.Visible = 'Off';
     YZplaneSelectorButton.Visible = 'Off';
     ZXplaneSelectorButton.Visible ='Off';
     toggleAutoRotationButton.Visible ='Off';
     resetViewButton.Visible = 'Off';
     showArrayButton.Visible = 'Off';
     showFocalPointButton.Visible = 'Off';
     xPortDataButton.Visible = 'Off';
     xPortFigureButton.Visible = 'Off';
     toggleRayLinesButton.Visible = 'Off';
     toggleRayIntersections.Visible = 'Off';
     
        
                statusTicker.ForegroundColor = 'b';
                pause(0.1)
        array.NeutralisedElements = [];
        cla(raySystemAxes.axes)
        raySystemAxes.axes.Visible = 'Off';
        cla(intersectElementsAxes.axes)
        intersectElementsAxes.axes.Visible = 'Off';
        runTracingButton.Visible = 'on';
        tracingDataText.Visible = 'off';
        reRunTracingButton.Visible = 'off';
        
        [array,constants] = importDefault();
         updateControls()
        neutraliseElementsButton.Visible = 'off';
        
        array.focalPoint = [0 0 0];
        focalDataText.String = sprintf('%s %.4fm %.4fm %.4fm','Current Focal Point     =  ', array.focalPoint);
        axes(phaseSteer.axes)
        cla
        discArray(array,'colouring','none','view','fixed','rays','none')
        hold on
        plot3(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),'r.','MarkerSize',20)
        hold on
        text(array.focalPoint(:,1),array.focalPoint(:,2),array.focalPoint(:,3),' \leftarrow  Focal Point');
        proposedfocalDataText.Visible = 'off';
        raytraceCheckbox.Enable = 'on';
        raytraceCheckbox.String = 'Run Ray Tracing as well as Pressure Analysis';
        raytraceCheckbox.Value = 1;
        runTracingButton.Enable = 'on';
      reRunTracingButton.Enable = 'on';
      currentMeshText.String = {'Loaded Mesh is : ', importedData.fileName};
        statusTicker.String = 'All defaults restored.';
        statusTicker.ForegroundColor = 'b';
        pause(0.1)
        plotTab.ForegroundColor = 'r';
            dataTab.ForegroundColor = 'r';
    end
    
    updateControls();

end