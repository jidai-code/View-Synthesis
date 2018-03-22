function [im0,im1,disp0,disp1, gt] = loadData()
%%  read color images and disparity maps for left and right view and ground truth synthesized image.
%   im0: color image of left view
%   im1: color image of right view
%   disp0: disparity image of left view
%   disp1: disparity image of right view
%   gt: ground truth color image of synthesized view (theta = 0.5)

%% code
im0 = im2double(imread('viewL.png'));
im1 = im2double(imread('viewR.png'));
disp0 = double(imread('dispL.png'));
disp1 = double(imread('dispR.png'));
gt = im2double(imread('GT.png'));
fprintf('data loaded ... \n');
fprintf('==========================================\n');
end