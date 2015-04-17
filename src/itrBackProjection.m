%% 
% Implements iterated back-projection in the super-resolution algorithm in the paper
% [1] "Image Super-Resolution as Sparse Representation of Raw Image Patches" by 
% Jianchao Yang ; ECE Dept., Univ. of Illinois at Urbana-Champaign, Urbana, IL ;
%itrBackProjection2() is the algorithm described in the above 08' paper while 
% itrBackProjection() is the BP algorithm described in 10' paper. The 
% Wright, J. ; Huang, T. ; Yi Ma
% Code by Shiv Surya, 
% Graduate student,
% Electrical engineering,
% USC
% email:ssurya@usc.edu, shiv.surya314@gmail.com
% Last updated on 9th April, 2015 
%%

function [img_final]=itrBackProjection(imgh,imgl,scale,patch_size)


%sigma for gaussian kernel
sigma=1.5;

corrImg=imgh;%initialize the corrected image with input image

lambda = 0.1; % define the step size for the iterative gradient method
maxItr = 100;% max number of iterations

%initialize a var to hold the most recent corrected image for iterative solution 
corrImg_t = corrImg;
i=1;
H_blur=fspecial('gaussian',[patch_size patch_size]*scale,sigma);

%display status while
h=msgbox('Back projection running','Status');

while (i<maxItr)
    imgFil = imfilter(corrImg, H_blur, 'symmetric','same');
    
    tempA=imgl-imresize(imgFil,1/scale,'bicubic');
    
    tempB=imfilter(imresize(tempA,scale,'bicubic'),H_blur','symmetric','same');        
    
    corrImg=corrImg+lambda*(tempB-0.5*(corrImg-imgh)) ;
    
    %change in the image in consecutive iterations
    delta = norm(corrImg-corrImg_t)/norm(corrImg);
    
   %check for change in consecutive iteration and bound on minimum  no of iterations 
      if abs(delta) <.00001 && i>20
        break  
      end
    corrImg_t = corrImg;
    i = i+1;
end
close(h);
img_final=corrImg;
end





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
    delta = norm(imgh-img_prev)/norm(imgh);
    if abs(delta) <.00001 && i>20
        break  
    end
end
 

end
