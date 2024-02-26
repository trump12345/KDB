clc;
clear;
folderPath = 'C:\Users\小范\Desktop\学学\dataset';  % 指定目录路径
outputFolderPath = 'C:\Users\小范\Desktop\学学\dataset1';  % 输出目录路径
filePattern = '*.arff';  % 文件格式
fileList = dir(fullfile(folderPath, filePattern));
for i = 1:numel(fileList)
    filePath = fullfile(folderPath, fileList(i).name);
     [~, filename, ~] = fileparts(fileList(i).name);
    outputFile = fullfile(outputFolderPath, [filename '.xlsx']);
    disp(['正在处理...', filename]);
    data=Copy_of_ARFFtoMAT(filePath);
    writetable(data, outputFile,'WriteVariableNames', true);
    disp('----------');
    if i==numel(fileList)
        disp('数据全部处理完成...');
    end
end
%%
data=xlsread("C:\Users\小范\Desktop\学学\dataset1\breast-cancer.xlsx");
outputFolderPath = 'C:\Users\小范\Desktop\学学\dataset1';
%data(:,1)=[];
data=data+1;
%outputFile = fullfile(outputFolderPath, 'breast-cancer22.xlsx');
writematrix(data, 'C:\Users\小范\Desktop\学学\dataset1\breast-cancer33.xlsx');
%data=data1';
%node_flag = 'A';
%[node_sizes, node_type,node_names] = get_node(data,node_flag);


%%
clc;
clear;
data=Copy_of_ARFFtoMAT('C:\Users\小范\Desktop\学学\dataset\glass.arff');


%%
% 生成一个具有多个强连通分量的有向无环图邻接矩阵
clc
clear
adj_matrix = [
    0, 1, 1, 0, 0;
    0, 0, 1, 0, 0;
    0, 0, 0, 0, 0;
    0, 0, 0, 0, 1;
    0, 0, 0, 0, 0
];
view(biograph(adj_matrix));
visited_node=dfs(adj_matrix,1);
disp('Visited nodes:');
disp(visited_node);




%%
adj_matrix = [
    0, 1, 1, 0, 0;
    0, 0, 1, 0, 0;
    0, 0, 0, 0, 0;
    0, 0, 0, 0, 1;
    0, 0, 0, 0, 0
];
view(biograph(adj_matrix));
G = digraph(adj_matrix);
sorted_nodes = toposort(G);

% 输出排序结果
disp(['拓扑排序结果：', num2str(sorted_nodes')]);
