
function confusionMatrix = compareImageFiles(gtFolder, binaryFolder, idxFrom, idxTo,roi,extension,filtersize)
% Compare the binary files with the groundtruth files.

%extension = '.png'; % TODO Change extension if required
threshold = strcmp(extension, '.jpg') == 1 || strcmp(extension, '.jpeg') == 1;

% imBinary = imread(fullfile(binaryFolder, ['frame', num2str(idxFrom, '%.5d'), extension]));
% int8trap = isa(imBinary, 'uint8') && min(min(imBinary)) == 0 && max(max(imBinary)) == 1;

confusionMatrix = [0 0 0 0 0]; % TP FP FN TN SE
for idx = idxFrom:idxTo
    fileName = num2str(idx, '%.4d');
    imBinary = (imread(fullfile(binaryFolder, ['frame0', fileName, extension])));
    
    if size(imBinary, 3) > 1
        imBinary = rgb2gray(imBinary);
    end
    if islogical(imBinary) || int8trap
        imBinary = uint8(imBinary)*255;
    end
    if threshold
        imBinary = im2bw(imBinary, 0.5);
        imBinary = im2uint8(imBinary);
    end
    %imGT = rgb2gray(imread(fullfile(gtFolder, [ '',fileName, '.jpg'])));
    imGT = (imread([gtFolder, '',fileName, '.png']));
    %imGT = (imread(fullfile(gtFolder, [ 'frame0',fileName, '.png'])));
    
    imBinary = medfilt2(imBinary, [filtersize,filtersize]);
    imwrite(imBinary,fullfile(binaryFolder, ['Filteredframe0', fileName, extension]));
    
    % imshow(imBinary);
    %
    % se = strel('disk',3);
    % se2 = strel('disk',5);
    %     forgMT = imerode(imBinary,se2);
    %     forgMT = imdilate(forgMT,se);
    %imBinary = (imread(fullfile(binaryFolder, ['00', fileName, extension])));
    %imBinary = im2bw(imBinary, 0.5);
    %     imBinary = im2uint8(imBinary);
    confusionMatrix = confusionMatrix + compareImages(imBinary, imGT,roi);
    
end
end

