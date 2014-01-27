

% function hist = provaAnonimaFun (matrice, i,j, offset,binsize)
% 
% hist = zeros(binsize,1);
% temp = matrice(i-offset:i+offset,j-offset:j+offset);
% 
% hist(temp(:))=1;
% 
% end
function res = provaAnonimaFun (matrix,binRatio)
res = zeros(1,binRatio);
%res = matriceRef(i:i+3,j:j+3)/32;
floor(((matrix)+binRatio-1)/binRatio);
accumarray([matrix(:),1,256/binRatio],[ones(size(matrix(:),1)),1,256/binRatio]);
end