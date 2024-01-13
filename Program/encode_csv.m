function data=encode_csv(filename)
%对csv文件进行编码。
%input：文件路径
%e.g. filename = 'C:\Users\anneal.arff.csv';
%opts = detectImportOptions(filename);
%opts.VariableNamingRule = 'preserve';
data = readtable(filename);
[~,col]=size(data);
featureNames = data.Properties.VariableNames; %获取数据集的特征名字
for i = 1:col   %将table 中的cell转成string
    varName = featureNames{i};
    if iscell(data.(varName))
        data.(varName)=string(data.(varName));
    end
end
data = table2array(data);%将table转成矩阵
for i=1:col
    strcol=data(:,i);
    if ~isstring(strcol)
        strcol=cellstr(data(:,i));%如果不是string转成string
    end
    [encodedLabels, ~] = grp2idx(strcol);%进行编码，每种不同的
       % 类别是一种数字编码
    data(:,i)=encodedLabels;%将编码后的列赋值给原矩阵
end

data=str2double(data);%将string矩阵转成数值矩阵
data=[featureNames;num2cell(data)];
% 选择要保存的文件类型
filter = {'*.xlsx','Excel Files (*.xlsx)'};

% 打开保存文件对话框
[filename, filepath] = uiputfile(filter,'Save as');

% 如果用户取消操作，则返回空值，否则保存文件
if filename ~= 0
    % 构造完整的文件名（包括路径）
    full_path = fullfile(filepath, filename);
    
    % 将数据写入 Excel 文件
    xlswrite(full_path, data);
end
end
