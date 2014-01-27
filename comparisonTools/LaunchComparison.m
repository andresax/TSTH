% datasetPath = '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histResults/datasets/cameraJitter/';
% 
% binaryFolderRoot = ...
%     '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histogBKG_SUB_GRAYSCALE/results_new_NoSm16_6_0.7/';
% 
% groundtruthFolder = {'/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/badminton/alignedBadmintonGT',...
%     '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/boulevard/alignedBoulevardGT',...
%     '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/sidewalk/alignedSidewalkGT',...
%     '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/traffic/alignedTrafficGT'};
% binaryFolder = {[binaryFolderRoot,'badminton/images'],[binaryFolderRoot,'boulevard/images'],...
%     [binaryFolderRoot,'sidewalk/images'],[binaryFolderRoot,'traffic/images']};
% roi = {'/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/badminton/ROI.bmp',...
%     '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/boulevard/ROI.bmp',...
%     '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/sidewalk/ROI.bmp',...
%     '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/traffic/ROI.bmp'};
TP = cell(4,1); FP = cell(4,1); FN = cell(4,1); TN = cell(4,1); SE = cell(4,1);
stats = cell(4,1); confusionMatrix = cell(4,1);
%nInitFrameList = [800, 790, 800, 900];
%nEndFrameList = [1150, 2500, 1200, 1570];
%nEndFrameList = [855, 1601, 1200, 1570];
%nEndFrameList = [1097, 2310, 1200, 1570];
nInitFrameList = 400;
nEndFrameList = 599;


binaryFolderRoot = ...
    '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histogBKG_SUB_GRAYSCALE/Chiari/results_new_NoSm16_6_0.75_800/';

groundtruthFolder = {'/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histogBKG_SUB_GRAYSCALE/Chiari/groundtruth'};
binaryFolder = {binaryFolderRoot};
roi = {'/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/badminton/ROI.bmp',...
    '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/boulevard/ROI.bmp',...
    '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/sidewalk/ROI.bmp',...
    '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/traffic/ROI.bmp'};
roim = '/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/histogBKG_SUB_GRAYSCALE/Chiari/ROI2.png';
%%
%matlabpool(4)

for curVid = 1:1
    %curVid = 2;
    idxFrom = nInitFrameList(curVid);
    idxTo = nEndFrameList(curVid);
    
    roiImage = imread(roim);
    confusionMatrix{curVid} = compareImageFiles(groundtruthFolder{curVid}, binaryFolder{curVid}, idxFrom, idxTo,roiImage);
    [TP{curVid} FP{curVid} FN{curVid} TN{curVid} SE{curVid} stats{curVid}] =...
        confusionMatrixToVar(confusionMatrix{curVid});
    disp(stats{curVid});
end



