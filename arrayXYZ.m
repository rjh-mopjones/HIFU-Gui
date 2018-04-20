
%arrayXYZ
function [array] = arrayXYZ(array)
%% get theta, phi and z from our data.

xyz_data=load(array.fileName)';
R = array.curv;

Xvalue = xyz_data(:,1);
Yvalue = xyz_data(:,2);
Zvalue = xyz_data(:,3);
theta = (asin(-Xvalue/R));
phi = (asin(Yvalue/R.*cos(theta)));
%% Variables;



%% Set up dummy axial piston
r=array.pRad;

 % number of points
np = array.pRes;
xg = linspace(-0.003, 0.003, np);
yg = linspace(-0.003, 0.003, np); 
[Xg,Yg] =  meshgrid(xg,yg);

x2 = reshape(Xg, np*np, 1);
y2 = reshape(Yg, np*np, 1);
z2 = (zeros(np*np,1)) - R;

xyz = [x2 y2 z2];

n= sqrt(xyz(:,1).^2+xyz(:,2).^2)>= r;
xyz(n,:)=[];

%% Rotation and translation
Mx_roll = [1 0 0;
        0 cos(array.roll) -sin(array.roll);
        0 sin(array.roll) cos(array.roll)];
    
    My_pitch = [cos(array.pitch) 0 sin(array.pitch);
        0 1 0;
        -sin(array.pitch) 0 cos(array.pitch)];
    Mz_yaw = [cos(array.yaw) -sin(array.yaw) 0;
        sin(array.yaw) cos(array.yaw) 0;
        0 0 1];
    
    
%% Rotation matrices
allArrayPoints = [];
for i = array.activeElements

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
   
   
allArrayPoints = [allArrayPoints; rot_xyz];

end
array.allPoints = allArrayPoints;
end