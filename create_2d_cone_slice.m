get_radius_profiles

%% 
%  close all

voxScale = 4; % Scale up factor on image for FDTD
writeLarge = 0;

%%% Switch to use profiles from CT
% Parameters from oliver
% interCone = 356.79/voxSize;
% interConeSD = 24.31/voxSize;
% use3Dintercone = 1;
% 
% outerCornea = 104.84/voxSize;
% outerCorneaSD = 6.59/voxSize;
% 
% epiCornea = 32.68/voxSize;
% epiCorneaSD = 2.21/voxSize;

% For display
nPlot = 2;
tText = 'Mean'; %'-2 SD'; 'Mean';

%%% 1 is closest but can currently intrude as intercone defined as radius not distance
    coneStepForIntercone = 2;    

SDMult = 0;
figure

tipOffset = 30; 
reduceTips = 1; 
bufferLength = 10;

useSlopedIntercone = 0;

% Set up parameters
% Labels
% outerValue = 0;
% innerValue = 1;
% coneValue = 5;
% outerCorneaValue = 4;
% epicorneaValue = 3;
% interconeValue = 2;

% RI values
outerValue = 1.33;
innerValue = 1.34;
coneValue = NaN;
outerCorneaValue = 1.5;
epicorneaValue = 1.53;
interconeValue = 1.47;

if reduceTips
    bufferOffset = 9;
else
    bufferOffset = 10;
end

if bufferOffset > bufferLength
    error('buffer offset to large')
end

% Change to ring height for cone length
coneLengthToUse = (bufferLength - bufferOffset) + mean(lengthsToPlanes(:,2)) + std(lengthsToPlanes(:,2))*SDMult;

interconeLengthToUse = (bufferLength - bufferOffset) + mean(lengthsToPlanes(:,1)) + std(lengthsToPlanes(:,1))*SDMult;

outerCorneaLengthToUse = (bufferLength - bufferOffset) + mean(lengthsToPlanes(:,3)) + std(lengthsToPlanes(:,3))*SDMult - coneLengthToUse;

epicorneaLengthToUse = (bufferLength - bufferOffset) + mean(lengthsToPlanes(:,4)) + std(lengthsToPlanes(:,4))*SDMult - coneLengthToUse - outerCorneaLengthToUse;

restretchLength_cone = ceil(max(lengthsToPlanes(:,2))/100)*100;

restretchLength_cornea = ceil((max(lengthsToPlanes(:,4))-min(lengthsToPlanes(:,3)))/10)*10;

[meanStretchedCone, stdStretchedCone, coneXRef] = restretchProfile(coneAverage(:,bufferOffset+1:end), numCones, depthTests(bufferLength+1:end), ...
        coneRefDiameter, ones(numCones,1), ceil(lengthsToPlanes(:,2)), mean(coneRefDiameter), coneLengthToUse, restretchLength_cone, 0, 0, 0);

% Cone in cone now stretched to full cone length
    % Doesn't guarantee that cone tips are x-aligned but should match bases well...
    %%% Add in alignment for profiles
[meanStretchedCinC, stdStretchedCinC] = restretchProfile(cInCAverage(:,bufferLength+1:end), numCones, depthTests(bufferLength+1:end), ...
        coneRefDiameter, ones(numCones,1), ceil(lengthsToPlanes(:,2)), mean(coneRefDiameter), coneLengthToUse, restretchLength_cone, 0, 1, 1);

% normalised from top plane of exposed intercone, would be good to also normalize to base plane of exposed intercone
    % Shift to distance from cone - more sensible given it can start at different heights, which have different radiuses.
    %%% Add in alignment for profiles
[meanStretchedExposedIntercone, stdStretchedExposedIntercone] = restretchProfile(exposedInterconeAverage(:,bufferLength+1:end), numCones, depthTests(bufferLength+1:end), ...
        coneRefDiameter, ones(numCones,1), ceil(lengthsToPlanes(:,2)), mean(coneRefDiameter), coneLengthToUse, restretchLength_cone, 0, 0, 1);

% Will switch this to be distance to cone, then it can't interfere
[meanStretchedInternalIntercone, stdStretchedInternalIntercone] = restretchProfile(internalInterconePaths(:,bufferLength+1:end,coneStepForIntercone), numCones, depthTests(bufferLength+1:end), ...
        coneRefDiameter, ones(numCones,1), ceil(lengthsToPlanes(:,2)), mean(coneRefDiameter), coneLengthToUse, restretchLength_cone, 1, 1, 0);

% epicornea cone stretch to epicornea length
    %%% Add in alignment for profiles
