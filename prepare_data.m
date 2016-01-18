clear;
train_file = fopen('./ucfTrainTestlist/trainlist01.txt');
test_file = fopen('./ucfTrainTestlist/testlist01.txt');
counter = 1;
dic = load('./dictionary.mat');
dic = dic.s;
imdb.meta.sets=['train','test'];
imdb.images.traindata=[];
imdb.images.testdata=[];
while ~feof(train_file)
    tline = fgetl(train_file);
    info = textscan(tline,'%s%d');
    start = strfind(info{1},'/');
    str = cell2mat(info{1});
    filename = str(start{1}+1:end);
    imdb.images.data(:,counter) = cellstr(filename);
    %get_real_data
    dir_ = strcat('/DATACENTER/1/zzd/flownet-release/models/flownet/UCF-OpticFlow-s',str(start{1}:end),'/');
    fidin = dir(dir_);
    data = [];
    for ii=1:length(fidin)
       if(isequal(fidin(ii).name,'.')||isequal(fidin(ii).name,'..'))
           continue;
       end
       if(isempty(strfind(fidin(ii).name,'.flo')))
           continue;
       end
       tline = strcat(dir_,fidin(ii).name);
       data_tmp = readFlowFile_fast(tline);
       data_tmp = imresize(data_tmp,[240,320]);
       %data_tmp = cat(3,data_tmp,zeros(240,320));
       %store_path = strcat(tline,'.jpeg');
       %imwrite(data_tmp,store_path);
       %p = imread(store_path);
       data = single(cat(3,data,data_tmp));
    end
    imdb.images.traindata = setfield(imdb.images.traindata,filename(1:end-4),data);
    imdb.images.label(:,counter) = info{2};
    imdb.images.set(:,counter) = 1;
    fprintf('selected_win:%d\n',counter);
    counter = counter+1;
    save('./ucf_real.mat','imdb','-v7.3');
end
fclose(train_file);
%}
label = 1;
while ~feof(test_file)
    tline = fgetl(test_file);
    info = textscan(tline,'%s');
    start = strfind(info{1},'/');
    str = cell2mat(info{1});
    key = str(1:start{1}-1);
    if(strcmp(dic.name{label},key)==0)
     label = label+1;
    end
    filename = str(start{1}+1:end);
    imdb.images.data(:,counter) = cellstr(filename);
    %get_real_data
    dir_ = strcat('/DATACENTER/1/zzd/flownet-release/models/flownet/UCF-OpticFlow-s',str(start{1}:end),'/');
    fidin = dir(dir_);
    data = [];
    for ii=1:length(fidin)
       if(isequal(fidin(ii).name,'.')||isequal(fidin(ii).name,'..'))
           continue;
       end
       tline = strcat(dir_,fidin(ii).name);
       data_tmp = readFlowFile_fast(tline);
       data_tmp = imresize(data_tmp,[240,320]);
       data = single(cat(3,data,data_tmp));
    end
    imdb.images.testdata = setfield(imdb.images.testdata,filename(1:end-4),data);
    imdb.images.label(:,counter) = label;
    imdb.images.set(:,counter) = 2;
    fprintf('selected_win:%d\n',counter);
    counter = counter+1;
end
fclose(test_file);

save('./ucf_real.mat','imdb','-v7.3');