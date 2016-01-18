clear;
label_file = fopen('./ucfTrainTestlist/classInd.txt');
s.name = [];
s.label = [];
while ~feof(label_file)
    tline = fgetl(label_file);
    info = textscan(tline,'%d%s');
    str = info{2};
    label = info{1};
    s.name = cat(1,s.name,str);
    s.label = cat(1,s.label,label);
end
save('./dictionary','s')