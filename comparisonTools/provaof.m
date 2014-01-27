videoName = {'badminton', 'boulevard', 'sidewalk', 'traffic'};
thresholdBhatVec = .758;
thresholdBhatVec2 = .758;
windowSize = 690;
windowSize2 = 690;
trshIll =1.0;
trshIll2 =0.0;
filterSize =7;
curThresh = 1;
% basePath = '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histogBKG_SUB_GRAYSCALE/OverallResult/changeIllThreshold/';
% basePath = '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histogBKG_SUB_GRAYSCALE/OverallResults/';
basePath = '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histogBKG_SUB_GRAYSCALE/ChangeDir09-Sep-2013/';
basePathGT = '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/';
nInitFrameList = [800, 790, 800, 900];
nEndFrameList = [1150, 2500, 1200, 1570];
groundtruthFolder2 = {[basePathGT,'badminton/alignedBadmintonGT/'], [basePathGT,'boulevard/alignedBoulevardGT/'], ...
    [basePathGT,'sidewalk/alignedSidewalkGT/'],[basePathGT,'traffic/alignedTrafficGT/']};

curVidVec = 1:4;
groundtruthFolder = {[basePathGT,'badminton/groundtruth/gt00'], [basePathGT,'boulevard/groundtruth/gt00'], ...
    [basePathGT,'sidewalk/groundtruth/gt00'],[basePathGT,'traffic/groundtruth/gt00']};
binaryFolderAND = {[binaryFolderRootAND,'badminton/images'],[binaryFolderRootAND,'boulevard/images'],...
        [binaryFolderRootAND,'sidewalk/images'],[binaryFolderRootAND,'traffic/images']};
for curVid = curVidVec
    binaryFolder = binaryFolderAND{curVid};
    idxFrom = nInitFrameList(curVid);
    idxTo = nEndFrameList(curVid);
    for idx = idxFrom:idxTo
        fileName = num2str(idx, '%.4d');
        imBinary = (imread(fullfile(binaryFolder, ['frame0', fileName, extension])));
        
        if size(imBinary, 3) > 1
            imBinary = rgb2gray(imBinary);
        end
        if islogical(imBinary) || int8trap
            imBinary = uint8(imBinary)*255;
        end
        if 0
            imBinary = im2bw(imBinary, 0.5);
            imBinary = im2uint8(imBinary);
        end
        imGT = (imread([groundtruthFolder{curVid}, '',fileName, '.png']));
        imGT2 = rgb2gray(imread(fullfile(groundtruthFolder2{curVid}, [ '',fileName, '.jpg'])));
        uv = estimate_flow_interface(imGT, imGT2,'classic+nl-fast');
        [x1,y1] = meshgrid(1:size(imGT,2),1:size(imGT,1));
        
        u = uv(:,:,1);
        v = uv(:,:,2);
        vgg_H_from_x_lin([x1(:),y1(:),ones(length(x1(:)),1)], [x1(:)+u(:),y1(:)+v(:),ones(length(x1(:)),1)]);
        
    end
end