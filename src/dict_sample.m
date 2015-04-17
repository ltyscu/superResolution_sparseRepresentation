%dictionary training
function [Y,sizeh,sizel]=dict_sample(imgDir,noPatches, codebookSize,scale,patch_sizel,overlap)
%written by Shiv Surya

%use this sparsecoding library for training dictionary 
%http://web.eecs.umich.edu/~honglak/softwares/nips06-sparsecoding.htm



%populate statistics of training image
imgList=dir(fullfile([imgDir, '*.bmp']));
noImages=size(imgList,1);

%sample the patches from all the images in the proportion of their size
numelImg=zeros(noImages,1); 
patchesinImage=zeros(noImages,1); 

%parse the images to compute the number of patches that can be sampled from each image
for i=1:noImages
   numelImg(i)=numel(imread([imgDir,imgList(i).name]))/3;
end

%patches in image i in the training set

patchesinImage=fix(noPatches*numelImg/sum(numelImg));
clear numelImg

Yh=[];
Yl=[];
%process each image for patches
for i=1:noImages

        curImage=rgb2gray(imread([imgDir,imgList(i).name]));
        img_sizel=size(curImage);
        img_sizel=(fix(img_sizel./scale))*scale;%generate size of cropped image  
        curImage=curImage(1:img_sizel(1),1:img_sizel(2));
        imgl=curImage;
         feat_scale=2;
        %size of the upsampled image
        img_sizeh = img_sizel.*scale ;


        % extract gradient feature from lIm using f1,f2,f3,f4 in sec.3.2 of [1]
        % from an upsampled image of size feat_scale=2.
        imgm = imresize(imgl, feat_scale,'bicubic');
        imgh = imresize(imgl, scale,'bicubic');
 
        patch_sizeh = patch_sizel*scale;
        patch_sizem = patch_sizel*feat_scale;
         fea=[];
   
         fea(:,:,1) = conv2(double(imgm),[-1,0,1],'same');
         fea(:,:,2) = conv2(double(imgm),[-1,0,1]','same');
         fea(:,:,3) = conv2(double(imgm),[1,0,-2,0,1],'same');
         fea(:,:,4) = conv2(double(imgm),[1,0,-2,0,1]','same');


        ygrid = ceil(patch_sizel/2.0):patch_sizel-overlap:img_sizel(1)-patch_sizel;
        xgrid = ceil(patch_sizel/2.0):patch_sizel-overlap:img_sizel(2)-patch_sizel;
        %add last patch to make sure that complete image is recovered.Patch may be
        %written twice -trivial
        ygrid = [ygrid, img_sizel(1)-patch_sizel];
        xgrid = [xgrid, img_sizel(2)-patch_sizel];
        [x,y] = meshgrid(xgrid,ygrid);
        x=x(:);
        y=y(:);
        t1=randperm(length(y));
        t2=randperm(length(x));
        ygrid=y(t1);
        ygrid=ygrid(1:patchesinImage(i));
        xgrid=x(t2);
        xgrid=xgrid(1:patchesinImage(i));
        
        %initialize girds for traversing the upsampled image and recovered image
        xgridm = (xgrid - 1)*feat_scale + 1;
        ygridm = (ygrid - 1)*feat_scale + 1;
        xgridh = (xgrid-1)*scale + 1;
        ygridh = (ygrid-1)*scale + 1;
        
        count=0;
        allPatchH=[];
        allPatchM=[];
        for j=1:patchesinImage(i)
            
            %extract patch and its transpose accounting for two patches in
            %the dictionary
            count=count+1;
            patchH = imgh(ygridh(j):ygridh(j)+patch_sizeh-1,xgridh(j):xgridh(j)+patch_sizeh-1);
            patchHt=patchH';
   
            patchM = fea(ygridm(j):ygridm(j)+patch_sizem-1,xgridm(j):xgridm(j)+patch_sizem-1,:);
            patchMt= permute(patchM,[2,1,3]);
     
            allPatchH(:,count) = patchH(:)-mean(patchH(:));
            allPatchM(:,count) = patchM(:);
    
            count = count + 1;
            
            allPatchH(:,count) = patchHt(:)-mean(patchH(:));
            allPatchM(:,count) = patchMt(:);
    
    
        
            
        end
        
%concatenate patches sampled from each image
Yh=[Yh,allPatchH];
Yl=[Yl,allPatchM];


    
    
    
end%end of for parsing the images

%concatenate the sampled patches
sizeh=size(Yh,1);
sizel=size(Yl,1);
Y=[Yh;Yl];
end



















%end

