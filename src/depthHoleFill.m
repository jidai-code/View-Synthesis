function [final_view,final_dist] = depthHoleFill(int_view,int_dist)
%% fill out holes in the synthesized depth map with hierarchical clustering
time0 = cputime;
%% parameter declare
neighbor_mask = ones(6);
stdTH = 0.0003;
%% code
[imh,imw] = size(int_dist);
final_view = int_view;final_dist = int_dist;
[Xid,Yid] = meshgrid(1:imw,1:imh);
Xid = Xid(:);Yid = Yid(:);
holes = int_dist == -1;
dist_v = int_dist(:);
CC = bwconncomp(holes);
Int_view = cell(CC.NumObjects,1);
Int_dist = cell(CC.NumObjects,1);
parfor i = 1:CC.NumObjects
    PixelID = CC.PixelIdxList{i};
    if(length(PixelID) > 20)
        ImagePD = zeros(imh,imw);
        for j = 1:length(PixelID)
            ImagePD(Yid(PixelID(j)),Xid(PixelID(j))) = 1;
        end
        edgePixel = imdilate(ImagePD,neighbor_mask) - ImagePD;
        edgeV = dist_v(find(edgePixel(:)));
        edgeV = edgeV(find(edgeV~=-1));
        %%
        IntDist = pdist(edgeV);
        LinkTree = linkage(IntDist);
        k = length(LinkTree) - length(find(LinkTree(:,3) < 0.001)) + 1;
        [Int_view{i},Int_dist{i}] = Type2Fill(int_view,int_dist,edgePixel,edgeV,std(edgeV),ImagePD,k);
    end
end

final_view = reshape(final_view,imh*imw,3);
final_dist = final_dist(:);
for ii = 1:length(Int_view)
    if (~isempty(Int_view{ii}))
        t_view = Int_view{ii};t_dist = Int_dist{ii};
        t_view = reshape(t_view,imh*imw,3);t_dist = t_dist(:);
        final_view(find(t_dist~=0),:) = t_view(find(t_dist~=0),:);
        final_dist(find(t_dist~=0)) = t_dist(find(t_dist~=0));
    end
end

final_view = reshape(final_view,imh,imw,3);
final_dist = reshape(final_dist,imh,imw);

time1 = cputime;
fprintf('depth holes filled: %.2fs ...\n',time1 - time0);
fprintf('==========================================\n');
end