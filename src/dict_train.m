function [Dh, Dl] = dict_train(Y,l_da,sizeh,sizel,codebookSize)

sparsity_func='L1';
 epsilon=[];
 num_iters=50;
 batch_size=5000;
 fname_save=[];
 pars=[];



% joint learning of the dictionary
Y(1:sizeh,:) = 1/sqrt(sizeh)*Y(1:sizeh,:); 
Y(1+sizeh:end,:) = 1/sqrt(sizel)*Y(1+sizeh:end,:); 

Y = Y(:, 1:100000);
Ynorm = sqrt(sum(Y.^2, 1));



Y = Y(:, Ynorm > 0.00001);
Y = Y./repmat(sqrt(sum(Y.^2, 1)), size(Y,1), 1);

% initial B matrix of codebook size
Binit = Y(:, randperm(size(Y, 2),codebookSize));

[Dict] = sparse_coding(Y, codebookSize, 100*l_da/2, sparsity_func, epsilon, num_iters,batch_size, fname_save, pars, Binit);

Dh = Dict(1:sizeh, :);
Dl = Dict(sizeh+1:end, :);

% normalize the dictionary extractd by the norm of the dictionary
Dh = Dh./repmat(sqrt(sum(Dh.^2, 1)), sizeh, 1);
Dl = Dl./repmat(sqrt(sum(Dl.^2, 1)), sizel, 1);
