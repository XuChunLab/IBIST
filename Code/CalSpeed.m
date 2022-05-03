function sp=CalSpeed(x,y)
% return speed vector [nLength,1]
% TO do: sliding window to smooth the instaneous speed
sp=InsSpeed(x,y);
sp=[0; reshape(sp,length(sp),1)];
end



function sp=InsSpeed(x,y)
% calculate the instaenous speed
% the output will be 1 element shorter
dX=diff(x);
dY=diff(y);
sp=sqrt( dX.^2 + dY.^2);

end