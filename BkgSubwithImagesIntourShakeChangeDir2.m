%%%%%%%%%%%
%%%%%%%%%%%
%Calc Spatio-Temporal bkg sub. To calc only Spatial bkg sub put radius
%region to 0, to compute the AND, use LunchComparison script in the
%../comparisonTools dir
foldersList = {'badminton', 'boulevard', 'sidewalk', 'traffic'};
nInitFrameList = [800, 790, 800, 900];
nEndFrameList = [1150, 2500, 1200, 1570];

if  matlabpool('size') == 0
    matlabpool(2);
end
%%

foldersList2 = {'badminton/alignedBadminton/', 'boulevard/alignedBoulevard/', 'sidewalk/alignedSidewalk/', 'traffic/alignedTraffic/'};
%foldersList2 = {'badminton/input/in00', 'boulevard/input/in00', 'sidewalk/input/in00', 'traffic/input/in00'};
binRatio = 16;
imgExtension = 'jpg';
thresholdBhatVec = [.1,.2];%,.3,.4,.5,.6,.7];%,.75,.76,.77,.8,.9];
windowSize = [690];
threshOffsetIll = [1.0];
offsetFromLearningFrame=100;
altraString = '_.5_0';
curvididx = [3,1,2,4];
parfor curvid = 1:4
    
    curNameVid = curvididx(curvid);
    withIllumCorrection =true;
    nLearningFrame = nInitFrameList(curNameVid);
    numFrames  = nEndFrameList(curNameVid);
    nameCurFolder = foldersList{curNameVid};
    nameCurFolder2 = foldersList2{curNameVid};
    
    for curThresh = 1:length(thresholdBhatVec)
        for curIllThreshIdx = 1:length(threshOffsetIll)
            for curWinSizeIdx = 1:length(windowSize)
                for radiusRegion = [0,6]
                    %for k = 1:2
                                            if radiusRegion == 0
                                                withIllumCorrection = false;
                                                curIllThresh = 0.0;
                                            else
                                                withIllumCorrection = true
                                                curIllThresh = threshOffsetIll(curIllThreshIdx);
                                            end
