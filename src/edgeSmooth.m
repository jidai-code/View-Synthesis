function [smooth_view] = edgeSmooth(final_view,final_dist)
%% smooth out pixels on the edges for a more realistic result
%% code
edge_th = 0.05;
fm = ones(3);
[imh,imw] = size(final_dist);
final_edge = edge(final_dist,'Canny',edge_th);
final_edge = imdilate(final_edge,fm);
% figure;imshow(final_edge);
ft_view = cat(3,medfilt2(final_view(:,:,1)),medfilt2(final_view(:,:,2)),medfilt2(final_view(:,:,3)));
smooth_view = reshape(final_view,imh*imw,3);
ft_view = reshape(ft_view,imh*imw,3);
smooth_view(find(final_edge(:)),:) = ft_view(find(final_edge(:)),:);
smooth_view = reshape(smooth_view,imh,imw,3);
end