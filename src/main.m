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
% Last updated on 9th April, 2015 
%%

clear all,close all;

%add path to solver for training 
addpath('../solver_sparseCoding/sc2');


%Parameters for super-resolution algorithm 
scale = 3.0; % scale factor by which the image needs to be magnified 
patch_size = 3; % patch size for the low resolution input image
overlap = 1; % overlap between adjacent patches
l_da = 0.001; % sparsity  $\lambda$ parameter 
istraining=false;

imgDir='../training_files/';
noPatches=80000;
codebookSize=1024;

if(istraining)
[Y,sizeh,sizel]=dict_sample(imgDir,noPatches, codebookSize,scale,patch_size,overlap);
dict_train(Y,l_da,sizeh,sizel,codebookSize);
else
load('Data/Dictionary/dictionary.mat');
end


% read image and poplulate files specs.Crop image suitable to make the
% dimensions a multiple of the scale factor.Generate low resolution image for
% super-resolution using bicubic interpolation

file_dir = '../data/Child_input.png';
sampImg = imread(file_dir); 
img_size=size(sampImg);
img_size(1:end-1)=(fix(img_size(1:end-1)./scale))*scale;%generate size of cropped image
sampImg=sampImg(1:img_size(1),1:img_size(2), : );
testImg=sampImg;
testImg_workin = rgb2ycbcr(testImg);
testImg_y = double(testImg_workin(:,:,1));



%super-resolution algorithm to process the luminance
%need to add back propogation

[Img_y] = SR(testImg_y,Dh, Dl, l_da, scale, patch_size, overlap ,[img_size(1:2) , 3]);





% Interpolate the cb-cr channels using bicubic interpolation to the higher
% scale


temp_img= rgb2ycbcr(imresize(testImg,scale,'bicubic'));
Img_cb = temp_img(:,:,2);
Img_cr = temp_img(:,:,3);
clear temp_img

%Display results and input for comparison
recon_Img(:,:,1) = uint8(Img_y);
recon_Img(:,:,2) = Img_cb;
recon_Img(:,:,3) = Img_cr;

figure,imshow(ycbcr2rgb(recon_Img),[]);
title('Super-resolved Image using Sparse Representation of Raw Image Patches ');

