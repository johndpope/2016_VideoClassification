addpath('../MATLAB');
addpath matlab;
imdb = load('./ucf_url.mat') ;
imdb = imdb.imdb;
batch = randperm(128);
imlist = imdb.images.data(:,batch) ;  % get random video
batch_size = numel(batch);
im = ones(224,224,2,10,batch_size);
%----------get random video----zip 10 frame----
%vl_imreadjpeg(images, 'numThreads', opts.numThreads, 'prefetch') ;
tic;
for i=1:batch_size
    p = imlist{i};
    file = dir(p);
    %-----------random clip
    s = size(file,1)-9;
    rr = randperm(s);
    selected = rr(1);
    Q = 2;
    while(selected == 1 || selected ==2)
        selected = rr(Q);
        Q = Q+1;
    end
    imv = zeros(240,320,2);
    spmd
        switch labindex
            case 1
                imv = readFlowFile_fast(strcat(p,file(selected).name));
            case 2
                imv = readFlowFile_fast(strcat(p,file(selected+1).name));
            case 3
                imv = readFlowFile_fast(strcat(p,file(selected+2).name));
            case 4
                imv = readFlowFile_fast(strcat(p,file(selected+3).name));
            case 5
                imv = readFlowFile_fast(strcat(p,file(selected+4).name));
            case 6
                imv = readFlowFile_fast(strcat(p,file(selected+5).name));
            case 7
                imv = readFlowFile_fast(strcat(p,file(selected+6).name));
            case 8
                imv = readFlowFile_fast(strcat(p,file(selected+7).name));
            case 9
                imv = readFlowFile_fast(strcat(p,file(selected+8).name));
            case 10
                imv = readFlowFile_fast(strcat(p,file(selected+9).name));
        end
    end
    imvq = cat(4,imv{1},imv{2},imv{3},imv{4},imv{5},imv{6},imv{7},imv{8},imv{9},imv{10});
    im(:,:,:,:,i) = random_cut(imvq);
end
im = single(reshape(im,224,224,20,numel(batch)));
labels = double(imdb.images.label(1,batch)) ;
toc;