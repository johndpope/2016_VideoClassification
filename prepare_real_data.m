clear;
train_file = fopen('./ucfTrainTestlist/trainlist01.txt');
test_file = fopen('./ucfTrainTestlist/testlist01.txt');
counter = 1;
dic = load('./dictionary.mat');
dic = dic.s;
imdb.meta.sets=['train','test'];

while ~feof(train_file)
    tline = fgetl(train_file);
    info = textscan(tline,'%s%d');
    start = strfind(info{1},'/');
    str = cell2mat(info{1});
    imdb.images.data(:,counter) = cellstr(strcat('/DATACENTER/1/zzd/flownet-release/models/flownet/UCF-OpticFlow-s',str(start{1}:end),'/'));
    imdb.images.label(:,counter) = info{2};
    imdb.images.set(:,counter) = 1;
    fprintf('selected_win:%d\n',counter);
    counter = counter+1;
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
    imdb.images.data(:,counter) = cellstr(strcat('/DATACENTER/1/zzd/flownet-release/models/flownet/UCF-OpticFlow-s',str(start{1}:end),'/'));
    imdb.images.label(:,counter) = label;
    imdb.images.set(:,counter) = 2;
    fprintf('selected_win:%d\n',counter);
    counter = counter+1;
end
fclose(test_file);

save('./ucf_url.mat','imdb','-v7.3');