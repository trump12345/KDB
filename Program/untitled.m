clc;
clear;
folderPath = 'C:\Users\27914\Desktop\文献\数据集 weka';  % 指定目录路径
outputFolderPath = 'C:\Users\27914\Desktop\文献\数据处理后';  % 输出目录路径
filePattern = '*.arff';  % 文件格式
fileList = dir(fullfile(folderPath, filePattern));
for i = 1:numel(fileList)
    filePath = fullfile(folderPath, fileList(i).name);
     [~, filename, ~] = fileparts(fileList(i).name);
    outputFile = fullfile(outputFolderPath, [filename '.xlsx']);
    disp(['正在处理...', filename]);
    data=ARFFtoMAT(filePath);
    writetable(data, outputFile,'WriteVariableNames', false);
    disp('----------');
end
%%
%data1=xlsread("eqwe.xlsx");
%data=data1';
%node_flag = 'A';
%[node_sizes, node_type,node_names] = get_node(data,node_flag);


%%
clc;
clear;
data=ARFFtoMAT('C:\Users\27914\Desktop\文献\数据集 weka\autos.arff');
