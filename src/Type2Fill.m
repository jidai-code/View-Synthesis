function [im1,dist1] = Type2Fill(im0,dist0,edgePixel,edgeV,edgeSTD,ImagePD,clusterN)
im1 = zeros(size(im0));
dist1 = zeros(size(dist0));
[imh,imw] = size(edgePixel);
medwing = 2;
fmask = ones(5);
[idx,center] = kmeans(edgeV,clusterN);
center(find(center == inf)) = 0;
[maxv,maxi] = max(center);
minth = min(edgeV(find(idx == maxi)));

edgeValue = edgePixel .* dist0;
edgeVld = edgeValue >= minth;
while(~isempty(find(ImagePD(:))))
    DealPixel = ImagePD .* imdilate(edgeVld,fmask);
    [rows,cols] = find(DealPixel);
    lm = max(cols - medwing,1);
    rm = min(cols + medwing,imw);
    tm = max(rows - medwing,1);
    bm = min(rows + medwing,imh);
    for l = 1:length(rows)
        distWindow = dist0(tm(l):bm(l),lm(l):rm(l)).*edgeVld(tm(l):bm(l),lm(l):rm(l));
        distWindow = distWindow(:);
        dist0(rows(l),cols(l)) = median(distWindow(find(distWindow~=0)));
        dist1(rows(l),cols(l)) = dist0(rows(l),cols(l));
        colorWindow_r = im0(tm(l):bm(l),lm(l):rm(l),1).*edgeVld(tm(l):bm(l),lm(l):rm(l));
        colorWindow_g = im0(tm(l):bm(l),lm(l):rm(l),2).*edgeVld(tm(l):bm(l),lm(l):rm(l));
        colorWindow_b = im0(tm(l):bm(l),lm(l):rm(l),3).*edgeVld(tm(l):bm(l),lm(l):rm(l));
        colorWindow_r = colorWindow_r(:);colorWindow_g = colorWindow_g(:);colorWindow_b = colorWindow_b(:);
        im0(rows(l),cols(l),1) = median(colorWindow_r(find(distWindow~=0)));
        im0(rows(l),cols(l),2) = median(colorWindow_g(find(distWindow~=0)));
        im0(rows(l),cols(l),3) = median(colorWindow_b(find(distWindow~=0)));
        im1(rows(l),cols(l),:) = im0(rows(l),cols(l),:);
    end
    ImagePD = ImagePD - DealPixel;
    edgeVld = or(edgeVld,DealPixel);
end

end