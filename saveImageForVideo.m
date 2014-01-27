function saveImageForVideo( fig, directoryPath, cur)
%SAVEIMAGEFORVIDEO Save the figure in the specified path
%
% Useful function used to save a certain figure (handle fig) which is
% supposed to be the frame number cur.
%
% INPUT:
%	fig: handle to figure to save
%	directoryPath: path where the figure will be stored.
%	cur: current numeric Id for image


%directoryPath = [strSave,int2str(numFilter)];
estensione = '.png';
if ~isdir(directoryPath)
    mkdir(directoryPath);
end
strBase = [directoryPath,'/images/frame'];
if ~isdir([directoryPath,'/images/'])
    mkdir([directoryPath,'/images/']);
end
if cur<10
    numWithPadding = ['0000',int2str(cur)];
elseif cur<100
    numWithPadding = ['000',int2str(cur)];
elseif cur<1000
    numWithPadding = ['00',int2str(cur)];
elseif cur<10000
    numWithPadding = ['0',int2str(cur)];
else
    numWithPadding = int2str(cur);
end
strtot = [strBase,numWithPadding,estensione];
if length(fig)==1
    print(fig, '-dpng', strtot);
else
    imwrite((fig),strtot,'png')
end
end

