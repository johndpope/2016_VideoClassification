addpath('../MATLAB');
addpath matlab;
imdb = load('./ucf_url.mat') ;
imdb = imdb.imdb;
batch = randperm(128);
imlist = imdb.images.data(:,batch) ;  % get random video
batch_size = numel(batch);
%im = single(ones(240,320,2,10*batch_size));
%----------get random video----zip 10 frame----
tic;
    f = zzd(imlist);
    ff = reshape(f,640,240,10*batch_size);
    f2 = permute(ff,[2 1 3]);
    img = cat(3,f2(:,(1:320)*2-1,:),f2(:,(1:320)*2,:));
toc;
im = reshape(img,240,320,20,batch_size);