function [array] = streeringTimeReversal(array,constants,focalPoint)

 %% Default values
[array] = arrayXYZ(array);

% rho0 = constants.rho0;          %% density of the medium
% uj   = constants.uj;              %% magnitude of normal velocity of piston
% c    = constants.c;           %% local speed of sound
% f    = constants.f;        %% Frequency
% w    = constants.w;        %% Rotational speed
k    = constants.k;        %% wave number
%% point source
pointSource = -focalPoint;

pointSource = repmat(pointSource, length(array.allPoints),1);
%% Complex pressure
Rj = sqrt(((pointSource(:,1)-array.allPoints(:,1)).^2) + ((pointSource(:,2)-array.allPoints(:,2)).^2) + ((pointSource(:,3)-array.allPoints(:,3)).^2));

pr0 = exp(-1i*k*Rj)./Rj;

%% get the mean pressure


numPerElement = length(array.allPoints)/length(array.activeElements);
avPr0 = [];
for n = 0  :(length(array.activeElements)-1)
    av_incr = mean(pr0(((numPerElement*n)+1):(numPerElement*(n+1))));
    avPr0(end+1) = av_incr;
        
end
avPr0 = avPr0';
%% Conjugate the average pressure
conjAvPr0 = conj(avPr0);

%% Get the absolute value of this conjugate
% absConj = abs(conjAvPr0);


normPr0 = conjAvPr0./max(conjAvPr0);

array.steerVector = normPr0;
array.performedPhasing = 1;
end


















