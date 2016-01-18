function img = readFlowFile_fast(filename)
fid = fopen(filename, 'r');
tag     = fread(fid, 1, 'float32');
width   = fread(fid, 1, 'int32');
height  = fread(fid, 1, 'int32');
%no_use  = fread(fid, 3, 'int32');
nBands = 2;
% arrange into matrix form
tmp = fread(fid, inf, 'float32');
tmp = reshape(tmp, [width*nBands, height]);
tmp = tmp';
img(:,:,1) = tmp(:, (1:width)*nBands-1);
img(:,:,2) = tmp(:, (1:width)*nBands);
img = imresize(img,[240,320]);      
fclose(fid);

