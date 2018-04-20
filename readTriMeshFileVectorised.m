
function [centroidCoords,patchData] = readTriMeshFileVectorised(fileName)


%% Read File and spew into a text array
fid = fopen(fileName);
tline = fgetl(fid);
tlines = cell(0,1);
while ischar(tline)
    tlines{end+1,1} = tline;
    tline = fgetl(fid);
end
fclose(fid);
%% Convert the numerical data from the Node section, sort
nodeLines = regexp(tlines,'Nodes|EndNodes');
nodeLinesBinary = ~cellfun(@isempty, nodeLines);
nodeIsolates = find(nodeLinesBinary);
nodeStringData = tlines(nodeIsolates(1)+2:nodeIsolates(2)-1);

% nodeNumData=[];
% n =1: length(nodeStringData);
% nodeNumStr = [];
% nodeNumStr(end+1) = nodeStringData(n);

nodeNumData = cell2mat(cellfun(@str2num,nodeStringData,'un',0));



% while n <= (length(nodeStringData))
%     lineConvert = str2num(nodeStringData{n});
%     nodeNumData(end+1,1:length(lineConvert)) = lineConvert;
%     n = n+1;
% end
 nodeNumData = sortrows(nodeNumData,1);
%% Convert the numerical data from the Element section, sort
elementLines = regexp(tlines,'Elements|EndElements');
elementLinesBinary = ~cellfun(@isempty, elementLines);
elementIsolates = find(elementLinesBinary);
elementStringData = tlines(elementIsolates(1)+2:elementIsolates(2)-1);

elementNumData = cell2mat(cellfun(@str2num,elementStringData,'un',0));


elementNumData = sortrows(elementNumData,1);
%% Match the element values with the node values and average for the centroids

fullnode_1 = elementNumData(:,6);
fullnode_2 = elementNumData(:,7);
fullnode_3 = elementNumData(:,8);
verts_A = zeros(length(elementNumData)*3,3);
verts_B = zeros(length(elementNumData)*3,3);
verts_C = zeros(length(elementNumData)*3,3);
vert_cell = cell(length(elementNumData),1);
centroidCoords = zeros(length(elementNumData),3);
verts = zeros(length(elementNumData)*3,3);



parfor n = 1:(length(elementNumData))
    node_1 = fullnode_1(n,1);
    node_2 = fullnode_2(n,1);
    node_3 = fullnode_3(n,1);
    
    xyz_node_1 = [nodeNumData(node_1,2:4); 0 0 0; 0 0 0];
    xyz_node_2 = [0 0 0;nodeNumData(node_2,2:4); 0 0 0];
    xyz_node_3 = [0 0 0; 0 0 0;nodeNumData(node_3,2:4)];
    

    vert_cell{n} = xyz_node_1 + xyz_node_2 + xyz_node_3;
    centroidCoords(n,:,end) = mean(xyz_node_1 + xyz_node_2 + xyz_node_3);

end


verts = cell2mat(vert_cell);
%% Patch the three nodes as vertices across the two spheres.

clear patchData
patchData.Vertices = verts;
patchData.Faces = reshape((1:length(verts)),3,length(verts)/3)';
patchData.FaceColor = 'c';
end







