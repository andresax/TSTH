foldersList2 = {'badminton/aligned/', 'boulevard/aligned/', 'sidewalk/aligned/', 'traffic/aligned/'};
foldersList = {'badminton', 'boulevard', 'sidewalk', 'traffic'};
nInitFrameList = [800, 790, 800, 900];
nEndFrameList = [1150, 2500, 1200, 1570];
%%
%matlabpool(4)
%%
smoothEnabled = false;
binRatio = 16;
radiusRegion = 6;
imgExtension = 'jpg';
thresholdBhat=.758;
windowSize = 690;
withIllumCorrection =true;
threshOffsetIll = 1.0;

if smoothEnabled
    paramString = ['_new_Sm',int2str(binRatio),'_',int2str(radiusRegion),'_',num2str(thresholdBhat),'_',num2str(windowSize),'_',num2str(threshOffsetIll)];
else
    paramString = ['_new_NoSm',int2str(binRatio),'_',int2str(radiusRegion),'_',num2str(thresholdBhat),'_',num2str(windowSize),'_',num2str(threshOffsetIll)];
end

for curvid = 1:4
    
    imgBaseName = ['/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/',foldersList2{curvid}];
    
    nLearningFrame = nInitFrameList(curvid);
    numFrames = nEndFrameList(curvid);
    
    namePathSave = ['./results',paramString,'/histRGBbkg',foldersList{curvid},'Align.mat'];
    namePathOut = ['./ChangeDir',date,'/res',paramString,'/',foldersList{curvid}];
    
    curImgRGB = imread([imgBaseName, '0001.' ,imgExtension]);
    sizeImage = [size(curImgRGB,1), size(curImgRGB,2)];
    grayHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
    
    baseNumbering = 1;
    if withIllumCorrection
        lastMedians = zeros(windowSize,1);
        counter = 1;
    end
    %% Learning Stage
    %k = [5,5];h = fspecial('gaussian', k, .5);%MotionBlur = imfilter(I,h);
    [XM,YM] = meshgrid(1:size(grayHistogram,2),1:size(grayHistogram,1));
    XM = uint32(XM);YM = uint32(YM);
    for curFrame = 1:1:nLearningFrame-100
        tic
        curNumber = getFrameNumber( baseNumbering,curFrame );
        
        curImgGray = rgb2gray(imread([imgBaseName, curNumber, '.' ,imgExtension]));
        %curImgGray = imread([imgBaseName, curNumber, '.' ,imgExtension]);

        idxRGB = floor((curImgGray+binRatio-1)/binRatio);
        %iG =sub2ind(size(grayHistogram),YM(:),XM(:),uint32(idxRGB(:)));
        iG = 1 + (YM(:)-1)*1 + (XM(:)-1)*size(grayHistogram,1) ...
            + (uint32(idxRGB(:))-1)*(size(grayHistogram,1)*size(grayHistogram,2));
        
        grayHistogram(iG) = grayHistogram(iG) + 1;
        if withIllumCorrection
            if curFrame >=  nLearningFrame-100 - windowSize
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
    
    grayIntourHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
    curIntourHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
    
    for curFrame = nLearningFrame-100:numFrames
        tic
        disp(curFrame);
        curIntourHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
        maxValHistR = mean(grayHistogram,3);
        curNumber = getFrameNumber( baseNumbering,curFrame );
        
 %       curImgGray = (imread([imgBaseName, curNumber, '.' ,imgExtension]));
         curImgGray = rgb2gray(imread([imgBaseName, curNumber, '.' ,imgExtension]));
        tic
        if withIllumCorrection
            comparMediane = median(lastMedians);
            curIllum = median(double(curImgGray(:)));
            
            offset = comparMediane - curIllum;
            curImgGray = curImgGray + round(threshOffsetIll*offset);
            
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
                
                a = grayIntourHistogram(offsetRowOffsetABegin:offsetRowOffsetAEnd, offsetColOffsetABegin:offsetColOffsetAEnd,:);
                b = grayHistogram(offsetRowOffsetBBegin:offsetRowOffsetBEnd, offsetColOffsetBBegin:offsetColOffsetBEnd,:);
                grayIntourHistogram(offsetRowOffsetABegin:offsetRowOffsetAEnd, offsetColOffsetABegin:offsetColOffsetAEnd,:) = ...
                    a+b;
            end
        end
        grayIntourHistogram = grayIntourHistogram./ repmat(sum(grayIntourHistogram,3),[1,1,size(grayIntourHistogram,3)]);
        curIntourHistogram = curIntourHistogram./ repmat(sum(curIntourHistogram,3),[1,1,size(curIntourHistogram,3)]);
        scoresBhattG = 1 - sum(sqrt(grayIntourHistogram.* curIntourHistogram),3);
        
        %%
        bkgMIDX =  scoresBhattG<=thresholdBhat;
        
        forgM = ~bkgMIDX;
        forgMT = imerode(forgM,se); forgMT = imdilate(forgMT,se);
        
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
        grayHistogram(iG) = grayHistogram(iG) + .51;
        toc
        saveImageForVideo( uint8(255*forgM), namePathOut, curFrame);
    end
end
