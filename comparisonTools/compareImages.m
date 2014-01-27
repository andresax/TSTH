
function confusionMatrix = compareImages(imBinary, imGT,roi)
% Compares a binary frames with the groundtruth frame

TP = sum(sum(imGT==255&imBinary==255&roi>0));		% True Positive
TN = sum(sum(imGT<=50&imBinary==0&roi>0));		% True Negative
FP = sum(sum((imGT<=50)&imBinary==255&roi>0));	% False Positive
FN = sum(sum(imGT==255&imBinary==0&roi>0));		% False Negative
SE = sum(sum(imGT==50&imBinary==255&roi>0));		% Shadow Error

% subplot(3,2,1);imshow(imGT);
% subplot(3,2,2);imshow(imBinary);
% subplot(3,2,3);imshow(imGT==255&imBinary==255&roi>0);
% subplot(3,2,4);imshow(imGT<=50&imBinary==0&roi>0);
% subplot(3,2,5);imshow((imGT<=50)&imBinary==255&roi>0);
% subplot(3,2,6);imshow(imGT==255&imBinary==0&roi>0);
% pause(0.2);


confusionMatrix = [TP FP FN TN SE];
end
