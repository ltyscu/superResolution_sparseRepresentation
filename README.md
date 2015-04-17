# superResolution_sparseRepresentation
Implements super-resolution algorithm via sparse representation of Raw patches in images as 
described in paper "Image Super-Resolution as Sparse Representation of Raw Image Patches" by 
Jianchao Yang ; ECE Dept., Univ. of Illinois at Urbana-Champaign, Urbana, IL ;Wright, J. ; 
Huang, T. ; Yi Ma.

The convex optimization problem in the algorithm can be solved by the MATLAB builtin function
lasso() or using CVX solver.

Two Backpropogation algorithms are implemented: itrBackPropagation() and itrBackPropagation2().
Good results can be obtained without using backpropogation,but use of backpropagation gives
marginally better results.

The dictionary is trained for magnification factor of 3.0. It has to be retrained if you are 
planning to magnify by a different factor. I chose this result as I wanted to replicate the authors 
results. Dictionary training took almost 2 days on my Intel I7 2.8 Ghz laptop(I was doing marginal 
work in parallel, just to give you an idea) 

The data in \training is borrowed from the authors site.Test images are borrowed from the author's 
site and Irani.et al's site(who are the authors of the other famous super-resolution algorithm).


I implemented this do that I could understand the algorithm.Feel free to contact me at 
shiv.surya314@gmail.com if you have any doubts.


