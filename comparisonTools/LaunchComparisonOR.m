
% datasetPath = '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histResults/datasets/cameraJitter/';
% withIll = true;
% window = 4;
% if withIll == true
%     strfold = [int2str(window),'_1.2_390'];
% else
%     strfold = int2str(window);
% end
% binaryFolderRoot = ...
%     ['/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histogBKG_SUB_GRAYSCALE/results_new_NoSm16_0_0.8_',strfold,'_SABS/res/images'];
% binaryFolderRootHist = ...
%     ['/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histogBKG_SUB_GRAYSCALE/results_new_NoSm16_6_0.8_',strfold,'_SABS/res/images'];
% binaryFolderRootOR = ...
%     ['/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histogBKG_SUB_GRAYSCALE/results_new_NoSm16_0.8_',strfold,'_AND_SABS/images'];
% groundtruthFolder = {['/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histogBKG_SUB_GRAYSCALE/results_new_NoSm16_0_0.8_',strfold,'_SABS/gt/images']};
% binaryFolder = {binaryFolderRoot};
% binaryFolderHist = {binaryFolderRootHist};
% binaryFolderAND = {binaryFolderRootOR};
%%
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
basePath = '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histogBKG_SUB_GRAYSCALE/ResultsPaper/';
basePathGT = '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/';
%curVidVec = 1:4;
curVidVec = 1:4;
extension = '.png';
extension2 = '.png';
offsetFromLearningFrame = 0;
useTemporal = false;
useSpatio = false;
useTSTH = true;
calcTSTH = false;
onlyTemporal = false;
altraString = '_.5_0';
altraString2 = '_.5_0';
if  matlabpool('size') == 0
    matlabpool(4);
end

