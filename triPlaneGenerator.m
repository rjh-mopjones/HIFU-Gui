%triPlaneGenerator
% clear
% inputData = struct('Xmat',linspace(-2.5e-2,2.5e-2,10)' ,'Ymat',linspace(-5e-2,5e-2,10)' ...
%        , 'Zmat' ,linspace(-2.5e-2,2.5e-2,10)', 'plane' , 'xy','res',25);
% Xmat = inputData.Xmat;
% Ymat = inputData.Ymat;
% Zmat = inputData.Zmat;
% plane = inputData.plane;
%    
function [patchGrid,xyz_j] = triPlaneGenerator(Xmat,Ymat,Zmat,plane,array)

%% Plane Selection
if  strcmp(plane,'xy') == 1
    Amat = Xmat;
    Bmat = Ymat;
    orig = array.focalPoint(:,3);
elseif  strcmp(plane,'yx') == 1
    Amat = Ymat;
    Bmat = Xmat;
elseif  strcmp(plane,'yz') == 1
    Amat = Ymat;
    Bmat = Zmat;
    orig = array.focalPoint(:,1);
elseif  strcmp(plane,'zy') == 1
    Amat = Zmat;
    Bmat = Ymat;
elseif  strcmp(plane,'zx') == 1
    Amat = Zmat;
    Bmat = Xmat;
    orig = array.focalPoint(:,2);
elseif  strcmp(plane,'xz') == 1
    Amat = Xmat;
    Bmat = Zmat;
    
end

%% Mesh the two data inputs to create a grid
[Aj,Bj] = meshgrid(Amat,Bmat);


%% Reshape the data into a manipulatable size
aG = reshape(Aj, length(Amat)*length(Bmat),1);
bG = reshape(Bj, length(Bmat)*length(Amat),1);
cG = ones(length(Bmat)*length(Amat),1).*orig;

%% Interweave the two matrices
aG_rs = reshape(aG,length(Bmat),length(Amat))';
bG_rs = reshape(bG,length(Bmat),length(Amat))';

aGbG = insertrows(aG_rs,bG_rs,1:length(Amat))';

%% Rearrange the data into readable groups of three nodes


a = 1: (size(aGbG,2)-3);
v = [];

for m = a(mod(a,2)==1)
    for n = 1: (size(aGbG,1)-1)
        v_incr1= [aGbG(n,m),aGbG(n,m+1);
%             aGbG(n+1,m),aGbG(n+1,m+1);
            aGbG(n+1,m+2),aGbG(n+1,m+3);
            aGbG(n,m+2),aGbG(n,m+3)];
        v(end+1:end+3,1:2)= v_incr1;
        v_incr2= [aGbG(n,m),aGbG(n,m+1);
            aGbG(n+1,m),aGbG(n+1,m+1);
            aGbG(n+1,m+2),aGbG(n+1,m+3)];
%             aGbG(n,m+2),aGbG(n,m+3)];
        v(end+1:end+3,1:2)= v_incr2;
    end
end

%% Patch the three nodes as vertices
patchGrid.Vertices = [];
%% Plane decides what order xyz_j is computed into
if  strcmp(plane,'xy') == 1
Xv = (v(:,1));
Yv = (v(:,2));
Zv = ones(length(v),1).*orig;


elseif  strcmp(plane,'yx') == 1
Xv = (v(:,2));
Yv = (v(:,1));
Zv =  ones(length(v),1).*orig;


elseif  strcmp(plane,'yz') == 1
Xv =  ones(length(v),1).*orig;
Yv = (v(:,1));
Zv = (v(:,2));


elseif  strcmp(plane,'zy') == 1
Xv =  ones(length(v),1).*orig;
Yv = (v(:,2));
Zv = (v(:,1));


elseif  strcmp(plane,'zx') == 1
Xv = (v(:,1));
Yv =  ones(length(v),1).*orig;
Zv = (v(:,2));


elseif  strcmp(plane,'xz') == 1
Xv = (v(:,2));
Yv =  ones(length(v),1).*orig;
Zv = (v(:,1));


end

clear patchGrid
patchGrid.Vertices = [Xv,Yv,Zv];
patchGrid.Faces = reshape((1:length(v)),3,length(v)/3)';
patchGrid.FaceColor = 'c';
patchGrid.EdgeColor = 'none';
patchGrid.LineStyle = 'none';

%% Average to get centroids

n=0;
ctr=[];
while n <= (length(v)-3)
    ctr_inc = mean(v(1+n:3+n,1:2),1);
    ctr(end+1,1:length(ctr_inc)) = ctr_inc;
    n = n + 3;
end

%% Plane decides what order xyz_j is computed into
if  strcmp(plane,'xy') == 1
Xj = (ctr(:,1));
Yj = (ctr(:,2));
Zj = ones(length(ctr),1).*orig;
elseif  strcmp(plane,'yx') == 1
Xj = (ctr(:,2));
Yj = (ctr(:,1));
Zj = ones(length(ctr),1).*orig;
elseif  strcmp(plane,'yz') == 1
Xj = ones(length(ctr),1).*orig;
Yj = (ctr(:,1));
Zj = (ctr(:,2));
elseif  strcmp(plane,'zy') == 1
Xj = ones(length(ctr),1).*orig;
Yj = (ctr(:,2));
Zj = (ctr(:,1));
elseif  strcmp(plane,'zx') == 1
Xj = (ctr(:,1));
Yj = ones(length(ctr),1).*orig;
Zj = (ctr(:,2));
elseif  strcmp(plane,'xz') == 1
Xj = (ctr(:,2));
Yj = ones(length(ctr),1).*orig;
Zj = (ctr(:,1));   
end


xyz_j = [Xj,Yj,Zj];

end
% patch(patchGrid);
% 
% Vt = [aGbG(1,1),aGbG(1,2);
%     aGbG(2,1),aGbG(2,2);
%     aGbG(2,3),aGbG(2,4)
% %     aGbG(1,3),aGbG(1,4)];
% % 
% % figure
% % plot(Vt(:,1),Vt(:,2),'k.');
% % xlim([-2.5e-2 2.5e-2])
% % ylim([-5e-2,5e-2])