%                         if k == 1
%                             withIllumCorrection = false;
%                             curIllThresh = 0.0;
%                         else
%                             withIllumCorrection = true
%                             curIllThresh = threshOffsetIll(curIllThreshIdx);
%                         end
                        curWinSize = windowSize(curWinSizeIdx);
                        paramString = ['Align',altraString,int2str(binRatio),'_',int2str(radiusRegion),'_',num2str(thresholdBhatVec(curThresh)),'_',num2str(curIllThresh),'_',num2str(curWinSize)];
                        
                        if curNameVid == 1 && curWinSize > 700
                            curWinSize =700;
                        elseif curNameVid == 2 && curWinSize > 690
                            curWinSize =690;
                        elseif curNameVid == 3 &&curWinSize > 700
                            curWinSize =700;
                        elseif curNameVid == 4 && curWinSize > 800
                            curWinSize =800;
                        else
                            curWinSize = windowSize(curWinSizeIdx);
                        end
                        imgBaseName = ['/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/',nameCurFolder2];
                        
                        namePathSave = ['./res',paramString,'/histRGBbkg',nameCurFolder,'Align.mat'];
                        namePathOut = ['./ChangeDir',date,'/res',paramString,'/',nameCurFolder];
                        
                        curImgRGB = gpuArray(imread([imgBaseName, '0001.' ,imgExtension]));
                        sizeImage = [size(curImgRGB,1), size(curImgRGB,2)];
                        grayHistogram = gpuArray(zeros(sizeImage(1),sizeImage(2), 256/binRatio));
                        
                        baseNumbering = 1;
                        if withIllumCorrection
                            lastMedians = gpuArray(zeros(windowSize,1));
                            counter = 1;
                        end
                        %% Learning Stage
                        k = [5,5];h = fspecial('gaussian', k, .5);%MotionBlur = imfilter(I,h);
                        [XM,YM] = meshgrid(1:size(grayHistogram,2),1:size(grayHistogram,1));
                        XM = uint32(XM);YM = uint32(YM);
                        for curFrame = 1:1:nLearningFrame-offsetFromLearningFrame
                            tic
                            curNumber = getFrameNumber( baseNumbering,curFrame );
                            
                            curImgGray = gpuArray(rgb2gray(imread([imgBaseName, curNumber, '.' ,imgExtension])));
                            
                            idxRGB = floor((curImgGray+binRatio-1)/binRatio);
                            %iG =sub2ind(size(grayHistogram),YM(:),XM(:),uint32(idxRGB(:)));
                            iG = 1 + (YM(:)-1)*1 + (XM(:)-1)*size(grayHistogram,1) ...
                                + (uint32(idxRGB(:))-1)*(size(grayHistogram,1)*size(grayHistogram,2));
                            
                            grayHistogram(iG) = grayHistogram(iG) + 1;
                            if withIllumCorrection
                                if curFrame >=  nLearningFrame-offsetFromLearningFrame - curWinSize
                                    lastMedians(counter) = median(double(curImgGray(:)));
                                    counter = counter + 1;
                                end
                            end
                            toc;
                            disp(curFrame);
                        end
                        
                        %% BkgSub
                        [XM,YM] = meshgrid(1:size(grayHistogram,2),1:size(grayHistogram,1));
                        XM = uint32(XM); YM = uint32(YM);
                        se = strel('disk',3); se2 = strel('disk',5);
                        
                        grayIntourHistogram = gpuArray(zeros(sizeImage(1),sizeImage(2), 256/binRatio));
                        curIntourHistogram = gpuArray(zeros(sizeImage(1),sizeImage(2), 256/binRatio));
                        
                        for curFrame = nLearningFrame-offsetFromLearningFrame:numFrames
                            tic
                            disp(curFrame);
                            disp(paramString);
                            curIntourHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
                            maxValHistR = mean(grayHistogram,3);
                            curNumber = getFrameNumber( baseNumbering,curFrame );
                            
                            curImgGray = rgb2gray(imread([imgBaseName, curNumber, '.' ,imgExtension]));
                            if withIllumCorrection
                                comparMediane = median(lastMedians);
                                curIllum = median(double(curImgGray(:)));
                                
                                offset = comparMediane - curIllum;
                                curImgGray = curImgGray + round(curIllThresh*offset);
                                
                                lastMedians = [lastMedians(2:end);median(double(curImgGray(:)))];
                            end
                            idxRGB = floor(((curImgGray)+binRatio-1)/binRatio);
                            G = idxRGB(:,:);
                            
                            for offsetRow = -radiusRegion:radiusRegion
                                for offsetCol = -radiusRegion:radiusRegion
                                    if offsetRow < 0
                                        offsetRowOffsetABegin   = 1;
                                        offsetRowOffsetAEnd     = sizeImage(1) + offsetRow;
                                        offsetRowOffsetBBegin   = -offsetRow+1;
                                        offsetRowOffsetBEnd     = sizeImage(1);
                                    else
                                        offsetRowOffsetBBegin   = 1;
                                        offsetRowOffsetBEnd     = sizeImage(1) - offsetRow;
                                        offsetRowOffsetABegin   = offsetRow+1;
                                        offsetRowOffsetAEnd     = sizeImage(1);
                                    end
                                    if offsetCol < 0
                                        offsetColOffsetABegin   = 1;
                                        offsetColOffsetAEnd     = sizeImage(2) + offsetCol;
                                        offsetColOffsetBBegin   = -offsetCol+1;
                                        offsetColOffsetBEnd     = sizeImage(2);
                                    else
                                        offsetColOffsetBBegin   = 1;
                                        offsetColOffsetBEnd     = sizeImage(2) - offsetCol;
                                        offsetColOffsetABegin   = offsetCol+1;
                                        offsetColOffsetAEnd     = sizeImage(2);
                                    end
                                    idxMask = false(size(curImgGray));
                                    idxMask(offsetRowOffsetBBegin:offsetRowOffsetBEnd, offsetColOffsetBBegin:offsetColOffsetBEnd) = true;
                                    
                                    iG = 1 + (YM(idxMask)-1)*1 + (XM(idxMask)-1)*size(grayHistogram,1) ...
                                        + (uint32(G(idxMask))-1)*(size(grayHistogram,1)*size(grayHistogram,2));
                                    %iG = sub2ind(size(curIntourHistogram),YM((idxMask)),XM(idxMask),uint32(G(idxMask)));
                                    curIntourHistogram(iG) = curIntourHistogram(iG) + 1;
                                    %
                                    %a = grayIntourHistogram(offsetRowOffsetABegin:offsetRowOffsetAEnd, offsetColOffsetABegin:offsetColOffsetAEnd,:);
                                    %b = grayHistogram(offsetRowOffsetBBegin:offsetRowOffsetBEnd, offsetColOffsetBBegin:offsetColOffsetBEnd,:);
                                    grayIntourHistogram(offsetRowOffsetABegin:offsetRowOffsetAEnd, offsetColOffsetABegin:offsetColOffsetAEnd,:) = ...
                                        grayIntourHistogram(offsetRowOffsetABegin:offsetRowOffsetAEnd, offsetColOffsetABegin:offsetColOffsetAEnd,:)+...
                                        grayHistogram(offsetRowOffsetBBegin:offsetRowOffsetBEnd, offsetColOffsetBBegin:offsetColOffsetBEnd,:);
                                end
                            end
                            grayIntourHistogram = grayIntourHistogram./ repmat(sum(grayIntourHistogram,3),[1,1,size(grayIntourHistogram,3)]);
                            curIntourHistogram = curIntourHistogram./ repmat(sum(curIntourHistogram,3),[1,1,size(curIntourHistogram,3)]);
                            scoresBhattG = 1 - sum(sqrt(grayIntourHistogram.* curIntourHistogram),3);
                            
                            %%
                            bkgMIDX =  scoresBhattG<=thresholdBhatVec(curThresh);
                            
                            forgM = gather(~bkgMIDX);
                            
                            forgMT = imerode(forgM,se); forgMT = imdilate(forgMT,se);
                            
                            saveImageForVideo( uint8(255*forgM), namePathOut, curFrame);
                            %updateBkg background pixels
                            idxMask = ~forgMT(:);
                            %iG = sub2ind(size(grayHistogram),YM((idxMask)),XM(idxMask),uint32(G(idxMask)));
                            iG = 1 + (YM(idxMask)-1)*1 + (XM(idxMask)-1)*size(grayHistogram,1) ...
                                + (uint32(G(idxMask))-1)*(size(grayHistogram,1)*size(grayHistogram,2));
                            grayHistogram(iG) = grayHistogram(iG) + 1;
                            
                            %updateBkg foreground pixels
                            idxMask = forgMT(:);
                            %iG = sub2ind(size(grayHistogram),YM((idxMask)),XM(idxMask),uint32(G(idxMask)));
                            iG = 1 + (YM(idxMask)-1)*1 + (XM(idxMask)-1)*size(grayHistogram,1) ...
                                + (uint32(G(idxMask))-1)*(size(grayHistogram,1)*size(grayHistogram,2));
                            grayHistogram(iG) = grayHistogram(iG) + .5;
                            toc
                        end
                   % end
                end
            end
        end
    end
end
