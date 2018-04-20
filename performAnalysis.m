%FullAnalysis
function [array,pr0_data] = performAnalysis(array,xyz_j,constants,patchData,varargin)

Tracing  = 'No';
Pressure = 'Yes';
PlaneFields = 'all';

nVarargs   = length(varargin);
transMat = array.transMat;
k=1;
while (k<=nVarargs)
    assert(ischar(varargin{k}), 'Incorrect input parameters')
    switch lower(varargin{k})
      case 'tracing'
        Tracing = lower(strtrim(varargin{k+1}));
        k = k+1;
    case 'pressure'
        Pressure = lower(strtrim(varargin{k+1}));
        k = k+1;
        case 'planefields'
            PlaneFields = lower(strtrim(varargin{k+1}));
            k = k+1;
    end
    k = k+1;
end


switch PlaneFields
%     case 'single'
%         Xmat = linspace(-array.curv,array.curv,100);
%         Ymat = linspace(-array.curv,array.curv,100);
%         Zmat = linspace(-array.curv,array.curv,100);
%         [pr0_data.patchGridYZ,YZ_j] = triPlaneGenerator(Xmat,Ymat,Zmat,'yz');
%         YZ_pr0 = zeros(length(YZ_j),1);
    case 'all'
        Xmat = linspace(array.focalPoint(:,1)-(array.curv/2),array.focalPoint(:,1)+(array.curv/2),150);
        Ymat = linspace(array.focalPoint(:,2)-(array.curv/2),array.focalPoint(:,2)+(array.curv/2),150);
        Zmat = linspace(array.focalPoint(:,3)-(array.curv/2),array.focalPoint(:,3)+(array.curv/2),150);
        [pr0_data.patchGridYZ,YZ_j] = triPlaneGenerator(Xmat,Ymat,Zmat,'yz',array);
        [pr0_data.patchGridXY,XY_j] = triPlaneGenerator(Xmat,Ymat,Zmat,'xy',array);
        [pr0_data.patchGridZX,ZX_j] = triPlaneGenerator(Zmat,Ymat,Xmat,'zx',array);
        
        XY_pr0 = zeros(length(XY_j),1);
        ZX_pr0 = zeros(length(ZX_j),1);
        YZ_pr0 = zeros(length(YZ_j),1);

end
xyz_data=load(array.fileName)';
R = array.curv;

Xvalue = xyz_data(:,1);
Yvalue = xyz_data(:,2);
Zvalue = xyz_data(:,3);
theta = (asin(-Xvalue/R));
phi = (asin(Yvalue/R.*cos(theta)));
 
%% Variables;

rho0 = constants.rho0;          %% density of the medium
uj   = constants.uj;          %% magnitude of normal velocity of each piston
c    = constants.c;       %% local speed of sound
f    = constants.f;       %% Frequency
w    = 2*pi*constants.f;                           %% Rotational speed
k   = (constants.w/constants.c); 


%% Set up dummy axial piston
r=array.pRad;

np = array.pRes; % number of points

originX = 0;
originY = 0;
originZ = 0;

xg = linspace(originX-r, originX+r, np);
yg = linspace(originY-r, originY+r, np); 
[Xg,Yg] =  meshgrid(xg,yg);

x2 = reshape(Xg, np*np, 1);
y2 = reshape(Yg, np*np, 1);
z2 = (originZ*(ones(np*np,1))) - R;
xyz = [x2 y2 z2];

n= sqrt(xyz(:,1).^2+xyz(:,2).^2)>= r;
xyz(n,:)=[];

%% normal matrix and surface section size


nj = 1;
sj = (pi*(r^2))/size(xyz,1); 
array.rayPatchData = patchData;

    
normal = [xyz(:,1)-xyz(:,1),xyz(:,2)-xyz(:,2),xyz(:,3)./xyz(:,3)];
% figure 

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
    
    fixedFocal = array.fixedFocal;
curv = array.curv;


switch PlaneFields
 case 'valid'
     totalPr0 = 0;
        for i = array.activeElements
    
%% Rotating elements
    M_phi = [1 0 0;
      0 cos(phi(i,:)) -sin(phi(i,:));
      0 sin(phi(i,:)) cos(phi(i,:))]; % rotation matrix around the x axis

M_theta = [cos(theta(i,:)) 0 sin(theta(i,:)); % rotation matrix around the y axis
       0 1 0;
       -sin(theta(i,:)) 0 cos(theta(i,:))];

