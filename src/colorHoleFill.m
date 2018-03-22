function [fl_view,fl_dist] = colorHoleFill(final_view,final_dist)
%% fill out holes in the synthesized color image
time0 = cputime;
%% code
holes = final_dist == -1;

[imh,imw] = size(holes);

medw = 2;
dealpixel = imdilate(~holes,ones(3)) - (~holes);
while(~isempty(find(dealpixel)))
    [row,col] = find(dealpixel);
    for i = 1:length(row)
        lm = max(1,col(i) - medw);
        rm = min(imw,col(i) + medw);
        um = max(1,row(i) - medw);
        bm = min(imh,row(i) + medw);
        d_medwindow = final_dist(um:bm,lm:rm);
        r_medwindow = final_view(um:bm,lm:rm,1);
        g_medwindow = final_view(um:bm,lm:rm,2);
        b_medwindow = final_view(um:bm,lm:rm,3);
        d_medwindow = d_medwindow(:);
        r_medwindow = r_medwindow(:);
        g_medwindow = g_medwindow(:);
        b_medwindow = b_medwindow(:);
        vldp = find(d_medwindow ~= -1);
        final_dist(row(i),col(i)) = median(d_medwindow(vldp));
        final_view(row(i),col(i),1) = median(r_medwindow(vldp));
        final_view(row(i),col(i),2) = median(g_medwindow(vldp));
        final_view(row(i),col(i),3) = median(b_medwindow(vldp));
    end
    holes = holes - dealpixel;
    dealpixel = imdilate(~holes,ones(3)) - (~holes);
end

fl_view = final_view;
fl_dist = final_dist;

time1 = cputime;
fprintf('color holes filled: %.2fs ...\n',time1 - time0);
end