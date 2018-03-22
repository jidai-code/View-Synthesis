function [im0,im1] = removeGhostContour(im0,im1,disp0,disp1)
%% removing ghost contour artifacts. 
% Filtering background pixels in significant edges. Please refer to paper for more details.
%% code
time0 = cputime;
[imh,imw] = size(disp0);
wid = 7;
th = 150;
bk0 = (imfilter(disp0,ones(wid)) - wid^2 * disp0) > th;
bk1 = (imfilter(disp1,ones(wid)) - wid^2 * disp1) > th;

vld0 = (~bk0).*(disp0~=0);
vld1 = (~bk1).*(disp1~=0);

medw = 5;

[row,col] = find(bk0);

proxf = fspecial('gaussian',[2*medw+1,2*medw+1],10);
for i = 1:length(row)
    if(disp0(row(i),col(i))~=0)
        lm = max(1,col(i) - medw);
        rm = min(imw,col(i) + medw);
        um = max(1,row(i) - medw);
        bm = min(imh,row(i) + medw);
        depwind = disp0(um:bm,lm:rm);
        colorwind = im0(um:bm,lm:rm,:);
        vldw = vld0(um:bm,lm:rm);
        vldw = vldw .* (abs(depwind - disp0(row(i),col(i))) < 2);
        if(sum(vldw(:)) ~= 0)
            proxwind = proxf(medw - (row(i)-um) + 1:medw + 1 + (bm - row(i)),medw - (col(i)-lm) + 1:medw + 1 + (rm - col(i)));
            www = vldw .* proxwind;
            im0(row(i),col(i),:) = sum(sum(colorwind .* repmat(www,1,1,3),1),2) / sum(www(:));
        end
    end
end
[row,col] = find(bk1);
for i = 1:length(row)
    if(disp1(row(i),col(i))~=0)
        lm = max(1,col(i) - medw);
        rm = min(imw,col(i) + medw);
        um = max(1,row(i) - medw);
        bm = min(imh,row(i) + medw);
        depwind = disp1(um:bm,lm:rm);
        colorwind = im1(um:bm,lm:rm,:);
        vldw = vld1(um:bm,lm:rm);
        vldw = vldw .* (abs(depwind - disp1(row(i),col(i))) < 2);
        if(sum(vldw(:)) ~= 0)
            proxwind = proxf(medw - (row(i)-um) + 1:medw + 1 + (bm - row(i)),medw - (col(i)-lm) + 1:medw + 1 + (rm - col(i)));
            www = vldw .* proxwind;
            im1(row(i),col(i),:) = sum(sum(colorwind .* repmat(www,1,1,3),1),2) / sum(www(:));
        end
    end
end
time1 = cputime;
fprintf('ghost contour removed: %.2fs ... \n',time1 - time0);
end