[meanStretchedEpicorneaInner, stdStretchedEpicorneaInner, corneaXRef] = restretchProfile(epicorneaInnerAverage(:,bufferLength+1:end), numCones, depthTests(bufferLength+1:end), ...
        coneRefDiameter, floor(lengthsToPlanes(:,3)), ceil(lengthsToPlanes(:,4)), mean(coneRefDiameter), epicorneaLengthToUse, restretchLength_cornea, 0, -1, 1);

figure;
subplot(1,2,1); hold on
errorbar(coneXRef, meanStretchedCone, stdStretchedCone);
errorbar(coneXRef, meanStretchedCinC, stdStretchedCinC);
errorbar(coneXRef, meanStretchedExposedIntercone, stdStretchedExposedIntercone);
errorbar(coneXRef, meanStretchedInternalIntercone, stdStretchedInternalIntercone);

if reduceTips
    %%% Tried interpolation but didn't work well
    % decided to add a step with half radius at top so it's not too blunt

    % reduce cone tip
    goodConeInds = find(~isnan(meanStretchedCone));
    
    % Put in profile - just do nearest for std
    meanStretchedCone(goodConeInds(1)-1) = meanStretchedCone(goodConeInds(1))/2;
    stdStretchedCone(goodConeInds(1)-1) = stdStretchedCone(goodConeInds(1));
    
    plot(coneXRef(goodConeInds(1)-1), meanStretchedCone(goodConeInds(1)-1), 'mx');
    
    % Reduce CinC tip
    goodCinCInds = find(~isnan(meanStretchedCinC));
    
    % refactor so interpolation is on cone around x-axis   
    % Put in profile - just do nearest for std
    meanStretchedCinC(goodCinCInds(1)-1) = meanStretchedCinC(goodCinCInds(1))/2;
    stdStretchedCinC(goodCinCInds(1)-1) = stdStretchedCinC(goodCinCInds(1));
    
    plot(coneXRef(goodCinCInds(1)-1), meanStretchedCinC(goodCinCInds(1)-1), 'mx');
end

subplot(1,2,2); hold on
errorbar(corneaXRef, meanStretchedEpicorneaInner, stdStretchedEpicorneaInner);

if reduceTips
    % reduce epicornea cone tip
    goodEpicorneaInds = find(~isnan(meanStretchedEpicorneaInner));
    
    % Put in profile - just do nearest for std
    meanStretchedEpicorneaInner(goodEpicorneaInds(end)+1) = meanStretchedEpicorneaInner(goodEpicorneaInds(end))/2;
    stdStretchedEpicorneaInner(goodEpicorneaInds(end)+1) = stdStretchedEpicorneaInner(goodEpicorneaInds(end));
    
    plot(corneaXRef(goodEpicorneaInds(end)+1), meanStretchedEpicorneaInner(goodEpicorneaInds(end)+1), 'mx');
end

% Get profiles to use
coneProfileToUse =  meanStretchedCone + stdStretchedCone*SDMult;

CinCProfileToUse =  meanStretchedCinC + stdStretchedCinC*SDMult;

exposedInterconeProfileToUse = meanStretchedExposedIntercone + stdStretchedExposedIntercone*SDMult;

internalInterconeProfileToUse = meanStretchedInternalIntercone + stdStretchedInternalIntercone*SDMult;

epicorneaProfileToUse = meanStretchedEpicorneaInner + stdStretchedEpicorneaInner*SDMult;

% Make slice to fit dimensions
topEpicornea = tipOffset + ceil(coneLengthToUse) + ceil(outerCorneaLengthToUse) + ceil(epicorneaLengthToUse);

sliceSize = round([3*max(coneProfileToUse), topEpicornea + tipOffset]);

slice = zeros(sliceSize(1), sliceSize(2));

%%% Continue from here then convert to 3D
    %%% Need to update profile placment (exposed, internal intercone, epicornea cone)

slice(:) = outerValue;

slice(:,1:tipOffset) = innerValue;

passedExposedCone = 0;
passedConeTip = 0;

