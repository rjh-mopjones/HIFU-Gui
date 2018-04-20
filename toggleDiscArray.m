%toggleDiscArray
function [patches,blackRays,redRays] = toggleDiscArray(array)


xyz_data=load(array.fileName)';
R = array.curv;

Xvalue = xyz_data(:,1);
Yvalue = xyz_data(:,2);
Zvalue = xyz_data(:,3);
theta = (asin(-Xvalue/R));
phi = (asin(Yvalue/R.*cos(theta)));



% neutralElements = [];
% detrimentalElements = [];

% array.normalRays = [array.centroids(:,1)-array.centroids(:,1),array.centroids(:,2)-array.centroids(:,2),array.centroids(:,3)./array.centroids(:,3)];

center = [0 0 0-array.curv];
normal = [0 0 1];
radius = array.pRad;
transMat = array.transMat;

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
    focalPoint = [0 0 0] - movingCenter;
end 
patches={};
redRays={};
blackRays={};
for i = 1:length(array.allElements)
    
    c = [.5 .5  .5];
   
            if nonzeros(i == array.deactiveElements) == 1
                c = 'b';
            end
  
            if nonzeros(i == array.detrimentalElements) == 1
                c = 'r';
            end
        
 
%% Rotating elements
    M_phi = [1 0 0;
      0 cos(phi(i,:)) -sin(phi(i,:));
      0 sin(phi(i,:)) cos(phi(i,:))]; % rotation matrix around the x axis

M_theta = [cos(theta(i,:)) 0 sin(theta(i,:)); % rotation matrix around the y axis
       0 1 0;
       -sin(theta(i,:)) 0 cos(theta(i,:))];
rot_center =M_theta*M_phi*center';
rot_center = rot_center';
    
    rot_Normal = M_theta*M_phi*normal';
rot_Normal = rot_Normal';
 
    
    rot_center = ((Mx_roll * My_pitch * Mz_yaw * rot_center'))';
    rot_Normal = ((Mx_roll * My_pitch * Mz_yaw * rot_Normal'))';
   
   rot_center = rot_center + transMat;
   %rot_Normal = rot_Normal+transMat;

    if array.fixedFocal == 0
    rot_center = rot_center - movingCenter + [0 0 -array.curv];
    end
    
   
    
            if nonzeros(i == array.detrimentalElements) == 1           
                redRays{end+1}= quiver3(rot_center(:,1),rot_center(:,2),rot_center(:,3),...
                rot_Normal(:,1),rot_Normal(:,2),rot_Normal(:,3) ,0.3,'LineStyle', '-','LineWidth',0.01,'Color','r');
            end
            if nonzeros(i == array.healthyElements) == 1
                hold on
               blackRays{end+1}=quiver3(rot_center(:,1),rot_center(:,2),rot_center(:,3),...
                rot_Normal(:,1),rot_Normal(:,2),rot_Normal(:,3) ,0.3,'LineStyle', ':','LineWidth',0.01,'Color','k');
            end
             
            
            
            
 
    
    
    

    theta_2=0:0.75:2*pi;
    v=null(rot_Normal);
    points=repmat(rot_center',1,size(theta_2,2))+radius*(v(:,1)*cos(theta_2)+v(:,2)*sin(theta_2));
    hold on
    patches{end+1}=fill3(points(1,:),points(2,:),points(3,:),c);
    
    
end
patches = patches';
blackRays = blackRays';
redRays = redRays';

for i = 1:length(blackRays)
blackRays{i}.Visible = 'off';
end
for i = 1:length(redRays)
redRays{i}.Visible = 'off';
end
for i = 1:length(patches)
patches{i}.Visible = 'off';
end
end
