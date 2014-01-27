
imgBaseNameTrain = '/home/andrea/Scrivania/SABS/Train/MPEG4_40kbps/MPEG4_';
imgExtension = 'png';
curImgRGB = imread([imgBaseNameTrain, '0001.' ,imgExtension]);

%
%frameRate = videoObj.FrameRate;
sizeImage = [size(curImgRGB,1), size(curImgRGB,2)];
numFrames = 599;
videoOffset = 2;
binRatio = 16;
nLearningFrame = 400;
thresholdBhatt = .8;
radiusRegion = 0;
window = 4;
windowILLSize = 390;
withIllumCorrection =true;
threshOffsetIll = 1.2;
for curRadius = [0,6]
    
    radiusRegion = curRadius;
    if radiusRegion == 0
        notSaveGT = false;
    else
        notSaveGT = true;
        withIllumCorrection =false;
    end
    %
    grayHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
   if withIllumCorrection == true
        paramString = ['_new_NoSm',int2str(binRatio),'_',int2str(radiusRegion),'_',num2str(thresholdBhatt),'_',num2str(window),'_',num2str(threshOffsetIll),'_',num2str(windowILLSize),'_SABS'];
    else
        paramString = ['_new_NoSm',int2str(binRatio),'_',int2str(radiusRegion),'_',num2str(thresholdBhatt),'_',num2str(window),'_SABS'];
    end
    if(notSaveGT == false)
        imgBaseNameTest = '/home/andrea/Scrivania/SABS/Test/MPEG4_40kbps/MPEG4_';
    else
        imgBaseNameTest = ['/results',paramString,'/origvideo/images/frame0'];
    end
    gtPath ='/home/andrea/Scrivania/SABS/GT/GT';
    shadows = '/home/andrea/Scrivania/SABS/ShadowMasks/ShadowMask';
    namePathOut = ['./results',paramString,'/res'];
    %namePathOutVideoOrig = ['./results',paramString,'/origvideo'];
    namePathOutVideoOrig = ['./results',paramString,'/origvideo'];
    namegtPathVideoOrig = ['./results',paramString,'/gt'];
    namegt2PathVideoOrig = ['./results',paramString,'/gtShadows'];
    histRnd = zeros(numFrames-nLearningFrame+1,2);
    %%
    
    if withIllumCorrection
        lastMedians = zeros(windowILLSize,1);
        counter = 1;
    end
    k = [5,5];
    h = fspecial('gaussian', k, .5);
    [XM,YM] = meshgrid(1:size(grayHistogram,2),1:size(grayHistogram,1));
    XM = uint32(XM);
    YM = uint32(YM);
    for curFrame = 1:1:nLearningFrame
        tic
        if curFrame >= 1000
            curNumber = curFrame;
        elseif curFrame >= 100
            curNumber = ['0',int2str(curFrame)];
        elseif curFrame >= 10
            curNumber = ['00',int2str(curFrame)];
        else
            curNumber = ['000',int2str(curFrame)];
        end
        tmpCurImgRGB = imread([imgBaseNameTrain, curNumber, '.' ,imgExtension]);
        
        offCurRow = floor(1+rand()*10)-5;
        offCurCol = floor(1+rand()*10)-5;
        if offCurRow < 0
            offsetRowOffsetABegin   = 1;
            offsetRowOffsetAEnd     = sizeImage(1) + offCurRow;
            offsetRowOffsetBBegin   = -offCurRow+1;
            offsetRowOffsetBEnd     = sizeImage(1);
        else
            offsetRowOffsetBBegin   = 1;
            offsetRowOffsetBEnd     = sizeImage(1) - offCurRow;
            offsetRowOffsetABegin   = offCurRow+1;
            offsetRowOffsetAEnd     = sizeImage(1);
        end
        if offCurCol < 0
            offsetColOffsetABegin   = 1;
            offsetColOffsetAEnd     = sizeImage(2) + offCurCol;
            offsetColOffsetBBegin   = -offCurCol+1;
            offsetColOffsetBEnd     = sizeImage(2);
        else
            offsetColOffsetBBegin   = 1;
            offsetColOffsetBEnd     = sizeImage(2) - offCurCol;
            offsetColOffsetABegin   = offCurCol+1;
            offsetColOffsetAEnd     = sizeImage(2);
        end
        curImgRGB (offsetRowOffsetABegin:offsetRowOffsetAEnd,...
            offsetColOffsetABegin:offsetColOffsetAEnd,:) = ...
            tmpCurImgRGB(offsetRowOffsetBBegin:offsetRowOffsetBEnd,...
            offsetColOffsetBBegin:offsetColOffsetBEnd,:);
        
        curImgGray = rgb2gray(curImgRGB);
        idxRGB = floor((curImgGray+binRatio-1)/binRatio);
        
        G = idxRGB(:,:);
        
        iG =sub2ind(size(grayHistogram),YM(:),XM(:),uint32(G(:)));
        if withIllumCorrection
            if curFrame >=  nLearningFrame - windowILLSize
                lastMedians(counter) = median(double(curImgGray(:)));
                counter = counter + 1;
            end
        end
        grayHistogram(iG) = grayHistogram(iG) + 1;
        toc;
        disp(curFrame);
        %imshow(curImgGray)
        %pause(.15);
    end
    [XM,YM] = meshgrid(1:size(grayHistogram,2),1:size(grayHistogram,1));
    XM = uint32(XM);
    YM = uint32(YM);
    se = strel('disk',3);
    se2 = strel('disk',5);
    %%
    saveResults = true;
    histBinEdges = 0:floor(256/binRatio)+1;
    
    grayIntourHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
    curIntourHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
    %
    for curFrame = nLearningFrame:numFrames
        %%
        disp(curFrame);
        curIntourHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
        tic
        maxValHistR = mean(grayHistogram,3);
        if curFrame >= 1000
            curNumber = int2str(curFrame);
        elseif curFrame >= 100
            curNumber = ['0',int2str(curFrame)];
        elseif curFrame >= 10
            curNumber = ['00',int2str(curFrame)];
        else
            curNumber = ['000',int2str(curFrame)];
        end
        if notSaveGT == false
            curCountGT = curFrame +799;
            if curCountGT >= 1000
                curNumberGT = int2str(curCountGT);
            elseif curCountGT >= 100
                curNumberGT = ['0',int2str(curCountGT)];
            elseif curCountGT >= 10
                curNumberGT = ['00',int2str(curCountGT)];
            else
                curNumberGT = ['000',int2str(cucurCountGTrFrame)];
            end
        end
        
        if notSaveGT == false
            tmpCurImgRGB = imread([imgBaseNameTest, curNumber, '.' ,imgExtension]);
            rowRnd = rand();
            colRnd = rand();
            histRnd(curFrame - nLearningFrame+1,:) = [rowRnd, colRnd];
            offCurRow = floor(1+rowRnd*window*2)-window;
            offCurCol = floor(1+colRnd*window*2)-window;
            if offCurRow < 0
                offsetRowOffsetABegin   = 1;
                offsetRowOffsetAEnd     = sizeImage(1) + offCurRow;
                offsetRowOffsetBBegin   = -offCurRow+1;
                offsetRowOffsetBEnd     = sizeImage(1);
            else
                offsetRowOffsetBBegin   = 1;
                offsetRowOffsetBEnd     = sizeImage(1) - offCurRow;
                offsetRowOffsetABegin   = offCurRow+1;
                offsetRowOffsetAEnd     = sizeImage(1);
            end
            if offCurCol < 0
                offsetColOffsetABegin   = 1;
                offsetColOffsetAEnd     = sizeImage(2) + offCurCol;
                offsetColOffsetBBegin   = -offCurCol+1;
                offsetColOffsetBEnd     = sizeImage(2);
            else
                offsetColOffsetBBegin   = 1;
                offsetColOffsetBEnd     = sizeImage(2) - offCurCol;
                offsetColOffsetABegin   = offCurCol+1;
                offsetColOffsetAEnd     = sizeImage(2);
                
            end
            curImgRGB (offsetRowOffsetABegin:offsetRowOffsetAEnd,...
                offsetColOffsetABegin:offsetColOffsetAEnd,:) = ...
                tmpCurImgRGB(offsetRowOffsetBBegin:offsetRowOffsetBEnd,...
                offsetColOffsetBBegin:offsetColOffsetBEnd,:);
            curSh = imread([shadows,curNumber,'.png']);
            curGT = imread([gtPath,curNumberGT,'.png']);
            curGT2 = curGT;
            curGT2(curSh>0) = 255;
            curGT(curGT>0) = 255;
            curGT2(curGT>0) = 255;
            curGT (offsetRowOffsetABegin:offsetRowOffsetAEnd,...
                offsetColOffsetABegin:offsetColOffsetAEnd,:) = ...
                curGT(offsetRowOffsetBBegin:offsetRowOffsetBEnd,...
                offsetColOffsetBBegin:offsetColOffsetBEnd,:);
            curGT2 (offsetRowOffsetABegin:offsetRowOffsetAEnd,...
                offsetColOffsetABegin:offsetColOffsetAEnd,:) = ...
                curGT2(offsetRowOffsetBBegin:offsetRowOffsetBEnd,...
                offsetColOffsetBBegin:offsetColOffsetBEnd,:);
        else
            curImgRGB = imread([imgBaseNameTest, curNumber, '.' ,imgExtension]);
        end
        curImgGray = rgb2gray(curImgRGB);
        
        if withIllumCorrection
            comparMediane = median(lastMedians);
            curIllum = median(double(curImgGray(:)));
            
            offsetI = comparMediane - curIllum;
            curImgGray = curImgGray + round(threshOffsetIll*offsetI);
            
            lastMedians = [lastMedians(2:end);median(double(curImgGray(:)))];
        end
        idxRGB = floor((curImgGray+binRatio-1)/binRatio);
        
        G = idxRGB(:,:);
        
        offset = radiusRegion;
        for offsetRow = -offset:offset
            for offsetCol = -offset:offset
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
                iG = sub2ind(size(curIntourHistogram),YM((idxMask)),XM(idxMask),uint32(G(idxMask)));
                
                curIntourHistogram(iG) = curIntourHistogram(iG) + 1;
                
                grayIntourHistogram(offsetRowOffsetABegin:offsetRowOffsetAEnd, offsetColOffsetABegin:offsetColOffsetAEnd,:) = ...
                    grayIntourHistogram(offsetRowOffsetABegin:offsetRowOffsetAEnd, offsetColOffsetABegin:offsetColOffsetAEnd,:) +...
                    grayHistogram(offsetRowOffsetBBegin:offsetRowOffsetBEnd, offsetColOffsetBBegin:offsetColOffsetBEnd,:);
            end
        end
        grayIntourHistogram = grayIntourHistogram./ repmat(sum(grayIntourHistogram,3),[1,1,size(grayIntourHistogram,3)]);
        curIntourHistogram = curIntourHistogram./ repmat(sum(curIntourHistogram,3),[1,1,size(curIntourHistogram,3)]);
        scoresBhattG = 1 - sum(sqrt(grayIntourHistogram.* curIntourHistogram),3);
        
        
        
        %%
        bkgMIDX =  scoresBhattG<=thresholdBhatt;
        curIntourHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
        %forgM = reshape(~bkgMIDX,  size(redHistogram,1), size(redHistogram,2));
        forgM = ~bkgMIDX;
        if saveResults
            saveImageForVideo( uint8(255*forgM), namePathOut, curFrame)
            if(notSaveGT == false)
                saveImageForVideo( curImgRGB, namePathOutVideoOrig, curFrame)
                saveImageForVideo( curGT, namegtPathVideoOrig, curFrame)
                saveImageForVideo( curGT2, namegt2PathVideoOrig, curFrame)
            end
        end
        forgMT = imerode(forgM,se); forgMT = imdilate(forgMT,se);
        
        %updateBkg
        idxMask = ~forgMT(:);
        iG = sub2ind(size(grayHistogram),YM((idxMask)),XM(idxMask),uint32(G(idxMask)));
        grayHistogram(iG) = grayHistogram(iG) + 1;
        %updateBkg foreground pixels
        idxMask = forgMT(:);
        %iG = sub2ind(size(grayHistogram),YM((idxMask)),XM(idxMask),uint32(G(idxMask)));
        iG = 1 + (YM(idxMask)-1)*1 + (XM(idxMask)-1)*size(grayHistogram,1) ...
            + (uint32(G(idxMask))-1)*(size(grayHistogram,1)*size(grayHistogram,2));
        grayHistogram(iG) = grayHistogram(iG) + .21;
        toc
    end
    if(notSaveGT == false)
    save(['histrand',paramString,'.mat'],'histRnd');
end
end