for i = 1:sliceSize(2)

    % Place cone profile
    if i > tipOffset & i <= coneLengthToUse + tipOffset

        if ~isnan(coneProfileToUse(i-tipOffset))
            passedConeTip = 1;
        end 

        if passedConeTip
            % avoids gap at end
            if isnan(coneProfileToUse(i-tipOffset)) 
               coneProfileToUse(i-tipOffset) = coneProfileToUse(i-tipOffset-1); 
            end
            
            xPosTop = round(sliceSize(1)/2 + coneProfileToUse(i-tipOffset));
            xPosBottom = round(sliceSize(1)/2 - coneProfileToUse(i-tipOffset));
    
            % Fill between top and bottom
            if ~isnan(coneValue)
                slice(xPosBottom:xPosTop, i) = coneValue;
            else
                % From oliver
                % rescale relative diameter to be 80
                tempRI = ((xPosBottom:xPosTop)-sliceSize(1)/2)/coneProfileToUse(i-tipOffset)*80;
                tempRI = 1.52-0.000004914*tempRI.^2;
    
                slice(xPosBottom:xPosTop, i) = tempRI;
            end
    
            % Place inner value
            slice(xPosTop+1:end, i) = innerValue;         
            slice(1:xPosBottom-1, i) = innerValue;
        end

        % Place exposed cone and other cone profile.
        if i > interconeLengthToUse + tipOffset

            if ~isnan(exposedInterconeProfileToUse(i-tipOffset))
                % Given exposed cone fill out too its level
                xPosInterconeTop = round(sliceSize(1)/2 + exposedInterconeProfileToUse(i-tipOffset));
                xPosInterconeBottom = round(sliceSize(1)/2 - exposedInterconeProfileToUse(i-tipOffset));

                slice(xPosTop+1:xPosInterconeTop, i) = interconeValue;  
                slice(xPosInterconeBottom:xPosBottom-1, i) = interconeValue;

                % For some the profiles don't start until some distance after the planes...
                passedExposedCone = 1;
            elseif passedExposedCone

                % avoids gap at end
                if isnan(internalInterconeProfileToUse(i-tipOffset))
                   internalInterconeProfileToUse(i-tipOffset) = internalInterconeProfileToUse(i-tipOffset-1); 
                end

                %%% Will need to modify when based on distance rather than radius...

                % Fill intercone out to adjacent cone level
                xPosInterconeTop = round(sliceSize(1)/2 + internalInterconeProfileToUse(i-tipOffset));
                xPosInterconeBottom = round(sliceSize(1)/2 - internalInterconeProfileToUse(i-tipOffset));

                slice(xPosTop+1:xPosInterconeTop, i) = interconeValue;  
                slice(xPosInterconeBottom:xPosBottom-1, i) = interconeValue;

                % Add in adjacent cone
                if ~isnan(coneValue)
                    slice(xPosInterconeTop+1:end, i) = coneValue;         
                    slice(1:xPosInterconeBottom-1, i) = coneValue;
                else
                    % Copy in RI from current cone
                    slice(xPosInterconeTop+1:end, i) = (tempRI(1:sliceSize(1)-(xPosInterconeTop)));         
                    slice(1:xPosInterconeBottom-1, i) = fliplr(tempRI(1:xPosInterconeBottom-1));
                end
            end
        end

        % Place cone in cone profile
        if ~isnan(CinCProfileToUse(i-tipOffset))
            xPosCinCTop = round(sliceSize(1)/2 + CinCProfileToUse(i-tipOffset));
            xPosCinCBottom = round(sliceSize(1)/2 - CinCProfileToUse(i-tipOffset));

            slice(xPosCinCBottom:xPosCinCTop, i) = outerCorneaValue;
        end
    end

    % Place outer cornea value
    if i > coneLengthToUse + tipOffset & i <= coneLengthToUse + tipOffset + outerCorneaLengthToUse
        slice(:, i) = outerCorneaValue;
    end    

    % Place epicornea value
    if i > coneLengthToUse + tipOffset + outerCorneaLengthToUse & ...
            i <= coneLengthToUse + tipOffset + outerCorneaLengthToUse + epicorneaLengthToUse
        
        slice(:, i) = epicorneaValue;

        if ~isnan(epicorneaProfileToUse(i-round(coneLengthToUse + tipOffset + outerCorneaLengthToUse)))
            xPosCorneaTop = round(sliceSize(1)/2 + epicorneaProfileToUse(i-round(coneLengthToUse + tipOffset + outerCorneaLengthToUse)));
            xPosCorneaBottom = round(sliceSize(1)/2 - epicorneaProfileToUse(i-round(coneLengthToUse + tipOffset + outerCorneaLengthToUse)));

            slice(xPosCorneaBottom:xPosCorneaTop, i) = outerCorneaValue;
        end
    end
end

figure;
imshow((slice'-1.45)/(1.54-1.45))

if 0
    subplot(1,3,nPlot)
    if ~isnan(coneValue)
        imshow(slice'/(max(slice(:))+1))
    else
        imshow((slice'-1.45)/(1.54-1.45))
    end
        title(tText);
        
    largerImg = imresize(slice, voxScale,'nearest'); 
    
    if writeLarge 
        currentDirectory = pwd; 
        cd('/Users/gavintaylor/Desktop')
    
        warning('check names are correct')
    
        writematrix(largerImg,'500_average_cone_0_sd.csv') 
        cd(pwd)

        figure;
        imshow((largerImg'-1.45)/(1.54-1.45))
    end
end