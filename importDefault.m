%importDefault
function [array,constants] = importDefault()

array=struct();
array.pRes= 6;
array.pRad= 0.003;
array.fileName = 'xyz_rand_array_v1.dat';
array.curv = 0.18;
array.pitch = 0;
array.yaw = 0;
array.roll = 0;
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
array.testroids = [];
theta = (asin(array.defaultXvalue/array.curv));
phi = (asin(array.defaultYvalue/array.curv.*cos(theta)));
array.fullAnalysis = 1;
array.validPlanes = 0;
% array.normalRays = [array.centroids(:,1)-array.centroids(:,1),array.centroids(:,2)-array.centroids(:,2),array.centroids(:,3)./array.centroids(:,3)];

for i = 1 : length(array.centroids)
%% Rotating elements
    M_theta = [1 0 0;
        0 cos(theta(i,:)) -sin(theta(i,:));
        0 sin(theta(i,:)) cos(theta(i,:))]; % rotation matrix around the y axis
    
    M_phi = [cos(phi(i,:)) 0 sin(phi(i,:)); % rotation matrix around the x axis
        0 1 0;
        -sin(phi(i,:)) 0 cos(phi(i,:))];
    
    rot_xyz =M_theta*M_phi*array.center';
    rot_xyz = rot_xyz';
    
    rot_Normal =M_theta*M_phi*array.centerNormal';
    rot_Normal = rot_Normal';
    
    Mx_roll = [1 0 0;
        0 cos(array.roll) -sin(array.roll);
        0 sin(array.roll) cos(array.roll)];
    
    My_pitch = [cos(array.pitch) 0 sin(array.pitch);
        0 1 0;
        -sin(array.pitch) 0 cos(array.pitch)];
    Mz_yaw = [cos(array.yaw) -sin(array.yaw) 0;
        sin(array.yaw) cos(array.yaw) 0;
        0 0 1];
    
    rot_xyz = ((Mx_roll * My_pitch * Mz_yaw * rot_xyz'))';
    array.testroids(end+1,1:3) = rot_xyz;
    
    rot_Normal = ((Mx_roll * My_pitch * Mz_yaw * rot_Normal'))';
    array.normalRays(end+1,1:3) = rot_Normal;
end
constants.rho0 = 1000;                                           %% density of the medium
constants.uj   = ones(length(array.centroids),1);              %% magnitude of normal velocity of piston
constants.c    = 1500;                                          %% local speed of sound
constants.f    = 1E6    ;                                    %% Frequency
constants.w    = 2*pi*constants.f;                           %% Rotational speed
constants.k    = (constants.w/constants.c);                       %% wave number



end