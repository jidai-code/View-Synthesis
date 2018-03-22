function [im3,disp3] = initialSynthesize(im0,im1,disp0,disp1,theta)
%% Synthesize initial view and depth map
% initial synthesis with two anchor views and corresponding disparity map
% holes and artifacts will be removed in the later process

%% code
time0 = cputime;

vld0 = disp0~=0;
vld1 = disp1~=0;

[imh,imw,~] = size(im0);

dist0 = 1./disp0;

dist1 = 1./disp1;

dist_trd = 0.0001;

sigfactor = 5;

im2 = zeros(imh,imw,3);
dist2 = 99 * ones(imh,imw);
im2w = zeros(imh,imw) + 0.00000001;
im3 = zeros(imh,imw,3);
dist3 = 99 * ones(imh,imw);
im3w = zeros(imh,imw) + 0.00000001;


%% synthesis each view
for rid = 1:imh
    for cid = 1:imw
        if (vld0(rid,cid) ~= 0)
            ncid = (cid - theta * disp0(rid,cid));
            ncidl = floor(ncid);
            ncidr = ceil(ncid);
            wl = exp(-sigfactor * (ncid - ncidl));
            wr = exp(-sigfactor * (ncidr - ncid));
            if (ncidl > 0)
                if (abs(dist2(rid,ncidl) - dist0(rid,cid)) < dist_trd)
                    im2(rid,ncidl,:) = im2(rid,ncidl,:) + im0(rid,cid,:) * wl;
                    im2w(rid,ncidl,:) = im2w(rid,ncidl,:)+ wl;
                elseif (dist2(rid,ncidl) > dist0(rid,cid))
                    dist2(rid,ncidl) = dist0(rid,cid);
                    im2(rid,ncidl,:) = im0(rid,cid,:) * wl;
                    im2w(rid,ncidl,:) = wl;
                end
            end
            if (ncidr > 0)
                if (abs(dist2(rid,ncidr) - dist0(rid,cid)) < dist_trd)
                    im2(rid,ncidr,:) = im2(rid,ncidr,:) + im0(rid,cid,:) * wr;
                    im2w(rid,ncidr,:) = im2w(rid,ncidr,:)+ wr;
                elseif (dist2(rid,ncidr) > dist0(rid,cid))
                    dist2(rid,ncidr) = dist0(rid,cid);
                    im2(rid,ncidr,:) = im0(rid,cid,:) * wr;
                    im2w(rid,ncidr,:) = wr;
                end
            end
        end
    end
end

for rid = 1:imh
    for cid = 1:imw
        if (vld1(rid,cid) ~= 0)
            ncid = (cid + (1 - theta) * disp1(rid,cid));
            ncidl = floor(ncid);
            ncidr = ceil(ncid);
            wl = exp(-sigfactor * (ncid - ncidl));
            wr = exp(-sigfactor * (ncidr - ncid));
            if (ncidl <= imw)
                if (abs(dist3(rid,ncidl) - dist1(rid,cid)) < dist_trd)
                    im3(rid,ncidl,:) = im3(rid,ncidl,:) + im1(rid,cid,:) * wl;
                    im3w(rid,ncidl,:) = im3w(rid,ncidl,:)+ wl;
                elseif (dist3(rid,ncidl) > dist1(rid,cid))
                    dist3(rid,ncidl) = dist1(rid,cid);
                    im3(rid,ncidl,:) = im1(rid,cid,:) * wl;
                    im3w(rid,ncidl,:) = wl;
                end
            end
            if (ncidr <= imw)
                if (abs(dist3(rid,ncidr) - dist1(rid,cid)) < dist_trd)
                    im3(rid,ncidr,:) = im3(rid,ncidr,:) + im1(rid,cid,:) * wr;
                    im3w(rid,ncidr,:) = im3w(rid,ncidr,:)+ wr;
                elseif (dist3(rid,ncidr) > dist1(rid,cid))
                    dist3(rid,ncidr) = dist1(rid,cid);
                    im3(rid,ncidr,:) = im1(rid,cid,:) * wr;
                    im3w(rid,ncidr,:) = wr;
                end
            end
        end
    end
end
nim2 = im2./repmat(im2w,1,1,3);
nim3 = im3./repmat(im3w,1,1,3);

%% merge two views
im3 = zeros(imh,imw,3);

disp3 = min(dist2,dist3);
for rid = 1:imh
    for cid = 1:imw
        if (abs(dist2(rid,cid) - dist3(rid,cid)) < dist_trd)
            im3(rid,cid,:) = nim2(rid,cid,:)*(1-theta) + nim3(rid,cid,:)*(theta);
        elseif (dist2(rid,cid) > dist3(rid,cid))
            im3(rid,cid,:) = nim3(rid,cid,:);
        else
            im3(rid,cid,:) = nim2(rid,cid,:);
        end
    end
end

%%
disp3 = disp3 + (-100) * (disp3 == 99);

time1 = cputime;
fprintf('initiate synthesize completed: %.2fs ... \n',time1 - time0);

end