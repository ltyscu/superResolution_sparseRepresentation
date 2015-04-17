%% 
% Implements the super-resolution algorithm in the paper
% [1] "Image Super-Resolution as Sparse Representation of Raw Image Patches" by 
% Jianchao Yang ; ECE Dept., Univ. of Illinois at Urbana-Champaign, Urbana, IL ;
% Wright, J. ; Huang, T. ; Yi Ma
% Code by Shiv Surya, 
% Graduate student,
% Electrical engineering,
% USC
% email:ssurya@usc.edu, shiv.surya314@gmail.com
% Last updated on 14th April, 2015 
%%

function [imgh] = SR(imgl,Dh, Dl, l_da, scale, patch_sizel, overlap ,img_sizel)

%-> Super-resplved image and its associated support variables have postfix "h"
%-> Input image and its associated suporting variables have postfix "l"
%-> Intermediate upsampled image for extracting the features from the input image
%   and supporting variables have postfix "m"

%scale of the intermediate image for extrating the features from the input image"m"
feat_scale=2;

%size of the upsampled image "h"
img_sizeh = [img_sizel(1:2).*scale ,3];


% extract gradient feature from lIm using f1,f2,f3,f4 in sec.3.2 of [1]
% from an upsampled image of size feat_scale=2.
imgm = imresize(imgl, 2,'bicubic');

%patch sizes for intermediate and magnified image
patch_sizeh = patch_sizel*scale;
patch_sizem = patch_sizel*feat_scale;


%feature for the input image from the intermediate image
 fea(:,:,1) = conv2(imgm,[-1,0,1],'same');
 fea(:,:,2) = conv2(imgm,[-1,0,1]','same');
 fea(:,:,3) = conv2(imgm,[1,0,-2,0,1],'same');
 fea(:,:,4) = conv2(imgm,[1,0,-2,0,1]','same');


%generate grid for sampling the patches from the input image
ygrid = ceil(patch_sizel/2.0):patch_sizel-overlap:img_sizel(1)-patch_sizel;
xgrid = ceil(patch_sizel/2.0):patch_sizel-overlap:img_sizel(2)-patch_sizel;
%add last patch to make sure that complete image is recovered.Patch may be
%written twice but can  be ignored
ygrid = [ygrid, img_sizel(1)-patch_sizel];
xgrid = [xgrid, img_sizel(2)-patch_sizel];




%initialize recovered image and a normalization matrix
imgh = zeros(img_sizeh(1:2));
normalizationMat = zeros(img_sizeh(1:2));

%initialize girds for traversing the upsampled image and recovered image
xgridm = (xgrid - 1)*feat_scale + 1;
ygridm = (ygrid - 1)*feat_scale + 1;
xgridh = (xgrid-1)*scale + 1;
ygridh = (ygrid-1)*scale + 1;

%initialize a counter for no of patches and a wait bar
counter=0;
h=waitbar(0,'Wait....Processing patches ');


%create a bicubic image for filling in the borders           
img_bicubic = imresize(imgl, 3, 'bicubic');
        

% loop to recover each patch
for u = 1:length(xgridm),
    for v = 1:length(ygridm),
    

    % track counter for display and display progress in progress bar
    counter=counter+1;
    waitbar(counter/(length(xgridm)*length(ygridm)),h,['Wait..Processing patches:',.....
        num2str(fix(100*counter/(length(xgridm)*length(ygridm)))),'% complete']);
    
       
        patchm = imgm(ygridm(v):ygridm(v)+patch_sizem-1, xgridm(u):xgridm(u)+patch_sizem-1);
        avg_patch = mean(patchm(:));
        
        
        featpatch = fea(ygridm(v):ygridm(v)+patch_sizem-1, xgridm(u):xgridm(u)+patch_sizem-1,:);
        featpatch = featpatch(:);
        
        normalization_m = sqrt(sum(featpatch.^2));
        
        if normalization_m > 1,
            yy = featpatch./normalization_m;
        else
            yy = featpatch;
        end
        
       %solve the convex problem using lasso() in MATLAB statistic and ML toolbox 
       w=lasso(Dl,yy,'Lambda',l_da);

       %Alternate solution using cvx solver. Uncomment the lines below if you do not have the 
       %statistics toolbox in MATLAB. CVX solver is available here:http://cvxr.com/cvx/
       %The CVX solver is much slower than  lasso() in matlab
       %solve the convex solution using cvx solver        
       %        cvx_begin quiet
       %          
       %        variable w(size(Dl,2));     
       %        minimize( square_pos(norm(Dl*w - yy)) + l_da*norm(w,1) )
       %        cvx_end
  
        
        if isempty(w),
            w = zeros(size(Dl, 2), 1);
        end
        
        if normalization_m > 1,
                    patchh = Dh*w*normalization_m;
         else
                    patchh = Dh*w;
       end
            
        % reshape the patch to 2-D grid and add the mean of the current
         
        patchh = reshape(patchh, [patch_sizeh, patch_sizeh]) + avg_patch;
        
       
        %write the patche to the recovered image "imgh"
        imgh(ygridh(v):ygridh(v)+patch_sizeh-1, xgridh(u):xgridh(u)+patch_sizeh-1)= imgh(ygridh(v):ygridh(v)+patch_sizeh-1, xgridh(u):xgridh(u)+patch_sizeh-1) + patchh;
        normalizationMat(ygridh(v):ygridh(v)+patch_sizeh-1, xgridh(u):xgridh(u)+patch_sizeh-1)= normalizationMat(ygridh(v):ygridh(v)+patch_sizeh-1, xgridh(u):xgridh(u)+patch_sizeh-1) + 1;
    
    
    end
end

        
%close progress bar
close(h);

%%


%normalize image
imgh = imgh./normalizationMat;

%borders are written  from the bicubic image "img_bicubic"
imgh(1:patch_sizel, :) = img_bicubic(1:patch_sizel, :);
imgh(:, 1:patch_sizel) = img_bicubic(:, 1:patch_sizel);

imgh(end-2:end, :) = img_bicubic(end-2:end, :);
imgh(:, end-2:end) = img_bicubic(:, end-2:end);

%iterated back projection in 2010 paper. Gives much better results
[imgh]=itrBackProjection(imgh,imgl,scale,patch_sizel);

%BP algorithm described in the current paper
%BP can be ognored altogether as the results are fairly good without back projection
%imgh=itrBackProjection2(imgl, imgh,scale);% in 2008 paper

imgh=uint8(imgh);


end % end of function


% Simple iterative back projection 
function [imgh] = itrBackProjection2(imgl,imgh,scale)

maxItr=100;


gauss_blur = fspecial('gaussian', 5, 1);
gauss_blur = gauss_blur.^2;
gauss_blur = gauss_blur./sum(gauss_blur(:));


i=1;
while (i < maxItr)
    img_prev=imgh;
    imgt = imresize(imgh, scale^-1, 'bicubic');
    err = imresize(imgl - imgt, scale, 'bicubic');
    imgh = imgh + conv2(err, gauss_blur, 'same');
    i=i+1;
    change = norm(imgh-img_prev)/norm(imgh);
    change
    if abs(change) <.00001 && i>10
        break  
    end
end
 

end
