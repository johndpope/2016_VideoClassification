run(fullfile(fileparts(mfilename('fullpath')), ...
    '..', '..', 'matlab', 'vl_setupnn.m')) ;

%run matlab/vl_setupnn ;
%model = 'imagenet-googlenet-dag' ;
%model = 'imagenet-vgg-m' ;
%model = 'imagenet-vgg-f' ;
model = 'imagenet-matconvnet-vgg-m';
net = load(sprintf('../../data/models/%s.mat', model)) ;

if strcmp(model, 'imagenet-googlenet-dag')
    net = dagnn.DagNN.loadobj(net) ;
    out = net.getVarIndex('prob') ;
    dag = true ;
else
    dag = false ;
end

scoress = zeros(1000,1) ;
momentum = .5 ;

% obtain and preprocess an image
im = imread('1.jpg') ;
d = size(im,1)-size(im,2) ;
dy = floor(max(d,0)/2) ;
dx = floor(max(-d,0)/2) ;
im = im(dy+1:end-dy, dx+1:end-dx, :) ; % center crop
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2), 'bilinear') ;
averageImage = reshape(net.meta.normalization.averageImage,1,1,3);
im_ = bsxfun(@minus,im_,averageImage) ;

% run the CNN
if dag
    net.eval({'data',im_}) ;
    scores = squeeze(gather(net.vars(out).value)) ;
else
    res = vl_simplenn(net, im_) ;
    scores = squeeze(gather(res(end).x)) ;
end

% smooth scores and pick the best
scoress = momentum*scoress + (1-momentum)*scores ;
[bestScore, best] = max(scoress) ;

% visualize
figure(1) ; clf ; imagesc(im) ;
title(sprintf('%s, score %.3f',...
    strtok(net.meta.classes.description{best},','), bestScore), ...
    'FontSize', 30) ;
axis equal off ;
drawnow ;

