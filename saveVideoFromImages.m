function  saveVideoFromImages( directoryPath, nameVideo ,sizeImage)
%SAVEVIDEOFROMIMAGES Save the video from the images in the specified path
%
% Useful function which call mencoder (which must be installed in
% the OS) to store images located in directoryPath/images to a video in
% directoryPath/nameVideo.avi
%
% INPUT:
%	directoryPath: the function search png images in directoryPath/images
%	nameVideo: name of the video stored in directoryPath/nameVideo.avi

if ~exist('sizeImage','var')
    width = 800;
    height = 600;
else
    width = floor(sizeImage(2));
    height= floor(sizeImage(1));
end
system(['/usr/bin/mencoder mf://',directoryPath,...
    '/images/*.png -mf w=',int2str(width),':h=',int2str(height),':fps=15:type=png -ovc lavc -lavcopts vcodec=msmpeg4:vbitrate=2600 -oac copy -o ',...
    directoryPath,'/',nameVideo,'.avi'])
end