rot_xyz =M_theta*M_phi*xyz';
rot_xyz = rot_xyz';  

    rot_xyz = ((Mx_roll * My_pitch * Mz_yaw * rot_xyz'))';

   rot_xyz = rot_xyz+array.transMat;
   
   if array.fixedFocal == 0

       rot_xyz = rot_xyz - movingCenter  + [0 0 -array.curv];
   end

   
    x_0 = repmat( rot_xyz(:,1),1, length(xyz_j));
    y_0 = repmat( rot_xyz(:,2),1, length(xyz_j));
    z_0 = repmat( rot_xyz(:,3),1, length(xyz_j));
    x_j = repmat( xyz_j(:,1),1, length(xyz))';
    y_j = repmat( xyz_j(:,2),  1, length(xyz))';
    z_j =  repmat( xyz_j(:,3),1,length(xyz))';
    
    
    
    %% Rayleigh Integral
    
    Rj = sqrt(((x_j-x_0).^2) + ((y_j-y_0).^2) + ((z_j-z_0).^2));
    
    phi1=sum(uj(i)*exp(-1i*k*Rj)./Rj)/(2*pi);
    pr0_sum=1i*phi1*2*pi*f*rho0*sj;
    
    totalPr0 = totalPr0 + pr0_sum;

        end
pr0_data = abs(totalPr0.');

return
    
    
    
    
    
    case 'all'
intersect =zeros(size(array.activeElements,2),3);
healthyElements = zeros(size(array.activeElements,2),1);
detrimentalElements = zeros(size(array.activeElements,2),1);
if array.fullAnalysis == 1
    performTracing = 1;
else
    performTracing = 0;
end
rayPatchData = patchData;


totalPr0 = zeros(length(xyz_j),1);
deactiveElements = array.deactiveElements;
   
parfor i = array.allElements
    
    
    
  
%% Rotating elements
if nonzeros(i == deactiveElements) == 1
    continue
end

    M_phi = [1 0 0;
      0 cos(phi(i,:)) -sin(phi(i,:));
      0 sin(phi(i,:)) cos(phi(i,:))]; % rotation matrix around the x axis

M_theta = [cos(theta(i,:)) 0 sin(theta(i,:)); % rotation matrix around the y axis
       0 1 0;
       -sin(theta(i,:)) 0 cos(theta(i,:))];

rot_xyz =M_theta*M_phi*xyz';
rot_xyz = rot_xyz';
rot_Normal = M_theta*M_phi*normal';
rot_Normal = rot_Normal';



rot_xyz = ((Mx_roll * My_pitch * Mz_yaw * rot_xyz'))';
rot_xyz = rot_xyz+transMat;
rot_Normal = ((Mx_roll * My_pitch * Mz_yaw * rot_Normal'))';


if fixedFocal == 0

       rot_xyz = rot_xyz - movingCenter  + [0 0 -curv];
end
   

%% Calculating the Hits

n = 1:length(rayPatchData.Faces);
m = 1:length(rot_xyz);
[nVals, mVals] = meshgrid(n,m);
%%
switch Tracing
    case 'yes'
        if performTracing == 1
orig = rot_xyz(mVals,:);
dir = [rot_Normal(mVals,1),rot_Normal(mVals,2),rot_Normal(mVals,3)];
vert0 = patchData.Vertices((3*nVals)-2,:);
vert1 = patchData.Vertices((3*nVals)-1,:);
vert2 = patchData.Vertices(3*nVals,:);

[int, t, u, v, xcoor] = TriangleRayIntersection ( orig, dir, vert0, vert1, vert2);

interCoords = xcoor;
interCoords(~any(~isnan(interCoords), 2),:)=[];

if length(interCoords) >= length(rot_xyz)/2
    intersect(i,:,end) = mean(interCoords);
    detrimentalElements(i) = i;
    
    
else
    healthyElements(i) = i;

end
        end
        

end

switch Pressure
    case 'yes'
x_0 = repmat( rot_xyz(:,1),1, length(xyz_j));
    y_0 = repmat( rot_xyz(:,2),1, length(xyz_j));
    z_0 = repmat( rot_xyz(:,3),1, length(xyz_j));
    x_j = repmat( xyz_j(:,1),1, length(xyz))';
    y_j = repmat( xyz_j(:,2),  1, length(xyz))';
    z_j =  repmat( xyz_j(:,3),1,length(xyz))';
    
    
    
    %% Rayleigh Integral
    
    Rj = sqrt(((x_j-x_0).^2) + ((y_j-y_0).^2) + ((z_j-z_0).^2));
    
    
    phi1=sum(uj(i)*exp(-1i*k*Rj)./Rj)/(2*pi);
    
    
    pr0_sum=1i*phi1*2*pi*f*rho0*sj;
    
    case 'no'
      pr0_sum = 0;
        
end
totalPr0 = totalPr0 + pr0_sum';

switch PlaneFields
    case 'all'
        
    %% XY Plane    
        x_0 = repmat( rot_xyz(:,1),1, length(XY_j));
        y_0 = repmat( rot_xyz(:,2),1, length(XY_j));
        z_0 = repmat( rot_xyz(:,3),1, length(XY_j));
        x_j = repmat( XY_j(:,1),1, length(xyz))';
        y_j = repmat( XY_j(:,2),  1, length(xyz))';
        z_j =  repmat( XY_j(:,3),1,length(xyz))';
  
    Rj = sqrt(((x_j-x_0).^2) + ((y_j-y_0).^2) + ((z_j-z_0).^2));
    phi1=sum(uj(i)*exp(-1i*k*Rj)./Rj)/(2*pi);
    pr0_sum=1i*phi1*2*pi*f*rho0*sj;       
    XY_pr0 = XY_pr0 + pr0_sum';    
    %% ZX Plane
    x_0 = repmat( rot_xyz(:,1),1, length(ZX_j));
        y_0 = repmat( rot_xyz(:,2),1, length(ZX_j));
        z_0 = repmat( rot_xyz(:,3),1, length(ZX_j));
        x_j = repmat( ZX_j(:,1),1, length(xyz))';
        y_j = repmat( ZX_j(:,2),  1, length(xyz))';
        z_j =  repmat( ZX_j(:,3),1,length(xyz))';
    
    Rj = sqrt(((x_j-x_0).^2) + ((y_j-y_0).^2) + ((z_j-z_0).^2));
    phi1=sum(uj(i)*exp(-1i*k*Rj)./Rj)/(2*pi);
    pr0_sum=1i*phi1*2*pi*f*rho0*sj;   
    ZX_pr0 = ZX_pr0 + pr0_sum' ;
    
    %% YZ Plane
    
    x_0 = repmat( rot_xyz(:,1),1, length(YZ_j));
        y_0 = repmat( rot_xyz(:,2),1, length(YZ_j));
        z_0 = repmat( rot_xyz(:,3),1, length(YZ_j));
        x_j = repmat( YZ_j(:,1),1, length(xyz))';
        y_j = repmat( YZ_j(:,2),  1, length(xyz))';
        z_j =  repmat( YZ_j(:,3),1,length(xyz))';

    Rj = sqrt(((x_j-x_0).^2) + ((y_j-y_0).^2) + ((z_j-z_0).^2));  
    phi1=sum(uj(i)*exp(-1i*k*Rj)./Rj)/(2*pi);
    pr0_sum=1i*phi1*2*pi*f*rho0*sj;        
    YZ_pr0 = YZ_pr0 + pr0_sum' ;
%     case 'single'
%         %% YZ Plane
%     
%     x_0 = repmat( rot_xyz(:,1),1, length(YZ_j));
%         y_0 = repmat( rot_xyz(:,2),1, length(YZ_j));
%         z_0 = repmat( rot_xyz(:,3),1, length(YZ_j));
%         x_j = repmat( YZ_j(:,1),1, length(xyz))';
%         y_j = repmat( YZ_j(:,2),  1, length(xyz))';
%         z_j =  repmat( YZ_j(:,3),1,length(xyz))';
% 
%     Rj = sqrt(((x_j-x_0).^2) + ((y_j-y_0).^2) + ((z_j-z_0).^2));  
%     phi1=sum(uj(i)*exp(-1i*k*Rj)./Rj)/(2*pi);
%     pr0_sum=1i*phi1*2*pi*f*rho0*sj;        
%     YZ_pr0 = YZ_pr0 + pr0_sum'; 
end


end

switch Tracing
    case 'yes'
        array.performedTracing = 1;
end

pr0_data.MeshPressure = abs(totalPr0);
switch PlaneFields
    case 'all'
       pr0_data.patchGridXY.FaceVertexCData = abs(XY_pr0);
       pr0_data.patchGridYZ.FaceVertexCData = abs(YZ_pr0);
       pr0_data.patchGridZX.FaceVertexCData = abs(ZX_pr0);
       pr0_data.pressurePlaneField = 1;
%     case 'single'
%         pr0_data.patchGridYZ.FaceVertexCData = abs(YZ_pr0);
%         pr0_data.pressurePlaneField = 1;
       
end

intersect( all(~intersect,2), : ) = [];
detrimentalElements( all(~detrimentalElements,2), : ) = [];
healthyElements( all(~healthyElements,2), : ) = [];


array.intersect = intersect;
array.detrimentalElements = detrimentalElements';
array.healthyElements = healthyElements';
end

end
