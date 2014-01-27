function [ curNumber ] = getFrameNumber( baseNumbering,curFrame )
%GETFRAMENUMBER Summary of this function goes here
%   Detailed explanation goes here
if baseNumbering == 100
        if curFrame >= 100000
            curNumber = int2str(curFrame);
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
    else
        if curFrame >= 1000
            curNumber = int2str(curFrame);
        elseif curFrame >= 100
            curNumber = ['0',int2str(curFrame)];
        elseif curFrame >= 10
            curNumber = ['00',int2str(curFrame)];
        else
            curNumber = ['000',int2str(curFrame)];
        end
    end

end