for curThresh = 1 : length(thresholdBhatVec)
    binaryFolderRootSpatioTemporal = [basePath,'resAlign',altraString,'16_6_',num2str(thresholdBhatVec(curThresh)),'_',num2str(trshIll),'_',num2str(windowSize),'/'];
    binaryFolderRootTemporal = [basePath,'resAlign',altraString2,'16_0_',num2str(thresholdBhatVec2(curThresh)),'_',num2str(trshIll2),'_',num2str(windowSize2),'/'];
    binaryFolderRootAND = [basePath,'resAlign',altraString,altraString2,'16_0_',num2str(thresholdBhatVec(curThresh)),'_',num2str(thresholdBhatVec2(curThresh)),'_',num2str(trshIll),'_',num2str(trshIll2),'_',num2str(windowSize),'_',num2str(windowSize2),'AND/'];
    
    groundtruthFolder = {[basePathGT,'badminton/alignedBadmintonGT/'], [basePathGT,'boulevard/alignedBoulevardGT/'], ...
        [basePathGT,'sidewalk/alignedSidewalkGT/'],[basePathGT,'traffic/alignedTrafficGT/']};
    
        groundtruthFolder = {[basePathGT,'badminton/groundtruth/gt00'], [basePathGT,'boulevard/groundtruth/gt00'], ...
            [basePathGT,'sidewalk/groundtruth/gt00'],[basePathGT,'traffic/groundtruth/gt00']};
    binaryFolderSpatioTemporal = {[binaryFolderRootSpatioTemporal,'badminton/images'],[binaryFolderRootSpatioTemporal,'boulevard/images'],...
        [binaryFolderRootSpatioTemporal,'sidewalk/images'],[binaryFolderRootSpatioTemporal,'traffic/images']};
    binaryFolderTemporal = {[binaryFolderRootTemporal,'badminton/images'],[binaryFolderRootTemporal,'boulevard/images'],...
        [binaryFolderRootTemporal,'sidewalk/images'],[binaryFolderRootTemporal,'traffic/images']};
    binaryFolderAND = {[binaryFolderRootAND,'badminton/images'],[binaryFolderRootAND,'boulevard/images'],...
        [binaryFolderRootAND,'sidewalk/images'],[binaryFolderRootAND,'traffic/images']};
    binaryFolderAND = {[binaryFolderRootAND,'badmintonDealigned'],[binaryFolderRootAND,'boulevardDealigned'],...
        [binaryFolderRootAND,'sidewalkDealigned'],[binaryFolderRootAND,'trafficDealigned']};
    roi = {[basePathGT,'badminton/ROI.bmp'],[basePathGT,'boulevard/ROI.bmp'],[basePathGT,'sidewalk/ROI.bmp'],[basePathGT,'traffic/ROI.bmp']};
    mask = {[basePathGT,'badminton/ROI2.bmp'],[basePathGT,'boulevard/ROI2.bmp'],[basePathGT,'sidewalk/ROI2.bmp'],[basePathGT,'traffic/ROI2.bmp']};
    nInitFrameList = [800, 790, 800, 900];
    nEndFrameList = [1150, 2500, 1200, 1570];
    
    TP = cell(4,1); FP = cell(4,1); FN = cell(4,1); TN = cell(4,1); SE = cell(4,1);
    stats = cell(4,1); confusionMatrix = cell(4,1);
    %roi = {'/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histogBKG_SUB_GRAYSCALE/Chiari/ROI2.png'};
    %%
    if calcTSTH
        parfor curVid = curVidVec
            mkdir(binaryFolderAND{curVid});
            idxFrom = nInitFrameList(curVid);
            idxTo = nEndFrameList(curVid);
            maskImage = (imread(mask{curVid}));
            for idx = idxFrom:idxTo
                fileName = num2str(idx, '%.4d');
                imBinary2 = (imread(fullfile(binaryFolderTemporal{curVid}, ['frame0', fileName, extension])));
                imBinary = (imread(fullfile(binaryFolderSpatioTemporal{curVid}, ['frame0', fileName, extension2])));
                imwrite(imBinary&imBinary2,fullfile(binaryFolderAND{curVid}, ['frame0', fileName, extension]));
                disp(idx);
            end
        end
    end
    
    %%
    if useTemporal 
        parfor curVid = curVidVec
            idxFrom = nInitFrameList(curVid);
            idxTo = nEndFrameList(curVid);
            roiImage = (imread(roi{curVid}));
            %roiImage = uint8(255.*ones(size(imBinary2)));
            %comparing temporal results
            confusionMatrix{curVid} = compareImageFiles(groundtruthFolder{curVid}, ...
                binaryFolderTemporal{curVid}, idxFrom, idxTo,roiImage,extension,filterSize);
            
            [TP{curVid} FP{curVid} FN{curVid} TN{curVid} SE{curVid} stats{curVid}] =...
                confusionMatrixToVar(confusionMatrix{curVid});
            disp(stats{curVid});
        end
        statsMat = cell2mat(stats);
        sumStat = sum(statsMat,1)./4;
        dlmwrite([binaryFolderRootTemporal,'TemporalstatsMat',int2str(filterSize),'_',int2str(offsetFromLearningFrame),'.csv'],statsMat);
        dlmwrite([binaryFolderRootTemporal,'TemporalsumStat',int2str(filterSize),'_',int2str(offsetFromLearningFrame),'.csv'],sumStat);
        save([binaryFolderRootTemporal,'Temporal',int2str(filterSize),'.mat'],'statsMat','sumStat');
    end
    if useSpatio
        parfor curVid = curVidVec
            idxFrom = nInitFrameList(curVid);
            idxTo = nEndFrameList(curVid);
            roiImage = (imread(roi{curVid}));
            %comparing spatio-temporal results
            confusionMatrix{curVid} = compareImageFiles(groundtruthFolder{curVid}, ...
                binaryFolderSpatioTemporal{curVid}, idxFrom, idxTo,roiImage,extension2,filterSize);
            
            [TP{curVid} FP{curVid} FN{curVid} TN{curVid} SE{curVid} stats{curVid}] =...
                confusionMatrixToVar(confusionMatrix{curVid});
            disp(stats{curVid});
        end
        statsMat = cell2mat(stats);
        sumStat = sum(statsMat,1)./4;
        dlmwrite([binaryFolderRootSpatioTemporal,'Spatio-TemporalstatsMat',int2str(filterSize),'.csv'],statsMat);
        dlmwrite([binaryFolderRootSpatioTemporal,'Spatio-TemporalsumStat',int2str(filterSize),'.csv'],sumStat);
        save([binaryFolderRootSpatioTemporal,'Spatio-Temporal',int2str(filterSize),'.mat'],'statsMat','sumStat');
        
    end
    if useTSTH    
        parfor curVid = curVidVec
            idxFrom = nInitFrameList(curVid);
            idxTo = nEndFrameList(curVid);
            roiImage = (imread(roi{curVid}));
            %comparing AND results
            confusionMatrix{curVid} = compareImageFiles(groundtruthFolder{curVid}, ...
                binaryFolderAND{curVid}, idxFrom, idxTo,roiImage,extension,filterSize);
            
            [TP{curVid} FP{curVid} FN{curVid} TN{curVid} SE{curVid} stats{curVid}] =...
                confusionMatrixToVar(confusionMatrix{curVid});
            disp(stats{curVid});
        end
        statsMat = cell2mat(stats);
        sumStat = sum(statsMat,1)./4;
        dlmwrite([binaryFolderRootAND,'ANDstatsMat',int2str(filterSize),'.csv'],statsMat);
        dlmwrite([binaryFolderRootAND,'ANDsumStat',int2str(filterSize),'.csv'],sumStat);
        save([binaryFolderRootAND,'AND',int2str(filterSize),'.mat'],'statsMat','sumStat');
    end
end
