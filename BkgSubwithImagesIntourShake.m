
% histComputationHandle = @( A, B, i,j,offsetI,offsetJ,binRatio ) (...
%     sqrt(1 - sum(sqrt(...
%     hist(A(i-offsetI:i+offsetI,j-offsetJ:j+offsetJ),0:floor(256/binRatio)+1).*...
%     hist(B(i-offsetI:i+offsetI,j-offsetJ:j+offsetJ),0:floor(256/binRatio)+1)))));


imgBaseNameTrain = '/home/romanoni/SABS/Train/MPEG4_40kbps/MPEG4_';
imgBaseNameTest = '/home/romanoni/SABS/Test/MPEG4_40kbps/MPEG4_';
imgExtension = 'png';
curImgRGB = imread([imgBaseNameTest, '0001.' ,imgExtension]);

%
%frameRate = videoObj.FrameRate;
sizeImage = [size(curImgRGB,1), size(curImgRGB,2)];
numFrames = 599;
videoOffset = 2;
binRatio = 8;
nLearningFrame = 400;
radiusRegion = 6;
imageIntervalX = [radiusRegion+1, sizeImage(2) - (radiusRegion+1)];
imageIntervalY = [radiusRegion+1, sizeImage(1) - (radiusRegion+1)];
%
grayHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);

%%
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
    
    grayHistogram(iG) = grayHistogram(iG) + 1;
    toc;
    disp(curFrame);
    %imshow(curImgGray)
    %pause(.15);
end
%%
save('./histRGBbkgProvaDataset1ShakeGray.mat','grayHistogram','radiusRegion','nLearningFrame');
%%
% tic;
% maxValHistR = max(redHistogram,[],3);
% maxValHistG = max(greenHistogram,[],3);
% maxValHistB = max(blueHistogram,[],3);
% toc;
%%
load('./histRGBbkgProvaDataset1ShakeGray.mat','grayHistogram','radiusRegion','nLearningFrame');
[XM,YM] = meshgrid(1:size(grayHistogram,2),1:size(grayHistogram,1));
XM = uint32(XM);
YM = uint32(YM);
se = strel('disk',3);
se2 = strel('disk',5);

saveResults = true;
radius = 6;
[patchToCheckX, patchToCheckY] = meshgrid(-radius:radius,-radius:radius);
histBinEdges = 0:floor(256/binRatio)+1;

grayIntourHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
curIntourHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
%
for curFrame = 0:numFrames
    %%
    disp(curFrame);
    curIntourHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
    tic
    maxValHistR = mean(grayHistogram,3);
    if curFrame >= 1000
        curNumber = curFrame;
    elseif curFrame >= 100
        curNumber = ['0',int2str(curFrame)];
    elseif curFrame >= 10
        curNumber = ['00',int2str(curFrame)];
    else
        curNumber = ['000',int2str(curFrame)];
    end
    
    tmpCurImgRGB = imread([imgBaseNameTest, curNumber, '.' ,imgExtension]);
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
    
    offset = radius;
    offsetXVector = offset*ones(size(curImgGray));
    offsetYVector = offset*ones(size(curImgGray));
    binRatioMatrix = binRatio*ones(size(curImgGray));
    [idxI,idxJ] = meshgrid(1+offset: size(grayHistogram,1)-offset,1+offset: size(grayHistogram,1)-offset);
     
    tic
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
    bkgMIDX =  scoresBhattG<=.88;
    toc
    curIntourHistogram = zeros(sizeImage(1),sizeImage(2), 256/binRatio);
    %forgM = reshape(~bkgMIDX,  size(redHistogram,1), size(redHistogram,2));
    forgM = ~bkgMIDX;
    if saveResults
        resfig(:,:,1) = uint8(255*forgM);
        resfig(:,:,2) = uint8(255*forgM);
        resfig(:,:,3) = uint8(255*forgM);
        saveImageForVideo( uint8(255*forgM), './resultsBkgVideoSABS1', curFrame)
    end
    forgMT = imerode(forgM,se);
    forgMT = imdilate(forgMT,se);
    forgMT = imerode(forgMT,se2);
    forgMT = imdilate(forgMT,se2);
    
    
    %forgMT = imdilate(forgM,se);
    %         forgMT = imerode(forgM,se);
    %         forgMT = imdilate(forgMT,se);
    
    subplot(2,2,1);imshow(forgM);
    subplot(2,2,2);imshow(curImgRGB);
    subplot(2,2,3);imshow(forgMT);  
    %imshow(forgM);
    %figure, imshow(forgMT)
    
    %updateBkg
    idxMask = ~forgMT(:);
    iG = sub2ind(size(grayHistogram),YM((idxMask)),XM(idxMask),uint32(G(idxMask)));
    grayHistogram(iG) = grayHistogram(iG) + 1;
    if ~saveResults
        pause(.05);
    end
end
%%
if saveResults
    saveVideoFromImages( './resultsBkgVideoSABS1IntourVideoShakeGray.avi', 'resultsBkgVideoSABS1' ,size(forgM));
end
%%
% se = strel('square',3);
% se2 = strel('square',5);
% forgMT = imdilate(forgM,se);
% forgMT = imerode(forgMT,se2);
% forgMT = imerode(forgMT,se);
% forgMT = imdilate(forgMT,se);
% imshow(forgMT)
