video = VideoReader('/home/andrea/Scrivania/Camera2/spezzone1.avi');
%%
% fig = figure;
% set(fig,'doublebuffer','on');
% 
% set(fig,'KeyPressFcn','keydown=1;');
%         keydown=0;
%         figure;
for curFrame = 1:1:video.NumberOfFrames
    curImgRGB = read(video,curFrame);
    
%     imshow(curImgRGB);
%     hold off;
%     pause(0.05);
%     
%     if keydown==1
        if curFrame >= 100000
            curNumber = curFrame;
        elseif curFrame >= 10000
            curNumber = ['0',int2str(curFrame)];
        elseif curFrame >= 1000
            curNumber = ['00',int2str(curFrame)];
        elseif curFrame >= 100
            curNumber = ['000',int2str(curFrame)];
        elseif curFrame >= 10
            curNumber = ['0000',int2str(curFrame)];
        else
            curNumber = ['00000',int2str(curFrame)];
        end
%         imwrite(curImgRGB, ['immaginiVideo/frame',curNumber,'.png']);
%         keydown=0;
%     end
imwrite(curImgRGB, ['immaginiVideo/frame',curNumber,'.png']);
end