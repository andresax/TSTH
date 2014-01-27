%Create unstab video
function createUnstabVideo(offset, imgBaseNamePath)

imgExtension = 'png';
curImgRGB = imread([imgBaseNamePath, '0001.' ,imgExtension]);
sizeImage = [size(curImgRGB,1), size(curImgRGB,2)];
numFrames = 599;
for curFrame = 1:1:numFrames
    tic;
    disp(curFrame);
    %curImgRGB= read(videoObj, videoOffset + curFrame);
    if curFrame >= 1000
        curNumber = curFrame;
    elseif curFrame >= 100
        curNumber = ['0',int2str(curFrame)];
    elseif curFrame >= 10
        curNumber = ['00',int2str(curFrame)];
    else
        curNumber = ['000',int2str(curFrame)];
    end
    tmpCurImgRGB = imread([imgBaseNamePath, curNumber, '.' ,imgExtension]);
    offCurRow = floor(1+rand()*offset-.5*offset);
    offCurCol = floor(1+rand()*offset-.5*offset);
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
    saveImageForVideo( curImgRGB, './resultsBkgVideoSABS1', curFrame);
end

 saveVideoFromImages( './resultsBkgVideoSABS1', 'resultsBkgVideoSABS1UnstabTrain' ,size(curImgRGB));
