function ucf_flownet(varargin)
addpath('../MATLAB');
% -------------------------------------------------------------------------
% Part 4.1: prepare the data
% -------------------------------------------------------------------------

% Load character dataset
imdb = load('./ucf_url.mat') ;
imdb = imdb.imdb;
% -------------------------------------------------------------------------
% Part 4.2: initialize a CNN architecture
% -------------------------------------------------------------------------

net = vggm();
%net = load('data/48net-cifar-v3-custom-dither0.1-128-3hard/f48net-cpu.mat');


% -------------------------------------------------------------------------
% Part 4.3: train and evaluate the CNN
% -------------------------------------------------------------------------

opts.train.batchSize = 128;
%opts.train.numSubBatches = 1 ;
opts.train.continue = true;
opts.train.gpus = 3;
opts.train.prefetch = false ;
opts.train.sync = false ;
opts.train.errorFunction = 'multiclass' ;
opts.train.expDir = '/DATACENTER/zzd1/ucf-model/ucf_flownet_v1.0/' ;
opts.train.learningRate = [0.001*ones(1,300) 0.0005*ones(1,30)] ;
opts.train.weightDecay = 0.0005;
opts.train.numEpochs = numel(opts.train.learningRate) ;
[opts, ~] = vl_argparse(opts.train, varargin) ;

% Call training function in MatConvNet
[net,info] = cnn_train(net, imdb, @getBatch,opts) ;

% Save the result for later use
net = vl_simplenn_move(net,'cpu');
net.layers{end} = [];
net.layers{end+1} = struct('type', 'softmax') ;
save(strcat(opts.expDir,'ucf-net.mat'), '-struct', 'net') ;

% -------------------------------------------------------------------------
% Part 4.4: visualize the learned filters
% -------------------------------------------------------------------------

figure(2) ; clf ; colormap gray ;
vl_imarraysc(squeeze(net.layers{1}.weights{1}),'spacing',2)
axis equal ; title('filters in the first layer') ;

% --------------------------------------------------------------------
function [im, labels] = getBatch(imdb, batch)
% --------------------------------------------------------------------
% im is a cell list
imlist = imdb.images.data(:,batch) ;  % get random video
batch_size = numel(batch);
im = ones(224,224,2,10,batch_size);
%----------get random video----zip 10 frame----
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
    imv = zeros(240,320,2,10);
    imv(:,:,:,1) = imresize(readFlowFile_fast(strcat(p,file(selected).name)),[240,320]);
    imv(:,:,:,2) = imresize(readFlowFile_fast(strcat(p,file(selected+1).name)),[240,320]);
    imv(:,:,:,3) = imresize(readFlowFile_fast(strcat(p,file(selected+2).name)),[240,320]);
    imv(:,:,:,4) = imresize(readFlowFile_fast(strcat(p,file(selected+3).name)),[240,320]);
    imv(:,:,:,5) = imresize(readFlowFile_fast(strcat(p,file(selected+4).name)),[240,320]);
    imv(:,:,:,6) = imresize(readFlowFile_fast(strcat(p,file(selected+5).name)),[240,320]);
    imv(:,:,:,7) = imresize(readFlowFile_fast(strcat(p,file(selected+6).name)),[240,320]);
    imv(:,:,:,8) = imresize(readFlowFile_fast(strcat(p,file(selected+7).name)),[240,320]);
    imv(:,:,:,9) = imresize(readFlowFile_fast(strcat(p,file(selected+8).name)),[240,320]);
    imv(:,:,:,10) = imresize(readFlowFile_fast(strcat(p,file(selected+9).name)),[240,320]);
    im(:,:,:,:,i) = random_cut(imv);
end
toc;
im = single(reshape(im,224,224,20,numel(batch)));
labels = double(imdb.images.label(1,batch)) ;
