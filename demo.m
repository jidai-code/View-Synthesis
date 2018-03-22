clear;
close all;
clc;

%%
addpath('src');
poolStartup();  % create parallel pool on cluster
theta = 0.5;    % parameter for new view location, theta can be any number from 0 to 1

%% synthesizing
[im0,im1,disp0,disp1,gt] = loadData();  % read data
[im0,im1] = removeGhostContour(im0,im1,disp0,disp1); % remove ghost contour artifacts
[int_view,int_dist] = initialSynthesize(im0,im1,disp0,disp1,theta); % synthesis new view and deptg map
[final_view,final_dist] = depthHoleFill(int_view,int_dist); % fill holes in depth map
[fl_view,fl_dist] = colorHoleFill(final_view,final_dist);   % fill holes in color image
[smooth_view] = edgeSmooth(fl_view,fl_dist);    % smooth edge for a more realistic look

%% evaluation
fprintf('==========================================\n');
fprintf('computing PSNR and SSIM scores ... \n');
PSNR = psnr(smooth_view,gt);    % PSNR score
SSIM = ssim(smooth_view,gt);    % SSIM score

%% display
figure;
suptitle(sprintf('PSNR: %.3f, SSIM: %.3f',PSNR,SSIM));
subplot(1,2,1);
imshow(gt);
title('ground truth');
subplot(1,2,2);
imshow(smooth_view);
title('synthesized view');